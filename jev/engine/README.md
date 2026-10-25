# Non-Regressive Semantic Engine (NRSE)

A source-grounded retrieval engine that returns byte spans instead of generated prose.
The core answer format is `[start_byte, end_byte]`; missing evidence is `[-1, -1]`.

## Design

- **Perl**: source ingestion, byte-preserving normalization, span indexing, deterministic orchestration.
- **AWK**: streaming corpus inspection and audit reports.
- **Mojo**: optional HTTP service exposing the span engine.
- **PEL**: a small declarative policy language for evidence and output constraints. This repository defines a deliberately small PEL grammar; it does not assume a vendor-specific PEL implementation.
- **Logic blocks**: exact-match, normalized-match, bounded-window, ambiguity, and evidence validation.
- **Non-regression**: golden fixtures, deterministic output, invariant tests, and corpus hashes.

No language can guarantee that a source-grounded system never returns a wrong answer: retrieval can select the wrong passage, source text can be false, and offsets can be misinterpreted. This engine avoids free-form answer generation and exposes provenance for downstream verification.

## Run

```sh
perl nrse.pl locate corpus.txt "exact source phrase"
perl nrse.pl extract corpus.txt 10 30
perl nrse.pl audit corpus.txt
awk -f blocks/audit.awk corpus.txt
prove -v tests/*.t
```

Optional Mojo server (install Mojolicious first):

```sh
MOJO_MODE=development perl nrse_mojo.pl daemon
```

The engine's canonical offsets are zero-based, half-open byte intervals `[start_byte, end_byte)`.
