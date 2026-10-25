// MACROGROK native library entry
// Exposes fixed-point INFER4 with Assembly Syscall Layer and C FFI.

pub mod fixed_point;
pub mod attention;
pub mod memory;
pub mod transformer;
pub mod tavily;

// Re-export the public infer4 for convenience
pub use fixed_point::{infer4, Q1_14, AssemblySyscall};
