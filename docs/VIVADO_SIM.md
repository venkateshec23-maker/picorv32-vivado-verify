# Simulating PicoRV32 in Vivado xsim (answers upstream issue #267)

## One-command flow
```bat
git clone --recurse-submodules <this-repo>
cd picorv32-vivado-verify
sim\vivado-xsim\run_xsim.bat all
```
Expect `OVERALL: PASS`, exit code 0. Requires Vivado 2019.2+ (tested: 2019.2).

## The correct procedure (what #267 got wrong)
1. You do **not** need the RISC-V toolchain for a first simulation. This repo's
   testbench hardcodes instruction words (same technique as upstream
   `testbench_ez.v`) — no `riscv32-unknown-elf-gcc`, no hex files.
2. To run **your own assembly**: hand-assemble (or assemble once with any
   RISC-V assembler and copy the words) into the `memory[i]` table in
   `tb/tb_picorv32_xsim.v`. Verify each word two ways (opcode math +
   cross-check against a known-good word) — a single wrong nibble fails loudly
   here instead of hanging silently.
3. The `mul` in the issue's factorial program **traps by default**:
   upstream `picorv32.v` has `ENABLE_MUL=0` unless you instantiate with it
   enabled or connect a PCPI multiplier. The core asserting `trap` on `mul`
   is correct behavior, not a hang. This repo's `multrap` run proves it.
   For M-free arithmetic, see the `fact` program (5! via repeated addition).

## Vivado 2019.2 xsim quirks found while building this (all verified)
- `--testplusarg` takes the value **without** the leading `+`
  (`--testplusarg prog_fact`, not `+prog_fact`; bare `+prog_fact` errors out).
- `-tclbatch` paths must be **absolute with forward slashes** — backslashes
  are eaten as TCL escapes.
- Run from a **writable directory**: xsim refuses `C:\Windows\System32`.
- Default (strict-Verilog) `xvlog` mode: no unpacked-array declarations,
  `$test$plusargs` (not `$value$plusargs %s`) for flags, `$display`/`$finish`
  only — all used here.
