# OpenGrok

Native Tensor Core attention and MACROGROK harness with app builder workspace.

**Repository:** https://github.com/AHMADALIPARR/OpenGrok

## Structure

- `native/` — Low-level segments (see `native/README.md`)
  - `native/cuda/` — Tensor Core kernels, including the full WMMA matrix multiplication engine
  - `native/rust/` — Host code, AssemblySyscall layer, C FFI
  - `native/asm/` — MACROGROK pseudo-ISA
  - `native/fixed_point/` — Dedicated fixed-point engine package
- `skills/` — Cherry-picked skill definitions (see `skills/README.md`)
- `emacs/vm/` — Emacs VM (View Mail) reference for GNU Emacs
- `src/` — TypeScript / React app builder (TanStack Start)
- `.grok/` — Skills and references for the app builder
- `ksb-plus/` — K-language binary serialization (Layer 0 + Layer 1 tables)
- `ports/` — Ports of external systems (e.g. TermHive messaging)

## Emacs VM

`emacs/vm/` holds the reference and example configuration for the Emacs mail reader VM (View Mail). Upstream: https://gitlab.com/emacs-vm/vm

Install from NonGNU ELPA: `M-x package-install RET vm RET`

## Skills

Skill definitions are in `skills/`. See `skills/README.md`.

## Matrix Multiplication Engine

`native/cuda/matrix_mul.cu` is a complete tiled WMMA GEMM.

## MACROGROK Fixed-Point

- Assembly: `native/asm/infer4.asm`
- Dedicated package: `native/fixed_point/`
