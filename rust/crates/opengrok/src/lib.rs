// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// OpenGrok core. Rust is the primary language.
// TypeScript in src/ is the UI layer only.

pub mod fixed_point;
pub mod ledger;
pub mod accounting;

pub use fixed_point::infer4;
pub use ledger::{HolographicLedger, OrderBook, Tick, Side, EventKind};
pub use accounting::{Accounting, Thresholds};

pub mod tools;
pub use tools::{call, parse, ToolCall, ToolResult};
