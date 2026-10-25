// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
use std::sync::Arc;
use cudarc::driver::CudaDevice;

mod attention;
mod memory;
mod tavily;
mod transformer;
mod fixed_point;

use memory::AttentionMemory;
use tavily::TavilyClient;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let device = Arc::new(CudaDevice::new(0)?);
    let config = transformer::TransformerConfig {
        hidden_size: 4096,
        num_layers: 32,
        num_heads: 32,
        head_dim: 128,
        max_seq_len: 8192,
        vocab_size: 32000,
    };
    let mut mem = AttentionMemory::new(
        device.clone(),
        config.num_layers,
        config.num_heads,
        config.head_dim,
        config.max_seq_len,
    )?;
    let tavily = TavilyClient::new(std::env::var("TAVILY_API_KEY").unwrap_or_default());

    // MACROGROK demo
    let (out, score, flags) = fixed_point::infer4([
        fixed_point::Q1_14(16384),
        fixed_point::Q1_14(0),
        fixed_point::Q1_14(0),
        fixed_point::Q1_14(0),
    ]);
    println!(
        "MACROGROK INFER4 out={} score={} flags={:03b}",
        out, score, flags
    );

    // Transformer loop placeholder: tokenize → forward → tool call → Tavily → continue
    let _ = (&config, &mut mem, &tavily);
    println!("Harness ready. Set TAVILY_API_KEY and wire model weights.");
    Ok(())
}
