# P1 Architecture — picorv32-vivado-verify

## Layout
```
picorv32-vivado-verify/
├── upstream/            # git submodule, pinned commit of YosysHQ/picorv32 (READ-ONLY, never edited)
├── tb/
│   └── tb_picorv32_xsim.v   # MY testbench: self-checking, no-toolchain programs
├── sim/vivado-xsim/
│   ├── run_xsim.tcl    # MY flow script: xvlog → xelab → xsim → pass/fail
│   └── run_xsim.bat    # MY one-command entry point (sets writable workdir)
├── rtl/                # reserved: only MY additions (P1: empty by design)
├── tools/              # MY log-check helper (Python, parses xsim log → PASS/FAIL)
├── reports/            # generated sim logs + utilization n/a (sim-only P1)
└── docs/               # requirements/architecture/decisions/testing/results
```

## Data flow
```
run_xsim.bat → xvlog(tb + upstream/picorv32.v) → xelab → xsim (batch)
   → transcript.log → tools/check_log.py → PASS/FAIL + exit code
```

## Interfaces
- DUT: `picorv32` module, standard clk/reset + native memory interface, driven
  by the testbench's synchronous SRAM model (mirrors `testbench_ez.v` style).
- Testbench ↔ checker: `$display("FACTORIAL_PASS x2=%0d", x2)` style markers;
  `$fatal` on mismatch so failure is a nonzero exit, not a silent wave.
- Program loading: hardcoded 32-bit instruction words in testbench `initial`
  block (same technique as upstream `testbench_ez.v`, new programs).

## Key design decisions (full log in design-decisions.md)
1. **Submodule, not copy, for upstream** — provenance is automatic; fork diff =
   exactly my files. Tradeoff: reviewer needs `git submodule update --init`.
2. **No-toolchain programs** — removes the #1 setup failure (#267, #275 class).
3. **Self-checking, not waveform** — a test that can't fail is not a test
   (criterion 3: negative control with wrong expectation must FAIL).
4. **Batch TCL, not GUI project** — reproducible, version-controllable, CI-able.
5. **Do not touch picorv32.v** — the core is formally verified; P1 value is
   access + verification evidence, not core edits.
