# Design decisions (changelog of *why*, not just *what*)

1. **Upstream as pinned submodule (`ef203c2`), zero edits.** Provenance is
   automatic; fork diff = exactly my files. Cost: reviewer runs
   `git submodule update --init`. Rejected alternative: copying `picorv32.v`
   in — loses provenance, invites accidental edits of a verified core.
2. **No-toolchain programs.** Removes the #1 setup failure mode (#267/#275
   class). Cost: hand-assembled words must be verified twice (done, and the
   tb caught my own blt error).
3. **Self-checking + markers + `tools/check_log.py`** instead of waveform
   review or `$fatal` (kept 2019.2-safe `$finish`; exit code from Python).
4. **Three runs via `$test$plusargs` flags**, not three testbenches — one tb
   to maintain. Plusarg quirk (`--testplusarg` without `+`) documented.
5. **M-free factorial + separate EXPECTED_TRAP demo** instead of enabling
   `ENABLE_MUL`: keeps default params (matches what a newcomer synthesizes)
   and turns #267's confusion into a diagnosed, asserted result.
6. **Stale logs deleted at flow start** (`del sim_*.log`): a previous run once
   masked a broken run as PASS. Never trust a verdict without a fresh log.
7. **TRACE block kept in tb**: transaction log is the debug evidence
   (it convicted my blt word, exonerated the core).
