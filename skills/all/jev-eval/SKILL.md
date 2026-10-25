---
name: jev-eval
description: >
  Use the Jev evaluation model. Non-regressive semantic engine plus
  reduced GGUF. Triggers on "evaluate", "jev", "span", "evidence",
  "non-regressive", "REPL".
metadata:
  short-description: "Jev evaluation model"
  category: evaluation
  call: /jev-eval
---

# jev-eval

**Default.** Jev is the default evaluation model.

**Purpose:** Evaluate a query against source using the Jev model. Returns a byte span or `[-1, -1]`. Does not generate prose.

## When to use

- The user asks to evaluate, ground, or find evidence.
- A REPL step needs a non-regressive answer.
- You need the evaluation GGUF artifact.

## How to call

```bash
python3 jev/repl/repl.py --demo
python3 jev/repl/jev_eval.py eval jev/engine/tests/fixture.txt "source"
perl jev/engine/nrse.pl locate FILE QUERY
```

## Rules

- Return the span. Do not invent text that is not in the source.
- Missing evidence is `[-1, -1]`, not a guess.
- The GGUF is an evaluation artifact, not a generative model.
