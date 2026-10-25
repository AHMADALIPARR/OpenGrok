---
name: generate2dmap
description: Plan and build 2D game maps and scenes - top-down and side-scrolling levels, tilemaps, prop packs, parallax backgrounds and HD-2D battle or story plates - with collision, navigation and reachability checks, environment motion, a playable HTML preview and export to Tiled, Godot 4 or LDtk. Map art (terrain, tiles, props, plates, parallax layers) is image generation by default, through generate2dmedia route_media.py (the API when a key is configured, else the local Codex or Grok CLI); map data (layout, collision, exits, spawns) is written as data. Use for any map, level, room, scene, background, terrain or prop-kit request. Not for characters, creatures, items or FX (generate2dsprite), character animation (video2dsprite), code-drawn tiles or maps (codeart2d, only on request) or calling an image or video API by itself (generate2dmedia).
---

# Generate 2D Map

Cherry-picked from https://github.com/AHMADALIPARR/OpenGrok-Skills

Build the smallest scene bundle the request needs, in the game's art, camera, renderer and data conventions.
A background picture needs no game system; a playable map needs explicit geometry and data beyond a painting.

## Use when

- A playable map, level, room set, tilemap, terrain or prop kit, with collision and exits.
- A parallax background, a battle, title or story backdrop, or an HD-2D plate with lights and motion.
- Map data must be validated, previewed or exported to Tiled, Godot or LDtk.

## Do not use when

- Actors, items and attack FX: [generate2dsprite](../generate2dsprite/SKILL.md). Character motion from video: [video2dsprite](../video2dsprite/SKILL.md).
- Code-drawn tiles, layouts or parallax the user asked for: [codeart2d](../codeart2d/SKILL.md). Only an API or CLI call: [generate2dmedia](../generate2dmedia/SKILL.md).

Full scripts, references and schemas live in the source repository:
https://github.com/AHMADALIPARR/OpenGrok-Skills/tree/main/skills/generate2dmap

(This file is the skill definition. For the complete implementation, submodule or copy the source repo.)