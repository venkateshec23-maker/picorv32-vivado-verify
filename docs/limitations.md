# Limitations (P1 — honest scope boundary)

- Simulation only; **no hardware test** (no FPGA board available).
- Vivado 2019.2 on Windows 10 only. Other versions/OSes untested.
- Covers the native-memory `picorv32` variant; AXI4-Lite/Wishbone variants
  (`testbench_wb.v` path) not exercised.
- Three hand-written programs; no randomized/differential testing vs Spike
  (upstream issue #283 shows why that matters — future work).
- Upstream open issues #279/#278/#280/#283 intentionally untouched in P1.
- `mem_la_*` look-ahead ports left unconnected (documented, single-cycle
  memory model doesn't need them).
