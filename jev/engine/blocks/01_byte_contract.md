# Block 01 — Byte Contract
Canonical spans are zero-based half-open byte intervals. Never confuse character offsets with byte offsets. All files are read in raw mode. UTF-8 query strings are encoded before searching. Span validation rejects negatives, reversed intervals, and end positions past the source length.
