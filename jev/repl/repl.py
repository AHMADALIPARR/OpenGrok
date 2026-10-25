# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
"""Read-Eval-Print loop. Evaluation model is Jev (NRSE + GGUF)."""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jev_eval

def main():
    model = jev_eval.load_model()
    print(f"jev REPL  model={model['name']}  tensors={model['tensors']}  bytes={model['bytes']}")
    print("commands: eval <file> <query> | audit <file> | model | quit")
    corpus = os.environ.get("JEV_CORPUS", "")
    while True:
        try:
            line = input("jev> ").strip()
        except EOFError:
            break
        if not line:
            continue
        if line in ("quit", "exit"):
            break
        if line == "model":
            print(json.dumps(model))
            continue
        parts = line.split(maxsplit=2)
        cmd = parts[0]
        if cmd == "eval" and len(parts) == 3:
            print(json.dumps(jev_eval.evaluate(parts[1], parts[2])))
        elif cmd == "audit" and len(parts) == 2:
            print(json.dumps(jev_eval.audit(parts[1])))
        elif cmd == "eval" and len(parts) == 2 and corpus:
            print(json.dumps(jev_eval.evaluate(corpus, parts[1])))
        else:
            print("usage: eval <file> <query> | audit <file> | model | quit")

if __name__ == "__main__":
    # Non-interactive demo path
    if len(sys.argv) > 1 and sys.argv[1] == "--demo":
        model = jev_eval.load_model()
        print("=== Jev evaluation model ===")
        print(json.dumps(model, indent=2))
        fixture = os.path.join(os.path.dirname(__file__), "..", "engine", "tests", "fixture.txt")
        print("=== eval ===")
        print(json.dumps(jev_eval.evaluate(fixture, "balance")))
        print("=== audit ===")
        print(json.dumps(jev_eval.audit(fixture)))
        print("=== done ===")
    else:
        main()
