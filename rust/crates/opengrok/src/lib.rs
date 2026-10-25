// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
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
