# Limitations that are true of this runtime

These are measured on ngn/k (growler fork) built with gcc on x86_64. They are not papered over.

1. There is no integer null distinct from `-2^63`. `0N` matches `-9223372036854775807-1`, and `0N+1` is a normal integer. KSB+ does not use `0N` as a missing-value sentinel inside persisted integers. Missing values are option tags or, at higher layers, null bitmaps. The single unrepresentable i64 (`0x8000000000000000`) is the symbol `` `I64MIN ``.

2. `%` is IEEE division, including for large integers. `(_x%y)` is not exact past the 53-bit mantissa. Exact shifts and non-negative adds in `src/binary.k` use bit vectors (`2\` / `2/`), not float division.

3. `&` and `|` on integers are minimum and maximum, not bitwise AND/OR. Bitwise operations in this layer are explicit on 0/1 bit lists. `&` coincides with AND only when both sides are already 0 or 1.

4. Path write `path 1: bytes` opens with truncation and then copies. There is no K-level `pwrite`, no `fsync`, and no `msync`. A completed write survives process exit only because it finished in the page cache. It is not a power-failure durability guarantee. Layer 5 has to say this again and test torn files; it must not claim ACID durability.

5. `` `fb `` reverses its 8 input bytes and reads host endianness. The persistent float format is still big-endian IEEE-754. `f64enc` is a pure encoder. `f64dec` uses `fb` only after an endianness probe.

6. This is not kdb+, not q, and not a compatible wire protocol. ngn/k is the execution host. Q, as a query language, has not been implemented yet.
