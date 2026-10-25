# OpenGrok

Production repository for the OpenGrok app builder, native Tensor Core kernels, and MACROGROK fixed-point harness.

**Repository:** https://github.com/AHMADALIPARR/OpenGrok

## Layout

```
.
├── src/                 App builder (TanStack Start, React)
├── server/              Server entry and routes
├── native/              Low-level code
│   ├── cuda/            Tensor Core kernels and WMMA GEMM
│   ├── rust/            Host code, FFI, AssemblySyscall layer
│   ├── asm/             MACROGROK pseudo-ISA
│   └── fixed_point/     Dedicated fixed-point package
├── skills/             Skill definitions (SKILL.md contracts)
├── emacs/              Emacs package notes (vm, helm)
├── ksb-plus/           K-language binary serialization (Layer 0 + Layer 1)
├── ports/              Ports of external systems
├── migrations/         Database migrations
├── scripts/            Build and maintenance scripts
├── public/             Static assets
├── archive/            Review material (nothing required to build)
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

## Native

See `native/README.md`.

- CUDA: `native/cuda/matrix_mul.cu` (tiled WMMA GEMM)
- Fixed-point: `native/fixed_point/` and `native/asm/infer4.asm`

## Skills and Emacs

- Skills: `skills/` (see `skills/README.md`)
- Emacs VM and Helm notes: `emacs/vm/`, `emacs/helm/`

## Review

Loose root stubs and past attachments are collected under `archive/` so the root stays clean. Nothing there is required to build. Go through `archive/root-stubs/` and keep or drop as you see fit.
