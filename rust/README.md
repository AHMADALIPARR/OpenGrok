# rust/

**Purpose:** Primary language for OpenGrok. Rust owns inference, the holographic ledger, token accounting, and the PyTorch bridge. TypeScript in `src/` is the UI layer only.

## Layout

| Path | Purpose |
|------|---------|
| `Cargo.toml` | Workspace |
| `crates/opengrok` | Core: fixed-point INFER4, ledger, accounting |
| `crates/pytorch-bridge` | Attention via a pure-Rust path; swaps to libtorch when present |
| `pytorch/attention.py` | PyTorch sidecar used when `torch` is installed |

## Run

```bash
cd rust
cargo run -p opengrok
cargo run -p pytorch-bridge
```

## PyTorch

The bridge implements scaled dot-product attention in Rust so the build always runs. When libtorch is available, route the same contract through it. The Python sidecar in `pytorch/attention.py` is the reference implementation.
