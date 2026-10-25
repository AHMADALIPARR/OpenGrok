---
name: gguf-local
description: >
  Use a local GGUF model served by microagent instead of the xAI API.
  Triggers when the bot is configured with an OpenAI-compatible base URL
  that points at a microagent model runner, or when the user asks for
  offline / local / GGUF inference.
metadata:
  short-description: "Local GGUF via microagent"
  category: bots
  tier: local
  call: /gguf-local
---

# gguf-local

**Purpose:** Tell a Grok Bot that it is talking to a local GGUF model served by microagent, not the xAI cloud API.

## When to use

- The environment has `OPENAI_BASE_URL` pointing at a microagent model runner.
- The user asks for local, offline, or GGUF inference.
- The bot is running inside a microagent workspace paired with `--model`.

## What to do

1. Confirm the runner is up:
   ```bash
   microagent model runners
   ```
2. Treat the endpoint as OpenAI-compatible. Do not assume xAI-only features (reasoning effort knobs, specific model slugs, etc.).
3. Prefer short, tool-friendly prompts. Local GGUFs vary widely in tool-calling quality.
4. If the runner is down, say so and stop. Do not silently fall back to a cloud API unless `XAI_API_KEY` is set and the user has asked for fallback.

## What not to do

- Do not invent model weights or claim a GGUF is loaded if `microagent model list` is empty.
- Do not send secrets to the local runner that you would not send to a local process.
- Do not assume the local model has the same context length or tool schema as Grok.

## Upstream

- microagent model commands: https://github.com/geoffbelknap/microagent
- OGskill style: https://github.com/DylanCkawalec/opgrok
