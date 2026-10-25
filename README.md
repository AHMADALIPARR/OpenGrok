# OpenGrok

Native Tensor Core attention and MACROGROK harness with app builder workspace.

**Repository:** https://github.com/AHMADALIPARR/OpenGrok

## Structure

- `native/` — Low-level segments (see `native/README.md` for full breakdown)
  - `native/cuda/` — Tensor Core kernels, including the **full WMMA matrix multiplication engine**
  - `native/rust/` — Host code, AssemblySyscall layer, C FFI
  - `native/asm/` — MACROGROK pseudo-ISA
- `src/` — TypeScript / React app builder (TanStack Start)
- `.grok/` — Skills and references for the app builder
- `ksb-plus/` — Separate K-language binary serialization contract (Layer 0)

## Matrix Multiplication Engine

`native/cuda/matrix_mul.cu` is a complete tiled WMMA GEMM (FP16 in, FP32 accum, 16×16×16 tiles). It supports arbitrary M/N/K, alpha scaling, and cooperative shared-memory loads. Attention and future dense operators are built on top of this engine.

```bash
nvcc -arch=sm_80 -ptx native/cuda/matrix_mul.cu -o gemm.ptx
```

See `native/README.md` for what every segment does.

## MACROGROK Fixed-Point (INFER4)

- Assembly: `native/asm/infer4.asm`
- Rust + AssemblySyscall + C FFI: `native/rust/fixed_point.rs`

## App Builder

The TypeScript workspace follows the Grok app builder contract (see AGENTS.md).
