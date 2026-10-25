# OpenGrok Skills

Cherry-picked skill definitions from https://github.com/AHMADALIPARR/OpenGrok-Skills

## Skills

| Skill | Purpose |
|-------|---------|
| `codeart2d` | Explicit-only last-resort code-drawn 2D art (PixelSpec, SVG, rigs, FX, autotiles, layouts). |
| `generate2dmap` | Plan and build 2D maps, tilemaps, prop packs, parallax, HD-2D plates with collision and export. |
| `generate2dmedia` | Art-route layer: single command for image / image-to-video via API or local CLI. |
| `generate2dsprite` | Game-ready 2D characters, props, icons and FX as masters, sheets or clips. |
| `video2dsprite` | Turn one approved master still into a full animated sprite set via image-to-video. |

## Full source

The complete scripts, references, schemas, examples and shared libraries live in the source repository:

```
https://github.com/AHMADALIPARR/OpenGrok-Skills
```

To bring the full implementation into this repo, add it as a submodule:

```bash
git submodule add https://github.com/AHMADALIPARR/OpenGrok-Skills.git skills/OpenGrok-Skills
```

Or copy the `skills/` and `shared/` trees directly.

These skill definitions are the contracts; the source repo contains the executable pipelines.
