# microagent for GGUF

**Purpose:** Notes for using microagent to pull and serve GGUF models that Grok Bots can call.

Upstream: https://github.com/geoffbelknap/microagent

## Install

```bash
brew install geoffbelknap/tap/microagent
# or from source
git clone https://github.com/geoffbelknap/microagent.git
cd microagent && make install
```

You also need `llama-server` (from llama.cpp) on PATH, or set `MICROAGENT_LLAMA_SERVER` to its absolute path.

## Pull a model

```bash
microagent model pull TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf
microagent model list
```

Blobs live under `~/.microagent/models/` by default.

## Serve it

```bash
# CPU
microagent model serve TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf

# GPU (auto)
microagent model serve TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf --runner-gpu auto

# Dedicated runner
microagent model serve TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf --dedicated --runner-gpu on
```

`serve` auto-pulls if the model is not yet stored and starts a pinned OpenAI-compatible server.

## Manage runners

```bash
microagent model runners
microagent model stop TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf
```

## Pair with a workspace

```bash
microagent create research --image docker.io/library/ubuntu:24.04 --model TheBloke/Llama-2-7B-GGUF/llama-2-7b.Q4_K_M.gguf
microagent start research
```

The guest reaches the model through a host service that keeps a stable address across runner restarts.

## Point a Grok Bot at it

Once a runner is up, the OpenAI-compatible base URL is what you set as the bot's model endpoint. Exact port is reported by `microagent model runners`. Example:

```bash
export OPENAI_BASE_URL=http://127.0.0.1:<port>/v1
export OPENAI_API_KEY=local
```

Then attach the `gguf-local` skill so the bot treats the endpoint as local and does not assume xAI-specific features.
