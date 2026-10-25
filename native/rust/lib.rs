// Copyright (C) 2026 AHMAD ALI PARR
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// See the GNU Affero General Public License for more details.
// You should have received a copy of the license along with this program.
// If not, see <https://www.gnu.org/licenses/>.

// MACROGROK native library entry
// Exposes fixed-point INFER4 with Assembly Syscall Layer and C FFI.

pub mod fixed_point;
pub mod attention;
pub mod memory;
pub mod transformer;
pub mod tavily;

// Re-export the public infer4 for convenience
pub use fixed_point::{infer4, Q1_14, AssemblySyscall};