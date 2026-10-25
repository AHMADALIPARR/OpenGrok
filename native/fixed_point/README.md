# Native Fixed-Point Engine

Dedicated directory for the MACROGROK fixed-point binary decision and Q-format arithmetic.

## Layout

```
native/fixed_point/
├── README.md
├── include/
│   └── macrogrok_fixed.h      # C ABI header
├── src/
│   └── fixed_point.rs          # Extended Rust implementation + AssemblySyscall + FFI
└── examples/
    └── demo.c                  # C caller example
```

The original copy remains at `native/rust/fixed_point.rs` for the existing crate. This directory is the standalone native package.

## Q formats

| Format | Bits | Scale | Range |
|--------|------|-------|-------|
| Q1.14 | 16 | 16384 | [-1, 1) typical |
| Q3.12 | 16 | 4096 | score / bias |
| Q7.24 | 32 | — | accumulator |

## Entry points

- Rust: `macrogrok_fixed::infer4([Q1_14; 4]) -> (i16, i32, u16)`
- C FFI: `macrogrok_infer4(i0, i1, i2, i3, &state, &score, &flags)`
- Extended: batch `infer4_batch`, reset state, get/set state, extra Q conversions.
