---
name: generate2dmedia
description: The art-route layer of the Forge skills. route_media.py is the one command that generates an image or an image-to-video clip - through the paid API of any provider whose key is configured (OpenAI, Google Gemini, xAI, BytePlus ModelArk, fal.ai; the configured key is the owner's consent), else through the user's own signed-in Codex or Grok CLI - and prints one JSON line with the route, artifact, sha256 and cost estimate; with no route it answers no-route (codeart2d is then the last resort). Also the capability check (forge_doctor), API key configuration, the spend ledger, resume and Codex image adoption. Use when a Forge skill sends a generation here, for the capability check, or when the user asks about keys, routes or spend. Not for planning, processing or QA of sprites, video frames or maps (generate2dsprite, video2dsprite, generate2dmap) or for code-drawn art (codeart2d).
---

# Generate 2D Media

Cherry-picked from https://github.com/AHMADALIPARR/OpenGrok-Skills

The route layer. It makes raw media; the owning skill plans the asset before and checks it after.

## Use when

- Any Forge skill (or its pipeline script) needs a generated image, reference edit or image-to-video clip.
- Once per session, to see which routes work here (`forge_doctor.py`).
- The user asks to configure an API key, to use a particular route, or about spend.

## Do not use when

- Planning, keying, registering or packaging: [generate2dsprite](../generate2dsprite/SKILL.md), [video2dsprite](../video2dsprite/SKILL.md), [generate2dmap](../generate2dmap/SKILL.md).
- Code-drawn art the user asked for: [codeart2d](../codeart2d/SKILL.md).

Full scripts, references and schemas live in the source repository:
https://github.com/AHMADALIPARR/OpenGrok-Skills/tree/main/skills/generate2dmedia

(This file is the skill definition. For the complete implementation, submodule or copy the source repo.)