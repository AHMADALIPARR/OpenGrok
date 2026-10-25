// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
// Full terminating demo of the former root stubs: attention, memory, transformer, tavily, fixed-point.
// Runs to completion on any machine. No CUDA required.

use std::sync::Mutex;

const WEIGHTS: [i16; 4] = [2458, -1638, 819, 3277];
const BIAS: i32 = -256;
static STATE: Mutex<i16> = Mutex::new(0);

fn infer4(input: [i16; 4]) -> (i16, i32, u16) {
    let mut acc: i32 = 0;
    for (w, x) in WEIGHTS.iter().zip(input.iter()) {
        acc += ((*w as i32) * (*x as i32)) >> 4;
    }
    let mut tmp0 = (acc >> 12) + BIAS;
    let mut flags = 0u16;
    if tmp0 < -8192 { tmp0 = -8192; flags |= 0x2; }
    if tmp0 > 8191  { tmp0 = 8191;  flags |= 0x2; }
    if tmp0 >= 0 { flags |= 0x4; }
    let target = if tmp0 >= 0 { 16384i16 } else { -16384i16 };
    let mut st = STATE.lock().unwrap();
    *st = ((3 * (*st as i32) + target as i32) / 4) as i16;
    flags |= 0x1;
    (*st, tmp0, flags)
}

// CPU stand-in for AttentionMemory
struct Memory {
    current_len: usize,
    max_seq_len: usize,
    k: Vec<f32>,
    v: Vec<f32>,
}
impl Memory {
    fn new(max_seq_len: usize, dim: usize) -> Self {
        Self { current_len: 0, max_seq_len, k: vec![0.0; max_seq_len * dim], v: vec![0.0; max_seq_len * dim] }
    }
    fn append(&mut self, k: &[f32], v: &[f32]) -> Result<(), String> {
        let n = k.len();
        if self.current_len + n > self.max_seq_len * (self.k.len() / self.max_seq_len) {
            return Err("KV overflow".into());
        }
        self.k[self.current_len..self.current_len+n].copy_from_slice(k);
        self.v[self.current_len..self.current_len+n].copy_from_slice(v);
        self.current_len += n;
        Ok(())
    }
}

// CPU stand-in for scaled dot-product attention
fn attention(q: &[f32], mem: &Memory, dim: usize) -> Vec<f32> {
    let seq = mem.current_len / dim.max(1);
    let mut out = vec![0.0f32; q.len()];
    if seq == 0 { return out; }
    let mut scores = vec![0.0f32; seq];
    for t in 0..seq {
        let mut s = 0.0;
        for d in 0..dim {
            s += q[d] * mem.k[t * dim + d];
        }
        scores[t] = s / (dim as f32).sqrt();
    }
    let m = scores.iter().cloned().fold(f32::NEG_INFINITY, f32::max);
    let exps: Vec<f32> = scores.iter().map(|s| (s - m).exp()).collect();
    let sum: f32 = exps.iter().sum();
    for d in 0..dim {
        let mut acc = 0.0;
        for t in 0..seq {
            acc += (exps[t] / sum) * mem.v[t * dim + d];
        }
        out[d] = acc;
    }
    out
}

// Minimal transformer step: embed (identity) -> attention -> residual
fn transformer_step(x: &[f32], mem: &mut Memory, dim: usize) -> Vec<f32> {
    let _ = mem.append(x, x);
    let attn = attention(x, mem, dim);
    x.iter().zip(attn.iter()).map(|(a, b)| a + b).collect()
}

fn main() {
    println!("=== OpenGrok full stub demo ===");

    // Fixed-point path
    let vectors = [
        [16384i16, 0, 0, 0],
        [0, 16384, 0, 0],
        [-16384, -16384, 0, 0],
        [8192, 8192, 8192, 8192],
    ];
    for v in vectors {
        let (out, score, flags) = infer4(v);
        println!("infer4 in={:?} score={} out={} flags={:03b}", v, score, out, flags);
    }

    // Memory + attention + transformer
    let dim = 4;
    let mut mem = Memory::new(16, dim);
    let x = [0.5f32, -0.2, 0.1, 0.8];
    let y = transformer_step(&x, &mut mem, dim);
    println!("transformer step out={:?}", y);
    assert_eq!(mem.current_len, dim);

    // Tavily stand-in (no network)
    println!("tavily search (mock): query='OpenGrok' hits=1");

    println!("done.");
}
