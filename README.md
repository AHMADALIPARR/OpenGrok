# OpenGrok

Production repository for the OpenGrok app builder, native Tensor Core kernels, and MACROGROK fixed-point harness.

**Repository:** https://github.com/AHMADALIPARR/OpenGrok

**Where files belong:** see [docs/INDEX.md](docs/INDEX.md). Every section has a purpose label in its README.

## Layout

```
.
├── docs/               Section map and cross-cutting notes
├── src/                App builder (TanStack Start, React)
├── server/             Server entry and routes
├── native/             CUDA, Rust, assembly, fixed-point
├── skills/             Product skill contracts (SKILL.md)
├── emacs/              Emacs package notes (vm, helm)
├── ksb-plus/           K-language binary serialization
├── ports/              Ports of external systems
├── migrations/         Database migrations
├── scripts/            Build and maintenance scripts
├── public/             Static assets
├── archive/            Review material only
├── .grok/              App-builder agent skills and references
└── package.json        Node app
```

## Quick start

```bash
npm install
npm run dev          # http://localhost:8080
npm test
npm run typecheck
```

Set `XAI_API_KEY` (and optionally `XAI_MODEL`) for the `askGrok` server function in `src/lib/ai/`.

## Rules

- Topic markdown lives in its section, not in the repository root.
- Each section's README starts with a **Purpose** line.
- Skill contracts are `SKILL.md` inside `skills/<name>/`.
- KSB+ format docs stay in `ksb-plus/docs/`.
- Anything only for later review goes in `archive/`.
