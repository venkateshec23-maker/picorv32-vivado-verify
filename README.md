# picorv32-vivado-verify

One-command, self-checking simulation of the PicoRV32 RISC-V core in Xilinx
Vivado xsim — no RISC-V toolchain, no FPGA board required.

> **Status (P1 in progress):** flow + testbench under implementation; no test
> has been run yet. Nothing below is claimed until `reports/` holds the logs.

## Upstream & attribution
- Core RTL: [YosysHQ/picorv32](https://github.com/YosysHQ/picorv32) by Claire Wolf,
  ISC License (see `upstream/COPYING`). Upstream is **archived (read-only)**;
  this repo vendors it as a pinned git submodule and modifies **zero** upstream files.
- Baseline commit: recorded in `docs/attribution.md`.
- Motivation: upstream issue #267 (Vivado simulation help) — this repo is the
  documented answer plus executable proof.

## Layout
`tb/` (my testbench) · `sim/vivado-xsim/` (my flow) · `tools/` (log checker) ·
`upstream/` (their RTL, untouched) · `docs/` · `reports/` (generated evidence)

## Reproduce
```bat
git clone --recurse-submodules <this-repo>
cd picorv32-vivado-verify
sim\vivado-xsim\run_xsim.bat
```
Expected: `OVERALL: PASS` and exit code 0. Requires Vivado 2019.2+ (tested: 2019.2).
