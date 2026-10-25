# holographic-ledger

**Purpose:** Append-only, hash-chained ledger for continuous tick-data capture and live order-book reconstruction.

Designed for the ingest pattern of exchanges, proprietary desks, and market makers: every quote, trade, and order-book adjustment is sealed into a holographic chain. The chain is an integrity check, not an authenticity proof.

## Layout

| File | Purpose |
|------|---------|
| `src/ledger.rs` | Tick, Entry, HolographicLedger, OrderBook |
| `src/main.rs` | Synthetic stream demo that seals and verifies |

## Run

```bash
cd ledger
cargo run --bin ledger
cargo test
```

## Notes

- Prices are fixed-point `i64` at 1e-8.
- Hash is FNV-1a mixed with the previous head. Swap for a cryptographic hash if you need collision resistance.
- The order book is a pure function of the ledger; it can be rebuilt from any prefix.
