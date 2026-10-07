# P1 Requirements — picorv32 Vivado-xsim verification package

## 1. Goal
Give any engineer with Xilinx Vivado (no RISC-V toolchain, no FPGA board) a
one-command, self-checking simulation of the PicoRV32 core that proves the
core executes real programs correctly in `xsim`.

## 2. Background / problem
Upstream `YosysHQ/picorv32` (ISC, archived July 2026 — read-only) verifies
with Icarus/Verilator/formal, but ships **no Vivado-xsim flow**. Open issue
#267 shows a student unable to simulate picorv32 programs (factorial,
summation) in Vivado and getting stuck with no diagnostic. `testbench_ez.v`
needs no toolchain but is not wired to any Vivado procedure or
self-checking program.

## 3. Scope (P1)
- Batch-mode Vivado simulation: `xvlog → xelab → xsim` via a single TCL script.
- New self-checking testbench `tb_picorv32_xsim.v` (no RISC-V toolchain needed:
  hardcoded instruction memory, like `testbench_ez.v`).
- Two demo programs with known-good answers: factorial(5)=120,
  summation 1+2+3+4 = 10 (mirrors issue #267's failing cases).
- Pass/fail reported as simulator exit status + log line (no waveform eyeballing).
- Doc `docs/VIVADO_SIM.md`: the "correct procedure" #267 asked for, including
  why a naive `mul` program appears to stall (MUL needs PCPI/DSP path or the
  multi-cycle `picorv32_pcpi_mul` Model — documented after measurement).

## 4. Non-goals
- No modification of upstream `picorv32.v` (verified core — restraint is the point).
- No board bring-up, no bitstream (no board available).
- No fix of issues #279/#278/#280/#283 (tracked as future work, not duplicated:
  #281/#282 already propose #279/#278 fixes upstream).

## 5. Acceptance criteria (measurable)
1. `run_xsim.bat` completes on Vivado 2019.2 xsim with exit code 0.
2. Log contains `FACTORIAL_PASS x2=120` and `SUMMATION_PASS`.
3. A deliberately broken program variant (wrong expected value) makes the flow
   FAIL — proves the check is real, not tautological.
4. Clean-checkout reproduce: clone + submodule init + one command → same log.
5. Upstream baseline pinned (commit hash recorded in docs/attribution).

## 6. Environment
Windows 10, Vivado 2019.2 (`C:\Xilinx\Vivado\2019.2`), no Icarus/Verilator,
no RISC-V GCC. All runs execute from a writable working directory
(xsim refuses to run from `C:\Windows\System32`).

## 7. Risks (from reviewer stance)
- 2019.2 xsim vs newer `$display`/`$finish` semantics — mitigated: use only
  Verilog-2001 constructs in the testbench.
- `mul` opcode behavior without M-extension unit — measured, then documented.
- Timing: xsim batch elaboration of picorv32.v is small (<1 min expected).
