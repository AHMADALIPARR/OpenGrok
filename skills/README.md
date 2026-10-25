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
| `math-skills` | Mathematical master skill set. Six layers: enumeration, isomorphism, symmetry breaking, Hadamard, probabilistic method, circuit complexity. Fortran + APL + AXIOM. WORM-sealed. | [math-skills](https://github.com/SNAPKITTYWEST/math-skills) |

## Full source

- 2D skills: https://github.com/AHMADALIPARR/OpenGrok-Skills
- cache-guard: fully vendored under `skills/cache-guard/`
- math-skills: definitions + design doc + master seal under `skills/math-skills/`; full Fortran/APL/AXIOM implementations in the source repo

To bring full implementations:

```bash
git submodule add https://github.com/AHMADALIPARR/OpenGrok-Skills.git skills/OpenGrok-Skills
git submodule add https://github.com/SNAPKITTYWEST/math-skills.git skills/math-skills-src
```
