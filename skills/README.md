# OpenGrok Skills

Cherry-picked skill definitions from multiple sources.

## Skills

| Skill | Purpose | Source |
|-------|---------|--------|
| `codeart2d` | Explicit-only last-resort code-drawn 2D art (PixelSpec, SVG, rigs, FX, autotiles, layouts). | OpenGrok-Skills |
| `generate2dmap` | Plan and build 2D maps, tilemaps, prop packs, parallax, HD-2D plates with collision and export. | OpenGrok-Skills |
| `generate2dmedia` | Art-route layer: single command for image / image-to-video via API or local CLI. | OpenGrok-Skills |
| `generate2dsprite` | Game-ready 2D characters, props, icons and FX as masters, sheets or clips. | OpenGrok-Skills |
| `video2dsprite` | Turn one approved master still into a full animated sprite set via image-to-video. | OpenGrok-Skills |
| `cache-guard` | Image / prompt-cache thrash prevention. Batch image reads, delegate vision to subagents, write notes, keep bulk data out of context. Includes audit script. | [claude-cache-guard](https://github.com/0x0funky/claude-cache-guard) |

## Full source

The complete scripts, references, schemas and examples for the 2D skills live in:

```
https://github.com/AHMADALIPARR/OpenGrok-Skills
```

The cache-guard skill (including the audit script) is fully vendored under `skills/cache-guard/`.

To bring the full 2D implementations into this repo:

```bash
git submodule add https://github.com/AHMADALIPARR/OpenGrok-Skills.git skills/OpenGrok-Skills
```
