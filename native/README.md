# native/

**Purpose:** Low-level native code — CUDA kernels, Rust host, MACROGROK assembly, and the fixed-point engine. Not application UI.

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
| `asm/` | Reference pseudo-ISA for the fixed-point binary decision. |
| `fixed_point/` | Dedicated native package. Extended Rust engine + C ABI + demo. |
| `cuda/` | Tensor Core kernels (GEMM and attention). |
| `rust/` | Host wrappers and FFI for the kernels and fixed-point engine. |

## Building the fixed-point package

```bash
cd native/fixed_point
cargo build --release
```
