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

//! MACROGROK fixed-point INFER4 — Rust port of MACROGROK/src/sim.py + examples/infer4.asm
//! Q1.14 (16384 per 1.0), Q3.12 (4096 per 1.0), Q7.24 ACC, saturate.
//!
//! Includes an Assembly Syscall Layer that abstracts the pseudo-ISA operations
//! (LOAD/STORE/ADD/MUL/ASR/CMP/BR) as Rust syscalls, plus C FFI for external callers.

use std::sync::Mutex;

const WEIGHTS_Q1_14: [i16; 4] = [2458, -1638, 819, 3277];
const BIAS_Q3_12: i32 = -256;
const FLAG_VALID: u16 = 0x1;
const FLAG_SAT: u16 = 0x2;
const FLAG_POSITIVE: u16 = 0x4;

#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub struct Q1_14(pub i16);

/// Persistent STATE for the 3/4 low-pass filter (matches assembly erasable memory).
static STATE: Mutex<i16> = Mutex::new(0);

/// Assembly Syscall Layer — finish layer that maps the pseudo-ISA macros to Rust.
/// Each primitive is exposed as a syscall-style function for traceability and FFI.
pub struct AssemblySyscall;

impl AssemblySyscall {
    /// CLR_ACC equivalent
    pub fn clr_acc(acc_hi: &mut i16, acc_lo: &mut i16) {
        *acc_hi = 0;
        *acc_lo = 0;
    }

    /// MAC_Q1_14: 16-bit multiply + arithmetic shift right 4 + accumulate (Q2.28 -> Q3.24)
    pub fn mac_q1_14(acc: &mut i32, a: i16, b: i16) {
        let prod = (a as i32) * (b as i32); // Q2.28
        let shifted = prod >> 4; // arithmetic
        *acc = acc.wrapping_add(shifted);
    }

    /// ACC_TO_Q3_12: ASR32 by 12
    pub fn acc_to_q3_12(acc: i32) -> i32 {
        acc >> 12
    }

    /// SAT_Q3_12 with flag update
    pub fn sat_q3_12(value: &mut i32, flags: &mut u16) {
        let mut sat = false;
        if *value < -8192 {
            *value = -8192;
            sat = true;
        }
        if *value > 8191 {
            *value = 8191;
            sat = true;
        }
        if sat {
            *flags |= FLAG_SAT;
        }
    }

    /// THRESHOLD_Q3_12
    pub fn threshold_q3_12(tmp0: i32, flags: &mut u16) -> i16 {
        if tmp0 >= 0 {
            *flags |= FLAG_POSITIVE;
            16384
        } else {
            -16384
        }
    }

    /// UPDATE_STATE_3_4 low-pass
    pub fn update_state_3_4(target: i16) -> i16 {
        let mut state = STATE.lock().unwrap();
        *state = ((3 * (*state as i32) + target as i32) / 4) as i16;
        *state
    }
}

pub fn infer4(input: [Q1_14; 4]) -> (i16, i32, u16) {
    let mut acc: i32 = 0;
    let mut flags: u16 = 0;

    // DOT4 via syscall layer
    for (w, inp) in WEIGHTS_Q1_14.iter().zip(input.iter()) {
        AssemblySyscall::mac_q1_14(&mut acc, *w, inp.0);
    }

    let mut tmp0 = AssemblySyscall::acc_to_q3_12(acc);
    tmp0 += BIAS_Q3_12;
    AssemblySyscall::sat_q3_12(&mut tmp0, &mut flags);

    let tmp1 = AssemblySyscall::threshold_q3_12(tmp0, &mut flags);
    let out = AssemblySyscall::update_state_3_4(tmp1);
    flags |= FLAG_VALID;

    (out, tmp0, flags)
}

// ===== C FFI layer (extern "C") =====
#[no_mangle]
pub extern "C" fn macrogrok_infer4(
    i0: i16,
    i1: i16,
    i2: i16,
    i3: i16,
    out_state: *mut i16,
    out_score: *mut i32,
    out_flags: *mut u16,
) -> i32 {
    if out_state.is_null() || out_score.is_null() || out_flags.is_null() {
        return -1;
    }
    let input = [Q1_14(i0), Q1_14(i1), Q1_14(i2), Q1_14(i3)];
    let (state, score, flags) = infer4(input);
    unsafe {
        *out_state = state;
        *out_score = score;
        *out_flags = flags;
    }
    0
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_infer4_basic() {
        let (out, _, flags) = infer4([Q1_14(16384), Q1_14(0), Q1_14(0), Q1_14(0)]);
        assert!(out != 0);
        assert!(flags & FLAG_VALID != 0);
    }
}