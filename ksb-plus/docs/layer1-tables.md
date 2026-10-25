# KSB+ Layer 1 — Columnar Tables

Extension of the Layer 0 envelope.

## On-disk layout

A table is a single `KSB+` envelope (version 1) whose payload is a sequence of columns:

```
for each column:
  length-prefixed UTF-8 name
  u8  type tag
  u32 count
  raw values
```

## Type tags

| Tag | Type | Encoding |
|-----|------|----------|
| 0 | i32 | big-endian two's complement |
| 1 | i64 | big-endian two's complement (with `I64MIN` special case from Layer 0) |
| 2 | f64 | IEEE-754 binary64 big-endian |
| 3 | bytes | length-prefixed (u32 + bytes) |

## In-memory model

```
table: (`name`i32! (0; 1 2 3); `price`f64! (2; 1.5 2.0 0.5))
```

## API (src/table.k)

| Function | Purpose |
|----------|---------|
| `tableenc` | dict of columns → envelope bytes |
| `tabledec` | envelope bytes → dict of columns |
| `appendrow` | add one row (dict) to an in-memory table |
| `scan` | return all rows as a list of dicts |

## Notes

- No secondary indexes, no compression, no schema evolution yet.
- Nulls are not first-class; use the Layer 0 option tag if needed inside a bytes column.
- Higher layers (query language, WAL, durability) are not claimed.
