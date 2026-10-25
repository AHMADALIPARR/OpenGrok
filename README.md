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
- `emacs/` — Emacs packages and references
  - `emacs/vm/` — Emacs VM (View Mail)
  - `emacs/helm/` — Helm incremental completion framework
- `src/` — TypeScript / React app builder (TanStack Start)
- `.grok/` — Skills and references for the app builder
- `ksb-plus/` — K-language binary serialization (Layer 0 + Layer 1 tables)
- `ports/` — Ports of external systems (e.g. TermHive messaging)

## Emacs

| Package | Path | Upstream |
|---------|------|----------|
| VM (View Mail) | `emacs/vm/` | https://gitlab.com/emacs-vm/vm |
| Helm | `emacs/helm/` | https://github.com/emacs-helm/helm |

Install from ELPA: `M-x package-install RET vm RET` / `M-x package-install RET helm RET`

## Skills

Skill definitions are in `skills/`. See `skills/README.md`.

## Matrix Multiplication Engine

`native/cuda/matrix_mul.cu` is a complete tiled WMMA GEMM.

## MACROGROK Fixed-Point

- Assembly: `native/asm/infer4.asm`
- Dedicated package: `native/fixed_point/`
