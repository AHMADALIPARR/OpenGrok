# skills/all/

**Purpose:** Single directory containing every skill contract (`SKILL.md`) found in the repository.

Skills were located in three places and are now gathered here:

| Original location | Now under |
|-------------------|-----------|
| `skills/` | `skills/all/product/` |
| `.grok/skills/` | `skills/all/platform/` |
| `bots/skills/` | `skills/all/bots/` |

Original trees are left in place. This directory is the canonical index of skill contracts.

## Product skills (`skills/all/product/`)

| Skill | Purpose |
|-------|---------|
| cache-guard | Image / prompt-cache thrash prevention |
| codeart2d | Explicit code-drawn 2D art |
| generate2dmap | 2D maps, tilemaps, prop packs |
| generate2dmedia | Image / image-to-video art route |
| generate2dsprite | Game-ready 2D sprites |
| video2dsprite | Master still → animated sprite set |
| math-skills | Mathematical master skill set |
| personas/prehool | PreHool mathematician persona |

## Platform skills (`skills/all/platform/`)

auth, building-games, controls, design-ui, game-animation-frames, game-asset-core, game-character-consistency, game-tilesets, game-ui-icons, generate2dmap, generate2dsprite, imagine-grok-build, multiplayer-p2p, neon, og, threejs, video2dsprite, xai-api

## Bot skills (`skills/all/bots/`)

| Skill | Purpose |
|-------|---------|
| gguf-local | Local GGUF via microagent (no cloud fallback) |

## Layout

```
skills/all/
  product/     # product skill contracts
  platform/    # .grok/skills contracts
  bots/        # bots/skills contracts
```
