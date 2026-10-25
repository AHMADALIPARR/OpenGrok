# Block 03 — Non-regression Contract
For fixed source bytes and fixed query bytes, exact lookup must return the same result on every run. Every change requires tests for hit, miss, repeated match, UTF-8 offsets, malformed span, and boundary handling. Golden outputs are versioned.
