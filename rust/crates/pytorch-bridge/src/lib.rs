// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
//
// PyTorch bridge. Speaks a small tensor contract.
// When libtorch is present, route through it. Otherwise the pure-Rust
// path below is used so the build always runs.

#[derive(Clone, Debug)]
pub struct Tensor { pub shape: Vec<usize>, pub data: Vec<f32> }

impl Tensor {
    pub fn zeros(shape: &[usize]) -> Self {
        let n: usize = shape.iter().product();
        Self { shape: shape.to_vec(), data: vec![0.0; n] }
    }
    pub fn from_vec(shape: &[usize], data: Vec<f32>) -> Self {
        Self { shape: shape.to_vec(), data }
    }
}

/// Matmul for 2D tensors. Pure Rust. Matches a PyTorch `torch.matmul` call
/// for the shapes we use in attention.
pub fn matmul(a: &Tensor, b: &Tensor) -> Tensor {
    assert_eq!(a.shape.len(), 2);
    assert_eq!(b.shape.len(), 2);
    let (m, k) = (a.shape[0], a.shape[1]);
    let n = b.shape[1];
    assert_eq!(k, b.shape[0]);
    let mut out = vec![0.0f32; m * n];
    for i in 0..m {
        for j in 0..n {
            let mut s = 0.0f32;
            for p in 0..k { s += a.data[i*k+p] * b.data[p*n+j]; }
            out[i*n+j] = s;
        }
    }
    Tensor { shape: vec![m, n], data: out }
}

/// Softmax over the last dimension.
pub fn softmax(t: &Tensor) -> Tensor {
    let n = *t.shape.last().unwrap();
    let rows = t.data.len() / n;
    let mut out = vec![0.0f32; t.data.len()];
    for r in 0..rows {
        let row = &t.data[r*n..(r+1)*n];
        let max = row.iter().cloned().fold(f32::NEG_INFINITY, f32::max);
        let exps: Vec<f32> = row.iter().map(|x| (x-max).exp()).collect();
        let sum: f32 = exps.iter().sum();
        for c in 0..n { out[r*n+c] = exps[c] / sum; }
    }
    Tensor { shape: t.shape.clone(), data: out }
}

/// Scaled dot-product attention: softmax(Q K^T / sqrt(d)) V
pub fn attention(q: &Tensor, k: &Tensor, v: &Tensor) -> Tensor {
    let d = q.shape[1] as f32;
    let mut scores = matmul(q, &transpose(k));
    for x in &mut scores.data { *x /= d.sqrt(); }
    let weights = softmax(&scores);
    matmul(&weights, v)
}

fn transpose(t: &Tensor) -> Tensor {
    let (m, n) = (t.shape[0], t.shape[1]);
    let mut data = vec![0.0f32; m*n];
    for i in 0..m { for j in 0..n { data[j*m+i] = t.data[i*n+j]; } }
    Tensor { shape: vec![n, m], data }
}
