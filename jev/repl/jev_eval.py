# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
"""Jev evaluation model for the Read-Eval-Print loop.
Uses the non-regressive semantic engine for evidence spans
and the reduced GGUF as the evaluation artifact.
"""
import json, os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENGINE = os.path.join(ROOT, "engine", "nrse.pl")
GGUF = os.path.join(ROOT, "models", "jev.gguf")
MANIFEST = os.path.join(ROOT, "models", "jev.manifest.json")

def load_model():
    man = json.load(open(MANIFEST))
    size = os.path.getsize(GGUF)
    return {
        "name": "jev",
        "role": "evaluation",
        "gguf": GGUF,
        "bytes": size,
        "sha256": man.get("sha256"),
        "tensors": [t["name"] for t in man.get("tensors", [])],
        "operation": man.get("operation"),
    }

def evaluate(corpus_path, query):
    """Run NRSE locate. Returns span or [-1, -1]."""
    r = subprocess.run(
        ["perl", ENGINE, "locate", corpus_path, query],
        capture_output=True, text=True,
    )
    span = r.stdout.strip() or "[-1, -1]"
    ok = span != "[-1, -1]" and r.returncode == 0
    return {"ok": ok, "span": span, "query": query, "engine": "nrse"}

def audit(corpus_path):
    r = subprocess.run(
        ["perl", ENGINE, "audit", corpus_path],
        capture_output=True, text=True,
    )
    info = {}
    for line in r.stdout.splitlines():
        if "=" in line:
            k, v = line.split("=", 1)
            info[k] = v
    return info

if __name__ == "__main__":
    model = load_model()
    print(json.dumps({"model": model}))
    if len(sys.argv) >= 3 and sys.argv[1] == "eval":
        print(json.dumps(evaluate(sys.argv[2], sys.argv[3])))
