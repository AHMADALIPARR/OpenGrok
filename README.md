# OpenGrok

OpenGrok is a production repository that combines an app builder, native Tensor Core kernels, a fixed-point inference engine, and skill contracts under one tree.

**Repository:** https://github.com/AHMADALIPARR/OpenGrok  
**License:** GNU Affero General Public License v3.0 ([LICENSE](LICENSE))  
**Where files belong:** [docs/INDEX.md](docs/INDEX.md)

## What is in this repository

| Section | What it contains |
|---------|------------------|
| `src/` | App builder UI and libraries (TanStack Start, React). Includes auth, app data, and the `askGrok` server function. |
| `server/` | Server entry and server-only routes. |
| `native/` | Low-level code: CUDA Tensor Core GEMM and attention, Rust host and FFI, MACROGROK assembly, fixed-point engine. |
| `skills/` | Product skill contracts. Each skill is a folder with a `SKILL.md`. |
| `emacs/` | Notes and starter configs for Emacs VM and Helm. |
| `ksb-plus/` | K-language binary serialization (Layer 0 envelope and Layer 1 columnar tables). |
| `ports/` | Ports of external systems (for example TermHive messaging). |
| `migrations/` | Database migrations applied by `npm run db:migrate`. |
| `scripts/` | Build, migrate, preview, and maintenance scripts. |
| `public/` | Static assets. |
| `.grok/` | Skills and references used by the app-builder agent. |
| `docs/` | Section map and cross-cutting notes. |
| `archive/` | Review material only. Nothing here is required to build. |

## Quick start

```bash
npm install
npm run dev          # http://localhost:8080
npm test
npm run typecheck
```

Set `XAI_API_KEY` (and optionally `XAI_MODEL`) for the `askGrok` server function in `src/lib/ai/`.

## License and headers

This project is licensed under the GNU Affero General Public License v3.0. See [LICENSE](LICENSE).

Source files carry a short header pointing at that license:

```
Copyright (C) 2026 AHMAD ALI PARR

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

See the GNU Affero General Public License for more details.
You should have received a copy of the license along with this program.
If not, see <https://www.gnu.org/licenses/>.
```

## Rules

- Topic markdown lives in its section, not in the repository root.
- Each section's README starts with a **Purpose** line.
- Skill contracts are `SKILL.md` inside `skills/<name>/`.
- KSB+ format docs stay in `ksb-plus/docs/`.
- Anything only for later review goes in `archive/`.
