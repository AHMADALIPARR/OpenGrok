# bots/demo

**Purpose:** End-to-end local GGUF workflow for Grok Bots.

`server.mjs` is an OpenAI-compatible stand-in for `llama-server`. It serves `/v1/models` and `/v1/chat/completions` and records request stats. Use it when `llama-server` is not available; swap the base URL for a real runner when you have one.

## Run

```bash
node bots/demo/server.mjs &
OPENAI_BASE_URL=http://127.0.0.1:8080/v1 bash bots/demo/run.sh
OPENAI_BASE_URL=http://127.0.0.1:8080/v1 bash bots/repl.sh
```

## Real GGUF

Replace the stand-in with `llama-server` or `microagent model serve`. The bots contract is the same: local base URL, no cloud fallback.
