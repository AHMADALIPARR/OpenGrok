// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
use pytorch_bridge::*;

fn main() {
    println!("PyTorch bridge (pure-Rust path)");
    let q = Tensor::from_vec(&[2, 2], vec![1.0, 0.0, 0.0, 1.0]);
    let k = Tensor::from_vec(&[2, 2], vec![1.0, 0.0, 0.0, 1.0]);
    let v = Tensor::from_vec(&[2, 2], vec![2.0, 3.0, 4.0, 5.0]);
    let out = attention(&q, &k, &v);
    println!("attention shape={:?} data={:?}", out.shape, out.data);
}
