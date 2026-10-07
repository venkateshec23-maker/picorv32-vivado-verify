# Testing (P1)

## Strategy
Self-checking testbench + log-marker verdicts + Python checker exit codes.
No waveform eyeballing. Every run ends in PASS/FAIL + nonzero-on-fail exit.

## What was executed (all in Vivado 2019.2 xsim, 2026-10-07)
- `run_xsim.bat sum` → PASS (1+2+3+4+5=15, backward branch exercised)
- `run_xsim.bat fact` → PASS (5!=120, 16-instruction program)
- `run_xsim.bat multrap` → PASS (`mul` traps with default params)
- `run_xsim.bat all` → OVERALL: PASS, exit code 0
- Full transcripts in `reports/`.

## Failure actually observed and fixed (evidence the tests work)
1. Mis-encoded `blt` (-4 for -8): FAIL `mem[0x100]=1`, diagnosed from TRACE
   (core jumped exactly -4 — core correct, my word wrong), fixed, re-ran PASS.
2. Two racing `initial` blocks: all runs silently executed the wrong program
   (3× "PASS sum"); merged into one deterministic block.
3. xsim `--testplusarg` needs the value without leading `+` (verified by
   experiment: `fact=0` → `fact=1`).

## Not yet tested (see limitations.md)
No FPGA board run, no AXI/Wishbone variants, no formal proofs re-run,
single Vivado version (2019.2), no randomized programs.
