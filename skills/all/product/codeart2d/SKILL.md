---
name: codeart2d
description: Explicit-only last resort. Draws game art from code, with no image model - pixel sprites from a PixelSpec, flat vector props, UI and icons from portable SVG, rigged characters with planted feet, FX with a JS runtime, seam-proven autotiles, playable top-down layouts with collision, stylized parallax and ambient plate motion - palette-exact, with QA and review sheets. Use only when the user explicitly asks for code-drawn art, or when generate2dmedia route_media.py finds no image or video route (no-route, exit 3). Never the default - image generation (generate2dsprite, generate2dmap, video2dsprite) comes first for characters, props, maps and FX. Not for painterly, detailed or likeness art, HD-2D plates or realistic fire, smoke or water. Always disclose the result as code-drawn.
---

# Code Art 2D

Cherry-picked from https://github.com/AHMADALIPARR/OpenGrok-Skills

You write the art as text (PixelSpec JSON, portable SVG, rig, FX, material, layout or parallax
specs); the scripts render, check and package it. No image model is involved. It is a declared art
source (`art_source: "code"`), not a placeholder.

## Use when

- The user explicitly asks for code-drawn art: a PixelSpec or SVG sprite, palette variants drawn in code, a code rig, code FX, a seam-proven autotile set, a code-made layout, stylized parallax or ambient loops.
- `route_media.py` prints `no-route` (exit 3): no API key is configured and no local image or video route exists. Say so, and offer to add a key or a CLI as well.
- Pose and layout guides that help an image model (support material, not final art).

## Do not use when

- Any art request while an image or video route exists and the user did not ask for code art: [generate2dsprite](../generate2dsprite/SKILL.md), [generate2dmap](../generate2dmap/SKILL.md) or [video2dsprite](../video2dsprite/SKILL.md) generate it.
- Painterly, organic or identity-rich art, likenesses, portraits, HD-2D plates or textured terrain; realistic fire, smoke or water.
- Never trace licensed characters into specs.

Full scripts, references, schemas and examples live in the source repository:
https://github.com/AHMADALIPARR/OpenGrok-Skills/tree/main/skills/codeart2d

(This file is the skill definition. For the complete implementation, submodule or copy the source repo.)