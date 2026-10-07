# Changelog — picorv32-vivado-verify

All notable engineering decisions and changes. Upstream `YosysHQ/picorv32`
history is NOT reproduced here — see `upstream/` submodule + docs/attribution.

## [0.1.0] — 2026-10-07 — P1: Vivado-xsim verification package
### Added
- `tb/tb_picorv32_xsim.v` — self-checking, no-toolchain testbench (sum/fact/multrap)
- `sim/vivado-xsim/run_xsim.{tcl,bat}` — one-command batch flow, exit-code verdicts
- `tools/check_log.py` — log → PASS/FAIL verdict
- `docs/VIVADO_SIM.md` — procedure resolving upstream issue #267's ask
- `reports/sim_{sum,fact,multrap}.log` — measured evidence (all PASS)
### Fixed (mine, during bring-up — core exonerated in each case)
- `blt` word `fe314ee3` → `fe314ce3` (my offset-double-halving; trace proved -4 jump)
- merged two racing `initial` blocks into one deterministic block
- `--testplusarg` value without leading `+` (2019.2 quirk, verified by experiment)
- absolute forward-slash `-tclbatch` path; stale-log deletion; writable workdir
