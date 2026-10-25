# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Tool-call dispatcher. Routes a call to ipython or bash."""
import json, subprocess, sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def call(name: str, arg: str) -> dict:
    if name == "ipython":
        r = subprocess.run([sys.executable, os.path.join(ROOT, "ipython", "tool.py"), arg],
                           capture_output=True, text=True)
        try:
            return json.loads(r.stdout)
        except Exception:
            return {"ok": False, "error": r.stderr or r.stdout}
    if name == "bash":
        r = subprocess.run(["bash", os.path.join(ROOT, "bash", "tool.sh"), arg],
                           capture_output=True, text=True)
        try:
            return json.loads(r.stdout)
        except Exception:
            return {"ok": False, "error": r.stderr or r.stdout}
    return {"ok": False, "error": f"unknown tool: {name}"}

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage: dispatch.py <ipython|bash> <arg>")
        sys.exit(2)
    print(json.dumps(call(sys.argv[1], sys.argv[2])))
