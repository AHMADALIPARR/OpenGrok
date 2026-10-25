---
name: math-skills
description: Mathematical master skill set — six capability layers (combinatorial enumeration, graph isomorphism, symmetry breaking, Hadamard construction, probabilistic method, circuit complexity). Each skill is expressed in Fortran (high-performance), APL (array prototype), and AXIOM (formal spec). Sealed to a WORM ledger with Merkle root. Use for Ramsey theory support, Hadamard matrices, circuit lower bounds, or when a formal mathematical capability is requested. Not a claim that open problems are solved.
---

# Mathematical Skills (Master Set)

Cherry-picked from https://github.com/SNAPKITTYWEST/math-skills

Six self-contained mathematical capability layers. Each skill has three implementations:

- **Fortran** — high-performance computational core
- **APL** — concise array-oriented prototype
- **AXIOM** — formal specification / theorem stubs

## Skills

| ID | Capability | Notable test |
|----|------------|--------------|
| `skill1-enumeration` | Enumerate non-isomorphic graphs (backtracking + canonical form) | Graphs on 5 vertices = 34 (OEIS A000088) |
| `skill2-isomorphism` | Canonical labeling / isomorphism detection | Detect isomorphic graphs |
| `skill3-symmetry` | Orbit enumeration under group actions (symmetry breaking) | Reduce Ramsey search via Sₙ |
| `skill4-hadamard` | Sylvester, Paley, Williamson constructions | Build orders 4, 8, 12, 16, 20 |
| `skill5-probabilistic` | Monte Carlo + Lovász Local Lemma existence proofs | Lower bounds on Ramsey numbers |
| `skill6-circuits` | Gate counting, depth, lower bounds (parity ∉ AC⁰) | Parity lower bound |

## Foundations formalized

- Burnside's lemma
- Orbit-stabilizer theorem
- Hadamard conjecture (construction side)
- Lovász Local Lemma
- Parity ∉ AC⁰
- Graph isomorphism ∈ NP

These are infrastructure and finite-method support. They are **not** claims that the open problems (R(5,5), Hadamard conjecture, P vs NP) are solved.

## Sealing

Master seal (Merkle root over 6 skills):

```
merkleRoot: 1db547d7a403c7d6ba2a8bdc8d13378a7c5335da1c5ac7e27842e72c324ceb63
chainLength: 6
```

Full source (Fortran / APL / AXIOM files + sealing scripts):
https://github.com/SNAPKITTYWEST/math-skills

See also `MATH_SKILLS.md` in this directory for the design document.
