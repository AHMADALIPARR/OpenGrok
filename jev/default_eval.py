# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Resolve the default evaluation model. Jev unless overridden."""
import json, os

CONFIG = os.path.join(os.path.dirname(__file__), "eval-default.json")

def default_eval_model():
    cfg = json.load(open(CONFIG))
    name = os.environ.get("EVAL_MODEL", cfg["default_evaluation_model"])
    return {
        "name": name,
        "artifact": os.environ.get("EVAL_GGUF", cfg["artifact"]),
        "engine": os.environ.get("EVAL_ENGINE", cfg["engine"]),
        "role": "evaluation",
    }

if __name__ == "__main__":
    print(json.dumps(default_eval_model()))
