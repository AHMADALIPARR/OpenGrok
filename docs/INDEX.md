# Where things belong

Every section has one job. Markdown for a topic lives in that section.

| Section | Purpose | Markdown lives in |
|---------|---------|-------------------|
| `src/` | App builder (TanStack Start, React) | `src/README.md` |
| `server/` | Server entry and routes | `server/README.md` |
| `native/` | CUDA, Rust, assembly, fixed-point | `native/README.md` |
| `skills/` | Skill contracts used by the product | `skills/README.md` and each `skills/*/SKILL.md` |
| `emacs/` | Emacs package notes (VM, Helm) | `emacs/README.md`, `emacs/vm/README.md`, `emacs/helm/README.md` |
| `ksb-plus/` | K-language binary serialization | `ksb-plus/README.md`, `ksb-plus/docs/` |
| `ports/` | Ports of external systems | `ports/README.md` |
| `migrations/` | Database migrations | `migrations/README.md` |
| `scripts/` | Build and maintenance scripts | `scripts/README.md` |
| `public/` | Static assets | `public/README.md` |
| `.grok/` | App-builder skills and reference docs | `.grok/README.md` |
| `archive/` | Review material only; not required to build | `archive/README.md` |
| `docs/` | This index and cross-cutting notes | `docs/` |

## Rules

- Do not put topic markdown in the repository root.
- A section's `README.md` states its purpose in the first paragraph.
- Skill definitions stay as `SKILL.md` inside their skill folder.
- KSB+ format docs stay in `ksb-plus/docs/`.
- Anything that is only for later review goes in `archive/`.
