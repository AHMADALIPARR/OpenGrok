# ledger/

**This directory is a host demo. It is not the ledger.**

The holographic append-only ledger is KSB+. It lives in `ksb-plus/src/ledger.k` and seals every tick into a version-1 `KSB+` envelope using `envenc` / `envdec` and the Layer 0 codec.

| Real path | Purpose |
|-----------|---------|
| `ksb-plus/src/ledger.k` | `tickenc`, `seal`, `open`, `verify` on the KSB+ envelope |
| `ksb-plus/t/t_ledger.k` | Chain round-trip |
| `ksb-plus/src/binary.k` | Layer 0 envelope and CRC-32 |
| `ksb-plus/src/codec.k` | u8–u64 encode/decode |

The Rust files here replay the same tick shape in memory. They do not write a `KSB+` envelope and they are not the source of truth.

```sh
K=path/to/ngn-k sh ksb-plus/t/run.sh
```
