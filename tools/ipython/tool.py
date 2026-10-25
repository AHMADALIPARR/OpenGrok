# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
"""IPython tool. Executes Python and returns JSON only.
Uses IPython when installed, otherwise a plain exec namespace.
Print output is captured into the result.
"""
import io, json, sys, traceback, contextlib

def run(code: str) -> dict:
    buf = io.StringIO()
    try:
        import IPython
        from IPython.core.interactiveshell import InteractiveShell
        shell = InteractiveShell.instance()
        with contextlib.redirect_stdout(buf):
            result = shell.run_cell(code)
        out = buf.getvalue()
        if result.result is not None:
            out += repr(result.result)
        err = "" if result.error_in_exec is None else str(result.error_in_exec)
        return {"ok": result.error_in_exec is None, "result": out, "error": err, "engine": "ipython"}
    except ImportError:
        ns = {}
        try:
            with contextlib.redirect_stdout(buf):
                exec(code, ns)
            out = buf.getvalue()
            if "_" in ns:
                out += repr(ns["_"])
            return {"ok": True, "result": out, "error": "", "engine": "exec"}
        except Exception:
            return {"ok": False, "result": buf.getvalue(), "error": traceback.format_exc(), "engine": "exec"}

if __name__ == "__main__":
    code = sys.stdin.read() if not sys.argv[1:] else " ".join(sys.argv[1:])
    json.dump(run(code), sys.stdout)
    sys.stdout.write("\n")
