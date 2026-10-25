# Native Segments

Organized low-level components for OpenGrok.

## Directory Layout

```
native/
├── asm/                 # MACROGROK pseudo-ISA
│   └── infer4.asm        # Fixed-point 4-input decision (Q1.14 / Q3.12)
├── fixed_point/         # Dedicated fixed-point engine package
│   ├── include/macrogrok_fixed.h
│   ├── src/fixed_point.rs   # Extended: batch, state control, extra Q helpers
│   ├── examples/demo.c
│   └── Cargo.toml
├── cuda/                # CUDA kernels (Tensor Core)
│   ├── matrix_mul.cu      # Full WMMA GEMM engine (A*B -> C, FP16/FP32)
│   ├── tensor_core_attention.cu
│   └── tma.ptx
└── rust/                # Host-side Rust (cudarc + FFI)
    ├── lib.rs
    ├── fixed_point.rs     # Original copy (crate-integrated)
    ├── attention.rs
    ├── memory.rs
    ├── transformer.rs
    ├── tavily.rs
    └── main.rs
```

## What Each Segment Does

| Segment | Purpose |
|---------|---------|
| `asm/infer4.asm` | Reference pseudo-ISA for the fixed-point binary decision. |
| **`fixed_point/`** | **Dedicated native package.** Extended Rust engine + C ABI + demo. Batch inference, state get/set/reset, extra Q conversions. |
| `cuda/matrix_mul.cu` | Full Tensor Core WMMA GEMM engine. |
| `cuda/tensor_core_attention.cu` | Attention built on WMMA tiles. |
| `rust/fixed_point.rs` | Original crate-integrated copy of the fixed-point engine. |
| `rust/attention.rs` + others | Host wrappers for CUDA kernels. |

## Building the fixed-point package

```bash
cd native/fixed_point
cargo build --release
# produces libmacrogrok_fixed.so / .dylib / .dll
# then link against examples/demo.c with the header
```
