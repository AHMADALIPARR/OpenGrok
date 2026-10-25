---
name: cache-guard
description: Prevents prompt-cache thrash and runaway token burn in long or image-heavy agent sessions. Load BEFORE reading images/screenshots (visual QA, render checks, UI verification, diagram review) in a conversation that already has substantial history, when running long agentic loops with periodic wake-ups, or when the user asks why token usage / rate limits burn unusually fast. Teaches batched image reads, delegating vision work to isolated-context subagents, write-once notes instead of re-reading, and keeping large tool outputs out of context. Includes an audit script to measure a session's cache write/read ratio.
---

# Cache Guard — stop paying 700× overhead on context rewrites

Cherry-picked from https://github.com/0x0funky/claude-cache-guard (image / prompt-cache skill).

## The one mechanism to understand

Prompt cache is a **prefix match with three tiers: tools → system → messages**.
Reads from cache cost **0.1×** the base input price; writes cost **1.25×** — a
**12.5× spread**. A long conversation is *cheap* as long as every call re-reads
the cached prefix.

**Any image anywhere in the request invalidates the entire messages tier.**
The next call rewrites the whole conversation history at the 1.25× write price.
The rewrite cost equals the *current context size* — in an 800k-token session,
one glance at a screenshot costs ~800k cache-write tokens, even though the image
itself is ~1–2k tokens. Measured in production: 91% of a session's cost was
image-triggered rewrites; the images themselves were 0.13% of the tokens.

Other full-rewrite triggers: cache TTL expiry (>5 min idle, next wake rewrites
everything), model switch, tool-set / MCP change mid-session, editing earlier
history. Details and pricing math: `references/mechanism.md`.

## Rules

### R1 — Batch image reads into one message
Reading 1 image and reading 10 images cost the SAME rewrite. Never look at
screenshots one-by-one across turns. Accumulate paths, then read them all with
parallel Read calls in a single message, and draw every conclusion in that turn.

### R2 — Look once, write it down, never re-read
Immediately after viewing images, append findings to a notes file
(e.g. `qa-notes.md`): filename → verdict → required fix. From then on cite the
notes. Re-reading an image "to double-check" repeats the full-context rewrite.

### R3 — Delegate vision to a subagent (best option when context is large)
A subagent has its own small, isolated context. Images it reads rewrite ITS
few-k tokens, not your few-hundred-k, and its intermediate noise never enters
your history. Use the Task/Agent tool (`general-purpose` works) with:

```
View these images and reply in TEXT ONLY — never return image data:
- <path1> — check: <what "correct" means for this image, stated concretely —
  e.g. no clipped or overlapping elements, expected text/labels present,
  values match the data given below>
- <path2> — check: <criteria>
Reference material (text only, if the check needs it): <paste the relevant
requirements, expected values, or style rules here>
For each image: PASS/FAIL, one-line reason, exact fix needed if FAIL.
```

The subagent's eyes are the same model — verdict quality depends on how
concretely you state the criteria, so pass the "what does correct look like"
context as text. Main session receives a short text verdict; its cached prefix
stays intact. (Subagent calls may themselves skip caching — irrelevant: their
context is tiny.)

### R4 — If you must read inline, read early
Rewrite cost = context size at that moment. Front-load visual checks; don't
defer them to the end of a long session. If the session is already huge,
prefer R3 or a fresh session over inline reads.

### R5 — Keep bulk data out of context
- Verify renders/builds by **exit code, file size, or a grep'd summary** — not
  by dumping output into the conversation.
- Read only the lines you need (`offset`/`limit`); never cat a large file or
  paste base64.
- Write large intermediate results to files; pass paths, not contents.

### R6 — Session hygiene for long-running agents
- Work in continuous bursts. A giant session that idles >5 min pays a full
  rewrite on every wake — for periodic monitors, run each round as a fresh
  one-shot session (state on disk) instead of waking a huge conversation.
- Clear/restart at work-unit boundaries in image-heavy workflows; persistent
  state belongs in files, not in the transcript.
- Never switch model or add/remove tools (incl. MCP) mid-session — either one
  invalidates the whole cache.

## Decision table

| Situation | Do |
|---|---|
| Context small (<~50k), a few images, one-time check | Read inline, all in ONE message (R1), note results (R2) |
| Context large (>~150k) OR repeated visual checks | Delegate to subagent (R3) |
| Periodic loop with screenshots (monitor, render-watch) | Fresh one-shot session per round (R6) |
| Image already viewed earlier | Use notes; do NOT re-read (R2) |
| Need render/build verification | Exit code / file size / grep, no dumps (R5) |

## Verify it's working

`usage` on each API response tells the truth: healthy sessions show
`cache_read_input_tokens` ≫ `cache_creation_input_tokens` (aim ≥10:1; a
write:read ratio near 1:3 or worse means thrash). To audit past sessions from
transcripts:

```
node scripts/audit-session.mjs --hours 5          # rank recent sessions by burn
node scripts/audit-session.mjs --detail <sid8>    # per-call forensics for one session
```

Flags to look for in the output: `IMG-REWRITE` (image nuked the messages tier)
and `TTL-WAKE` (idle >5 min, whole context rewritten on wake).