# Mechanism — why one image can cost 800k tokens

Cherry-picked from https://github.com/0x0funky/claude-cache-guard

## Cache tiers and the invalidation hierarchy

The prompt cache is a byte-exact **prefix** match over the rendered request,
in render order `tools → system → messages`. Invalidation cascades downward:

| Change | Tools tier | System tier | Messages tier |
|---|:---:|:---:|:---:|
| Tool definitions added/removed/reordered (incl. MCP) | ❌ | ❌ | ❌ |
| Model switch | ❌ | ❌ | ❌ |
| System prompt content change | ✅ kept | ❌ | ❌ |
| `tool_choice` change, **image presence/absence**, thinking toggle | ✅ | ✅ | ❌ |
| Message content edit | ✅ | ✅ | ❌ |

(Source: Anthropic prompt-caching docs — "changes to `tool_choice` or the
presence/absence of **images** anywhere in the prompt will invalidate the
cache".)

The signature in usage data: a call whose `cache_read_input_tokens` collapses
to roughly the size of tools+system (a few tens of k) while
`cache_creation_input_tokens` jumps to the size of the whole conversation —
the messages tier was rebuilt from scratch.

## Pricing

Per million tokens, relative to base input price `P`:

| Token class | Price | Example (Opus-tier, P=$5) | Example (top-tier, P=$10) |
|---|---|---|---|
| Cache read | 0.1 × P | $0.50 | $1.00 |
| Uncached input | 1 × P | $5 | $10 |
| Cache write (5-min TTL) | 1.25 × P | $6.25 | $12.50 |
| Output | 5 × P | $25 | $50 |

The read↔write spread is **12.5×**. Everything in this skill follows from that
number.

## Worked example (real production session)

A 90-minute video-production session on a top-tier model, ~700–800k context,
83 API calls, 40 screenshots read one-at-a-time across 22 separate turns:

- Every image-carrying call: `cacheR` collapsed to 32k (tools+system),
  `cacheW` = 700–800k — a full messages-tier rewrite. 22 rewrites.
- Total cache writes 18.0M tokens = **$225 of $277 total (81%)**.
- The 40 images themselves: ~23k tokens (~0.13% of tokens paid for).
  Overhead ≈ **700× the content being looked at**.
- Four images were re-read "to double-check": ~$37 of pure waste.

A follow-up session doing comparable work with the rules applied (batched
reads, notes, delegation — 1 image inline, rest via subagent, fresh context):

- write:read ratio 1:2.5 → **1:22**; cache writes 18.0M → 0.74M (**−96%**)
- cache writes as share of spend: 81% → 27%
- **$276.80 → $33.65 (−88%)** while producing **~18% more output tokens**
  (139k → 164k) — ≈10× more token-efficient per unit of output. Same model,
  same image resolution.
- Caveat: a real-workload before/after on the same project and day, not a
  variable-controlled A/B; the "after" also benefits from starting with a
  fresh context, which is itself rule R6.

## Why subagents work

A subagent (Claude Code Task tool, or any separate small session) starts its
own context: a few k of instructions + the images. The rewrite its images
trigger applies to *its* tiny context. It returns a text verdict; the parent
appends a few hundred tokens and its own cached prefix remains valid.

Known caveat: some harnesses disable prompt caching entirely inside subagents
(e.g. Claude Code issue #29966, `enablePromptCaching: false`). This does not
matter for the pattern — the subagent's total context is small enough that
paying full price on it is still orders of magnitude cheaper than rewriting
the parent's history.

## TTL economics for long-lived agents

Default cache TTL is 5 minutes (1-hour TTL exists at 2× write price). A
persistent session that wakes every N minutes with N > TTL pays a full-context
write on the first call of every wake. For a 600k-token monitor waking 3×/hour
that is ~2.25M cache-write tokens/hour before any real work. Alternatives:

1. Fresh one-shot run per round (`claude -p` style), state persisted to files
   — context stays at tens of k forever.
2. Batch rounds into continuous bursts inside the TTL window.
3. If neither fits, at least keep the persistent session's context small
   (R5: no dumps, no images inline).

## Additional cache-killers seen in the wild

- **Auto-compaction** rewrites history → full re-cache (unavoidable, but a
  reason to keep transcripts lean so it triggers rarely).
- **>20 content blocks in one turn** (tool-heavy loops): each breakpoint only
  looks back 20 blocks to find the previous cache entry; a 60-tool turn can
  orphan the prefix. Split mega-turns.
- **Parallel first calls**: cache becomes readable only after the first
  response starts streaming; N simultaneous cold calls all pay full price.
- **Anything non-deterministic in the prefix**: timestamps, UUIDs, unsorted
  JSON in system prompts or early messages.
