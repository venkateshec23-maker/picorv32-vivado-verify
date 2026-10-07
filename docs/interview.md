# Interview prep (P1)

## 2-minute explanation
"Upstream PicoRV32 is formally verified but had no Vivado simulation path —
a student literally couldn't run a factorial program in xsim. I built a
one-command, self-checking Vivado flow in an attributed fork: a no-toolchain
testbench running three programs — a summation loop, 5-computed-without-a-
multiplier, and a program proving mul traps by default. All pass, exit code
zero, logs checked in. Along the way my own branch instruction was mis-encoded
and the testbench caught it — the trace showed the core jumping exactly the
wrong offset I'd encoded, which exonerated the RTL and convicted my test.
I also documented four Vivado 2019.2 quirks nobody had written down."

## 10 questions (all answerable from this repo)
1. Why a fork/submodule model instead of editing upstream? (archived upstream)
2. Why didn't you modify picorv32.v? (verified core; restraint + value is access)
3. Why no RISC-V toolchain in the flow? (removes #1 newcomer failure)
4. How does the testbench deliver a verdict without waveform review?
5. What proved your checker isn't tautological? (the blt FAIL run)
6. Explain the -4 vs -8 branch bug from first principles. (double-halved immediate)
7. Why did all three runs print "PASS sum", and what was the real cause?
   (racing initial blocks — not the tool)
8. Why does `mul` trap with default parameters? (ENABLE_MUL=0, PCPI unconnected)
9. Why is `--testplusarg` passed without `+`? (2019.2 quirk, found by experiment)
10. What would you add next, and what would it cost? (AXI variant / Spike
    differential / board run — each scoped in limitations.md)
