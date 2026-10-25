# bots/

**Purpose:** Grok Bots that run against local GGUF models, using microagent for model serving and OGskill contracts for behavior.

Nothing here is required to build the app. It is the documented path for pointing a Grok Bot at a local GGUF instead of the xAI API.

## What lives here

| Path | Purpose |
|------|---------|
| `skills/gguf-local/SKILL.md` | OGskill contract: how a Grok Bot uses a local GGUF via microagent |
| `microagent.md` | How to pull, serve, and stop GGUF models with microagent |
| `example.env` | Environment variables for a local GGUF-backed bot |

## Quick path

1. Install microagent and llama.cpp (`llama-server`).
2. Pull and serve a GGUF:
   ```bash
   microagent model pull TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf
   microagent model serve TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf --runner-gpu auto
   ```
3. Point a Grok Bot at the local OpenAI-compatible endpoint the runner exposes.
4. Attach the `gguf-local` skill so the bot knows it is running against a local model.

See `microagent.md` for the full commands and `skills/gguf-local/SKILL.md` for the skill contract.

## Upstream

- microagent: https://github.com/geoffbelknap/microagent
- opgrok / OGskill style: https://github.com/DylanCkawalec/opgrok
