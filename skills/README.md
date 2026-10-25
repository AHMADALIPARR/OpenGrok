# skills/

**Purpose:** Skill contracts that ship with the product. Each skill is a folder containing a `SKILL.md` that defines the contract.

Agent-only skills used by the app builder live in `.grok/skills/`, not here.

## Skills

| Skill | Purpose | Source |
|-------|---------|--------|
| `codeart2d` | Explicit-only last-resort code-drawn 2D art (PixelSpec, SVG, rigs, FX, autotiles, layouts). | OpenGrok-Skills |
| `generate2dmap` | Plan and build 2D maps, tilemaps, prop packs, parallax, HD-2D plates with collision and export. | OpenGrok-Skills |
| `generate2dmedia` | Art-route layer: single command for image / image-to-video via API or local CLI. | OpenGrok-Skills |
| `generate2dsprite` | Game-ready 2D characters, props, icons and FX as masters, sheets or clips. | OpenGrok-Skills |
| `video2dsprite` | Turn one approved master still into a full animated sprite set via image-to-video. | OpenGrok-Skills |
| `cache-guard` | Image / prompt-cache thrash prevention. Batch image reads, delegate vision to subagents, write notes, keep bulk data out of context. Includes audit script. | [claude-cache-guard](https://github.com/0x0funky/claude-cache-guard) |
| `math-skills` | Mathematical master skill set. Six layers: enumeration, isomorphism, symmetry breaking, Hadamard, probabilistic method, circuit complexity. | [math-skills](https://github.com/SNAPKITTYWEST/math-skills) |
| `personas/prehool` | Master Persona — PreHool, the Grok Mathematician. | Local |

## Personas

- **PreHool** (`skills/personas/prehool/`) — Grok Mathematician. Motto: "Finite methods first. Conjectures stay labeled."

## Sources

- 2D skills: https://github.com/AHMADALIPARR/OpenGrok-Skills
- cache-guard: vendored under `skills/cache-guard/`
- math-skills: under `skills/math-skills/`
- PreHool: under `skills/personas/prehool/`

## Unified directory

All skill contracts are also gathered under `skills/all/` (see `skills/all/README.md`). Original locations remain unchanged.
