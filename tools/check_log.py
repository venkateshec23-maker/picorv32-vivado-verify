"""check_log.py — verdict extractor for xsim transcripts (MY file).

Reads a simulator log, finds XSIM_RESULT markers emitted by the testbench,
prints the verdict, exits 0 on PASS / 1 otherwise (missing marker = FAIL).
Usage: check_log.py <sim_XXX.log>
"""

from __future__ import annotations

import re
import sys

MARKER = re.compile(r"XSIM_RESULT:\s*(PASS|FAIL)\s*(.*)")


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("usage: check_log.py <sim.log>")
        return 2
    try:
        text = open(argv[1], encoding="utf-8", errors="replace").read()
    except OSError:
        print(f"{argv[1]}: FAIL (log file missing — simulator never ran)")
        return 1
    verdicts = MARKER.findall(text)
    if not verdicts:
        print(f"{argv[1]}: FAIL (no XSIM_RESULT marker — sim never reached verdict)")
        return 1
    status, detail = verdicts[-1]
    print(f"{argv[1]}: {status} {detail}".rstrip())
    return 0 if status == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
