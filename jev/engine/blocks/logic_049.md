# Logic Block 049: Evidence semantics

## Invariant
Distinguish literal occurrence, normalized occurrence, relevance, and logical entailment. Do not conflate them.

## Inputs
- Source bytes and a stable source identifier.
- A query or a validated candidate span.
- Immutable engine configuration for this execution.

## Procedure
1. Validate input types and configured size limits.
2. Bind the operation to the exact source hash.
3. Execute only the declared deterministic transformation.
4. Validate any returned interval against the source byte length.
5. Preserve original source bytes for extraction.
6. Emit the configured result representation.
7. Record deterministic diagnostics without leaking document content.

## Rejection conditions
- Missing source or malformed query.
- Negative or reversed offsets.
- End offset beyond source length.
- Source hash changed since indexing.
- Operation exceeds configured limits.
- Policy disallows the requested operation.

## Non-regression test
For identical source bytes, query bytes, policy, and engine version, the result must remain identical. If the result differs, fail the test and preserve both outputs for diagnosis.

## Boundary cases
- Empty source or query.
- Match at byte zero or ending at the final byte.
- Multiple occurrences and UTF-8 multibyte content.
- Embedded NUL byte, truncated source, or stale index.
- Query exceeding the configured maximum.

## Output contract
A successful lookup returns a zero-based half-open byte interval. A missing exact match returns `[-1, -1]`. Any richer semantic claim requires an independent verifier and must not be inferred from occurrence alone.
