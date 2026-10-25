---
name: generate2dsprite
description: Make game-ready 2D characters, creatures, props, icons and FX as master stills, sprite sheets or animation clips. Plan size, motion and finish; generate the art (image generation is the default, through generate2dmedia route_media.py - the API when a key is configured, else the local Codex or Grok CLI); approve one master still per character; then key, slice, register, scale, palette, QA and export frames for a game engine (Aseprite JSON, Godot SpriteFrames or Sprite3D). HD finish by default, pixel finish on request. Character animation is one image-to-video clip per action from the master (video2dsprite); sheets are for FX, icons and props. Use for sprites, masters, sheets, frame-by-frame animation and packaging frames from any source. Not for maps, tiles or backgrounds (generate2dmap), video clips (video2dsprite), code-drawn art (codeart2d, only on request) or calling an image or video API by itself (generate2dmedia).
---

# Generate 2D Sprite

Cherry-picked from https://github.com/AHMADALIPARR/OpenGrok-Skills

Make the smallest asset bundle the game needs, at its real display size, camera and style.
Game logic (collision, damage, timing) stays independent of the art.

## Use when

- A character, creature, prop, item, icon or FX is needed as a master still, a sheet or clips.
- Frames already exist (generated, painted, code-drawn) and need clips, palettes or an engine export.

## Do not use when

- Maps, tiles, terrain, parallax or scene plates: [generate2dmap](../generate2dmap/SKILL.md).
- Animating a character: approve one master here, then [video2dsprite](../video2dsprite/SKILL.md) makes one clip per action ([video-handoff.md](references/video-handoff.md)).
- Code-drawn art the user asked for: [codeart2d](../codeart2d/SKILL.md). Only an API or CLI call: [generate2dmedia](../generate2dmedia/SKILL.md).

Full scripts, references and schemas live in the source repository:
https://github.com/AHMADALIPARR/OpenGrok-Skills/tree/main/skills/generate2dsprite

(This file is the skill definition. For the complete implementation, submodule or copy the source repo.)