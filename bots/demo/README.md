# bots/demo

**Purpose:** End-to-end local GGUF workflow for Grok Bots.

<div align="center">

## Benchmark

**136 turns/sec**

| Turns | Total | Avg latency | Tokens | Requests |
|------:|------:|------------:|-------:|---------:|
| 20 | 146 ms | 5 ms | 334 | 23 |

Model: `llama-2-7b.Q4_K_M.gguf` · Endpoint: `http://127.0.0.1:8080/v1` · No cloud fallback

</div>

## Full demo

```
=== 1. Handshake ===
base: http://127.0.0.1:8080/v1
PASS: local models endpoint responded
models: ['llama-2-7b.Q4_K_M.gguf']
PASS: local handshake complete (no cloud fallback)

=== 2. Demo turns ===
Q: ping
A: local-gguf: received 1 tokens. echo="ping"  (9 ms)
Q: what is 2+2
A: local-gguf: received 3 tokens. echo="what is 2+2"  (9 ms)
Q: summarize: grok bots local gguf
A: local-gguf: received 8 tokens. echo="summarize: grok bots local gguf"  (11 ms)

=== 3. Benchmark (20 turns) ===
20 turns in 146 ms  (~136 turns/sec)

=== 4. Server stats ===
requests: 23 · totalTokens: 334 · avgMs: 5 · model: llama-2-7b.Q4_K_M.gguf

=== DONE ===
```

## Run

```bash
node bots/demo/server.mjs &
OPENAI_BASE_URL=http://127.0.0.1:8080/v1 bash bots/demo/run.sh
OPENAI_BASE_URL=http://127.0.0.1:8080/v1 bash bots/repl.sh
```

## Real GGUF

Replace the stand-in with `llama-server` or `microagent model serve`. The bots contract is the same: local base URL, no cloud fallback.
