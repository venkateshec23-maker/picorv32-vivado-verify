# Attribution

## Upstream project
- **Project:** PicoRV32 — a size-optimized RISC-V CPU core (RV32IMC)
- **Author:** Claire Wolf; maintained under YosysHQ
- **Source:** https://github.com/YosysHQ/picorv32
- **License:** ISC License (`upstream/COPYING`) — permissive; fork and
  redistribution permitted with copyright notice preserved.
- **Baseline pinned:** `ef203c2b0a3fb793280f5114941416c425c5b461`
  (7 Sep 2026, "Merge pull request #296 … archiving" — final upstream state;
  upstream is archived/read-only since July 2026).
- **Vendored as:** git submodule at `upstream/` — zero files modified.

## What existed before my contribution
Core RTL (`picorv32.v`), example SoC (`picosoc/`), Icarus/Verilator benches,
riscv-formal CI, ISA tests (`tests/*.S`). No Vivado-xsim flow, no
no-toolchain self-checking demo for the #267 programs.

## What I changed (P1)
- ADDED `tb/tb_picorv32_xsim.v` (mine)
- ADDED `sim/vivado-xsim/run_xsim.{tcl,bat}` (mine)
- ADDED `tools/check_log.py` (mine)
- ADDED `docs/*` (mine)
- MODIFIED upstream files: **none**.
