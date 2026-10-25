// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
use cudarc::driver::{CudaDevice, CudaSlice};
use half::f16;
use std::sync::Arc;

#[derive(Clone)]
pub struct AttentionMemory {
    pub device: Arc<CudaDevice>,
    pub k_cache: CudaSlice<f16>,
    pub v_cache: CudaSlice<f16>,
    pub max_seq_len: usize,
    pub num_layers: usize,
    pub num_heads: usize,
    pub head_dim: usize,
    pub current_len: usize,
}

impl AttentionMemory {
    pub fn new(
        device: Arc<CudaDevice>,
        num_layers: usize,
        num_heads: usize,
        head_dim: usize,
        max_seq_len: usize,
    ) -> anyhow::Result<Self> {
        let elems = num_layers * num_heads * max_seq_len * head_dim;
        let k_cache = unsafe { device.alloc::<f16>(elems)? };
        let v_cache = unsafe { device.alloc::<f16>(elems)? };
        Ok(Self {
            device,
            k_cache,
            v_cache,
            max_seq_len,
            num_layers,
            num_heads,
            head_dim,
            current_len: 0,
        })
    }

    pub fn append_kv(
        &mut self,
        _layer: usize,
        _k: &CudaSlice<f16>,
        _v: &CudaSlice<f16>,
        seq_len: usize,
    ) -> anyhow::Result<()> {
        if self.current_len + seq_len > self.max_seq_len {
            anyhow::bail!("KV cache overflow");
        }
        self.current_len += seq_len;
        Ok(())
    }

    pub fn reset(&mut self) {
        self.current_len = 0;
    }
}
