//! MACROGROK fixed-point engine — extended.
//! Q1.14 / Q3.12 / Q7.24, AssemblySyscall layer, C FFI, batch, state control.
//!
//! Source of truth for the native/fixed_point/ package.
//! Mirrors native/asm/infer4.asm semantics.

use std::sync::Mutex;

// ===== Constants =====
pub const WEIGHTS_Q1_14: [i16; 4] = [2458, -1638, 819, 3277];
pub const BIAS_Q3_12: i32 = -256;
pub const ALPHA_Q1_14: i16 = 12288; // 0.75

pub const FLAG_VALID: u16 = 0x1;
pub const FLAG_SAT: u16 = 0x2;
pub const FLAG_POSITIVE: u16 = 0x4;

pub const Q1_14_ONE: i16 = 16384;
pub const Q1_14_MIN: i16 = -16384;
pub const Q1_14_MAX: i16 = 16383;
pub const Q3_12_MIN: i32 = -8192;
pub const Q3_12_MAX: i32 = 8191;

// ===== Types =====
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub struct Q1_14(pub i16);

#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub struct Q3_12(pub i32);

// ===== Persistent state =====
static STATE: Mutex<i16> = Mutex::new(0);

// ===== Conversion helpers =====
pub fn q1_14_to_f32(x: i16) -> f32 {
    x as f32 / 16384.0
}
pub fn f32_to_q1_14(f: f32) -> i16 {
    let v = (f * 16384.0).round() as i32;
    v.clamp(Q1_14_MIN as i32, Q1_14_MAX as i32) as i16
}
pub fn q3_12_to_f32(x: i32) -> f32 {
    x as f32 / 4096.0
}
pub fn f32_to_q3_12(f: f32) -> i32 {
    let v = (f * 4096.0).round() as i32;
    v.clamp(Q3_12_MIN, Q3_12_MAX)
}

// ===== Assembly Syscall Layer =====
pub struct AssemblySyscall;

impl AssemblySyscall {
    pub fn clr_acc() -> i32 {
        0
    }

    /// MAC_Q1_14: Q1.14 * Q1.14 -> Q2.28, ASR 4 -> Q3.24 accumulate
    pub fn mac_q1_14(acc: &mut i32, a: i16, b: i16) {
        let prod = (a as i32).wrapping_mul(b as i32);
        let shifted = prod >> 4; // arithmetic
        *acc = acc.wrapping_add(shifted);
    }

    pub fn acc_to_q3_12(acc: i32) -> i32 {
        acc >> 12
    }

    pub fn sat_q3_12(value: &mut i32, flags: &mut u16) {
        let mut sat = false;
        if *value < Q3_12_MIN {
            *value = Q3_12_MIN;
            sat = true;
        }
        if *value > Q3_12_MAX {
            *value = Q3_12_MAX;
            sat = true;
        }
        if sat {
            *flags |= FLAG_SAT;
        }
    }

    pub fn threshold_q3_12(tmp0: i32, flags: &mut u16) -> i16 {
        if tmp0 >= 0 {
            *flags |= FLAG_POSITIVE;
            Q1_14_ONE
        } else {
            Q1_14_MIN
        }
    }

    pub fn update_state_3_4(target: i16) -> i16 {
        let mut state = STATE.lock().unwrap();
        *state = ((3 * (*state as i32) + target as i32) / 4) as i16;
        *state
    }

    // Extended syscalls
    pub fn add_q3_12(a: i32, b: i32) -> i32 {
        a.wrapping_add(b)
    }

    pub fn scale_q1_14(x: i16, alpha: i16) -> i16 {
        let prod = (x as i32).wrapping_mul(alpha as i32);
        (prod >> 14) as i16
    }
}

// ===== Core inference =====
pub fn infer4(input: [Q1_14; 4]) -> (i16, i32, u16) {
    let mut acc = AssemblySyscall::clr_acc();
    let mut flags: u16 = 0;

    for (w, inp) in WEIGHTS_Q1_14.iter().zip(input.iter()) {
        AssemblySyscall::mac_q1_14(&mut acc, *w, inp.0);
    }

    let mut tmp0 = AssemblySyscall::acc_to_q3_12(acc);
    tmp0 = AssemblySyscall::add_q3_12(tmp0, BIAS_Q3_12);
    AssemblySyscall::sat_q3_12(&mut tmp0, &mut flags);

    let tmp1 = AssemblySyscall::threshold_q3_12(tmp0, &mut flags);
    let out = AssemblySyscall::update_state_3_4(tmp1);
    flags |= FLAG_VALID;

    (out, tmp0, flags)
}

/// Batch inference (does not reset state between calls).
pub fn infer4_batch(inputs: &[[i16; 4]]) -> Vec<(i16, i32, u16)> {
    inputs
        .iter()
        .map(|v| {
            let q = [Q1_14(v[0]), Q1_14(v[1]), Q1_14(v[2]), Q1_14(v[3])];
            infer4(q)
        })
        .collect()
}

/// Reset the persistent STATE to 0.
pub fn reset_state() {
    *STATE.lock().unwrap() = 0;
}

/// Read current STATE.
pub fn get_state() -> i16 {
    *STATE.lock().unwrap()
}

/// Set STATE directly (for testing / warm-start).
pub fn set_state(v: i16) {
    *STATE.lock().unwrap() = v;
}

// ===== C FFI =====
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

#[no_mangle]
pub extern "C" fn macrogrok_reset_state() {
    reset_state();
}

#[no_mangle]
pub extern "C" fn macrogrok_get_state() -> i16 {
    get_state()
}

#[no_mangle]
pub extern "C" fn macrogrok_set_state(v: i16) {
    set_state(v);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn basic_positive() {
        reset_state();
        let (out, score, flags) = infer4([Q1_14(16384), Q1_14(0), Q1_14(0), Q1_14(0)]);
        assert!(flags & FLAG_VALID != 0);
        assert!(score != 0 || out != 0);
    }

    #[test]
    fn batch_and_reset() {
        reset_state();
        let inputs = [[16384i16, 0, 0, 0], [0, 16384, 0, 0]];
        let results = infer4_batch(&inputs);
        assert_eq!(results.len(), 2);
        reset_state();
        assert_eq!(get_state(), 0);
    }
}
