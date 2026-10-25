# OpenGrok

Native Tensor Core attention and MACROGROK harness with app builder workspace.

**Repository:** https://github.com/AHMADALIPARR/OpenGrok

## Structure

- `native/cuda/` — CUDA kernels (Tensor Core attention, TMA)
- `native/rust/` — Rust host code (attention, memory, transformer, fixed-point + FFI)
- `native/asm/` — MACROGROK pseudo-ISA assembly (INFER4)
- `src/` — TypeScript / React app builder (TanStack Start)
- `.grok/` — Skills and references for the app builder
- `ksb-plus/` — Related subsystem

## CUDA Kernel

The Tensor Core attention kernel (`native/cuda/tensor_core_attention.cu`) implements WMMA 16x16x16 QK^T + softmax + PV for FP16/FP32, with head_dim tiling and causal support. Extended with online softmax skeleton and PV stage.

Compile example:
```
nvcc -arch=sm_80 -ptx native/cuda/tensor_core_attention.cu -o attention.ptx
```

## MACROGROK Fixed-Point (INFER4)

Assembly source: `native/asm/infer4.asm`  
Rust implementation with Assembly Syscall Layer + C FFI: `native/rust/fixed_point.rs`

The Rust port matches the Python simulator and assembly semantics (Q1.14 / Q3.12, 3/4 low-pass STATE, saturation flags).  
FFI entry point:
```c
int macrogrok_infer4(i16 i0, i16 i1, i16 i2, i16 i3,
                     i16 *out_state, i32 *out_score, u16 *out_flags);
```

## Rust Harness

See `native/rust/` for the cudarc-based host that launches the kernels and manages KV cache, plus the fixed-point syscall layer.

## App Builder

The TypeScript workspace follows the Grok app builder contract (see AGENTS.md).
