# Mathematical Skills Infrastructure

**Six mathematical capability layers for exploring Ramsey numbers, Hadamard constructions, and P vs NP-style search problems.**

Cherry-picked from https://github.com/SNAPKITTYWEST/math-skills

## Overview

Each skill implements a complete mathematical reasoning capability across three layers:
- **Fortran**: High-performance computational implementation
- **APL**: Concise mathematical expression and prototyping
- **AXIOM**: Formal verification and proof

## Skills

### Skill 1: Combinatorial Enumeration
**Purpose**: Enumerate combinatorial structures with completeness guarantees

**Implementation**:
- Fortran: Backtracking with canonical form checking
- APL: Concise graph enumeration using array operations
- AXIOM: Formal proof of enumeration completeness via Burnside's lemma

**Test**: Enumerate all graphs on 5 vertices → 34 (matches OEIS A000088)

**Applications**: Ramsey theory, graph classification, design theory

### Skill 2: Graph Isomorphism Detection
**Purpose**: Determine if two graphs are structurally identical

**Implementation**:
- Fortran: Canonical labeling algorithm (simplified nauty)
- APL: Permutation-based canonical form computation
- AXIOM: Formal definition of isomorphism and canonical forms

**Test**: Detect isomorphic graphs, verify against known results

**Applications**: Graph classification, symmetry detection, molecular structure

### Skill 3: Symmetry Breaking
**Purpose**: Reduce search space by exploiting symmetries

**Implementation**:
- Fortran: Orbit enumeration under group actions
- APL: Group operations on combinatorial structures
- AXIOM: Prove symmetry reductions preserve solutions (orbit-stabilizer theorem)

**Test**: Reduce Ramsey search space by S_n symmetry

**Applications**: Ramsey number computation, constraint satisfaction, optimization

### Skill 4: Hadamard Matrix Construction
**Purpose**: Construct Hadamard matrices using classical methods

**Implementation**:
- Fortran: Sylvester, Paley, Williamson constructions
- APL: Kronecker products and matrix operations
- AXIOM: Prove construction correctness (H * H' = n * I)

**Test**: Build Hadamard matrices for orders 4, 8, 12, 16, 20

**Applications**: Error correction codes, signal processing, design theory

### Skill 5: Probabilistic Method
**Purpose**: Prove existence via probability and random construction

**Implementation**:
- Fortran: Random graph generation, Monte Carlo simulation
- APL: Probability calculations and random sampling
- AXIOM: Formalize probabilistic existence proofs (Lovász Local Lemma)

**Test**: Prove lower bounds on Ramsey numbers probabilistically

**Applications**: Ramsey theory, existence proofs, randomized algorithms

### Skill 6: Circuit Complexity
**Purpose**: Analyze Boolean circuit complexity and prove lower bounds

**Implementation**:
- Fortran: Circuit simulation, gate counting, depth computation
- APL: Boolean function representation and evaluation
- AXIOM: Formalize circuit lower bounds (parity ∉ AC⁰)

**Test**: Prove lower bounds for parity function

**Applications**: P vs NP, circuit lower bounds, complexity theory

## Mathematical Foundations

### Key Theorems Formalized
1. **Burnside's Lemma**: Count orbits via fixed points
2. **Orbit-Stabilizer Theorem**: |Orbit| × |Stabilizer| = |Group|
3. **Hadamard Conjecture**: Exists for all n ≡ 0 (mod 4)
4. **Lovász Local Lemma**: Existence via positive probability
5. **Parity ∉ AC⁰**: Exponential circuit lower bound
6. **Graph Isomorphism in NP**: Certificate is permutation

### Open Problems Addressed (as infrastructure, not solutions)
- **Ramsey Numbers**: R(5,5) unknown (between 43 and 48)
- **Hadamard Conjecture**: Open for all multiples of 4
- **P vs NP**: Circuit lower bounds would separate classes
- **Graph Isomorphism**: In NP, not known to be in P or NP-complete

These skills should be read as infrastructure and finite-method support, not as evidence that the listed open problems are resolved.

## Full source

Fortran, APL, and AXIOM implementations plus sealing scripts:
https://github.com/SNAPKITTYWEST/math-skills
