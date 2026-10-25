# OpenGrok

Native Tensor Core attention and MACROGROK harness with app builder workspace.

**Repository:** https://github.com/AHMADALIPARR/OpenGrok

## Structure

- `native/cuda/` — CUDA kernels (Tensor Core attention, TMA)
- `native/rust/` — Rust host code (attention, memory, transformer, fixed-point)
- `src/` — TypeScript / React app builder (TanStack Start)
- `.grok/` — Skills and references for the app builder
- `ksb-plus/` — Related subsystem

## CUDA Kernel

The Tensor Core attention kernel (`native/cuda/tensor_core_attention.cu`) implements WMMA 16x16x16 QK^T + softmax + PV for FP16/FP32, with head_dim tiling and causal support. Extended with online softmax skeleton and PV stage.

Compile example:
```
nvcc -arch=sm_80 -ptx native/cuda/tensor_core_attention.cu -o attention.ptx
```

## Rust Harness

See `native/rust/` for the cudarc-based host that launches the kernels and manages KV cache.

## App Builder

The TypeScript workspace follows the Grok app builder contract (see AGENTS.md).
