# jev/

**Purpose:** Semantic Jev GGUF and non-regressive engine as the evaluation model for the Read-Eval-Print loop.

## Layout

| Path | Purpose |
|------|---------|
| `engine/` | Non-regressive semantic engine (Perl/AWK). Returns byte spans, never free prose. |
| `tensor/` | Recursive tensor reduction → GGUF writer. |
| `models/jev.gguf` | Evaluation model artifact (reduced GGUF). |
| `models/jev.manifest.json` | SHA-256 manifest for the GGUF. |
| `repl/jev_eval.py` | Evaluation interface. |
| `repl/repl.py` | Read-Eval-Print loop. |

## Run

```bash
# Demo (non-interactive)
python3 jev/repl/repl.py --demo

# Engine directly
perl jev/engine/nrse.pl locate jev/engine/tests/fixture.txt "source"
perl jev/engine/nrse.pl audit jev/engine/tests/fixture.txt

# Interactive REPL
python3 jev/repl/repl.py
```

## Integration

Jev is the evaluation model. It does not generate answers. It returns `[start, end)` spans from source, or `[-1, -1]` when evidence is missing. The GGUF is the reduced tensor artifact produced by `tensor/scripts/reduce_to_gguf.py`. Point a Grok Bot at it the same way as other local GGUFs: the artifact lives at `jev/models/jev.gguf`.
