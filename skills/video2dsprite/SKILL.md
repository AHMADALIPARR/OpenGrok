---
name: video2dsprite
description: Turn one approved master still into a character's whole animated sprite set - one image-to-video clip per action (idle, walk, run, attack, jump, hurt, cast and so on), all from that still, generated through generate2dmedia route_media.py (the xAI API when a key is configured, else the local Grok CLI) - then gate each take, key it with a soft matte, register it to the master, pick loops or retime actions, finish (HD by default, pixel on request) and package fixed-canvas frames, alpha WebM, packed MP4 for iPhone and a PNG fallback with engine metadata and a JS runtime. Also processes a supplied clip. Use for character and creature animation, fluid motion and any video-to-sprite work. Not for FX, icon or prop sheets (generate2dsprite), maps or plate loops (generate2dmap), code-drawn animation (codeart2d, only on request) or calling a video API by itself (generate2dmedia).
---

# Video to 2D Animation

Cherry-picked from https://github.com/AHMADALIPARR/OpenGrok-Skills

An approved still sets identity and geometry, a video model supplies motion, and deterministic
tools prepare it for the engine. Video is not promised to be smaller, seamless or cheaper than sheets.

## Use when

- Animating a character or creature: every action comes from one approved master still, one clip per action.
- Fluid motion from an accepted master: idle breathing, walks, runs, attacks, casts, hair, capes, creatures.
- A supplied clip must become transparent, registered, looped frames and engine video.

## Do not use when

- FX, icon or prop sheets: [generate2dsprite](../generate2dsprite/SKILL.md).
- Water, fire or mist inside a still scene plate: [generate2dmap](../generate2dmap/SKILL.md). Only an API or CLI call: [generate2dmedia](../generate2dmedia/SKILL.md).
- Code-drawn animation the user asked for: [codeart2d](../codeart2d/SKILL.md).

Full scripts, references and schemas live in the source repository:
https://github.com/AHMADALIPARR/OpenGrok-Skills/tree/main/skills/video2dsprite

(This file is the skill definition. For the complete implementation, submodule or copy the source repo.)
