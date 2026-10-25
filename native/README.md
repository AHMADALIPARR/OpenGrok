# Native Segments

Organized low-level components for OpenGrok.

## Directory Layout

```
native/
├── asm/                 # MACROGROK pseudo-ISA
│   └── infer4.asm        # Fixed-point 4-input decision (Q1.14 / Q3.12)
├── cuda/                # CUDA kernels (Tensor Core)
│   ├── matrix_mul.cu      # Full WMMA GEMM engine (A*B -> C, FP16/FP32)
│   ├── tensor_core_attention.cu  # Attention built on GEMM tiles + online softmax
│   └── tma.ptx            # Hopper TMA bulk-copy snippet
└── rust/                # Host-side Rust (cudarc + FFI)
    ├── lib.rs             # Crate root, re-exports
    ├── fixed_point.rs     # INFER4 + AssemblySyscall layer + C FFI
    ├── attention.rs        # TensorCoreAttention wrapper
    ├── memory.rs          # KV cache
    ├── transformer.rs     # Block skeleton
    ├── tavily.rs          # Search client
    └── main.rs            # Demo harness
```

## What Each Segment Does

| Segment | Purpose |
|---------|---------|
| `asm/infer4.asm` | Reference pseudo-ISA for the fixed-point binary decision. Defines memory map, macros (DOT4, SAT, THRESHOLD, 3/4 low-pass). |
| `cuda/matrix_mul.cu` | **Full matrix multiplication engine.** Tiled WMMA 16×16×16 GEMM. Supports arbitrary M/N/K, alpha scaling, cooperative shared-memory loads. Host launcher exposed as `launch_wmma_gemm`. |
| `cuda/tensor_core_attention.cu` | Attention built on the same WMMA tiles: QKᵀ reduction, online softmax, PV. Uses the GEMM primitives. |
| `cuda/tma.ptx` | Example of Hopper Tensor Memory Accelerator bulk tensor copy with mbarrier. |
| `rust/fixed_point.rs` | Rust port of INFER4. `AssemblySyscall` layer maps each assembly macro to a callable. C FFI: `macrogrok_infer4(...)`. |
| `rust/attention.rs` + `memory.rs` + `transformer.rs` | Host wrappers that allocate device memory and launch the CUDA kernels. |
| `ksb-plus/` (sibling) | Separate K-language binary serialization contract (Layer 0). Not part of the matrix engine. |

## Building the Matrix Engine

```bash
nvcc -arch=sm_80 -ptx native/cuda/matrix_mul.cu -o gemm.ptx
# or link into a .so / use from Rust via cudarc
```

The GEMM is the foundation; attention and future operators (MLP, etc.) reuse the same tiled WMMA path.
