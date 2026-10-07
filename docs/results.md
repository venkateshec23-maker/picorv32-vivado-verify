# Test evidence (measured 2026-10-07, Vivado 2019.2 xsim, Win10)

Full transcripts: `reports/sim_{sum,fact,multrap}.log` (this dir, generated).

| Program | What it proves | Expected | Observed | Sim-time | Verdict |
|---|---|---|---|---|---|
| sum | loop + backward `blt`, load/store path | mem[0x100]=15 | 15 | 2050 ns | PASS |
| fact | 16-instruction straight-line program, R-type `add` | mem[0x100]=120 | 120 | 1690 ns | PASS |
| multrap | `mul` with default `ENABLE_MUL=0` | trap=1 | trap=1 | 1080 ns | PASS |

Flow: `run_xsim.bat all` → xvlog + xelab once, 3× xsim → `OVERALL: PASS`, exit code 0.
Wall-clock for `all` (compile+elab+3 sims): ~18 s on Ryzen 7 7445HS.
Upstream baseline: `ef203c2` (final archived state). Zero upstream files modified.

## Negative control (the checker is not tautological)
An earlier run with a mis-encoded `blt` (offset -4 instead of -8, my error)
produced `XSIM_RESULT: FAIL wrong result mem[0x100]=1` and exit code 1.
The trace showed the core faithfully jumping -4 — core correct, my word wrong.
Fixed word `fe314ee3` → `fe314ce3`, re-ran → PASS. This FAIL-then-PASS pair is
the proof the verdict machinery actually discriminates.
