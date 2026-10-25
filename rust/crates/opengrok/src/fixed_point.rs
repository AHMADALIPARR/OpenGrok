// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
// Q1.14 / Q3.12 fixed-point INFER4. Matches MACROGROK semantics.

pub const Q1_14: i32 = 16384;
const WEIGHTS: [i32; 4] = [2458, -1638, 819, 3277];
const BIAS: i32 = -256;

pub fn infer4(input: [i32; 4], state: &mut i32) -> (i32, i32, u8) {
    let mut acc: i64 = 0;
    for (w, x) in WEIGHTS.iter().zip(input.iter()) {
        let prod = (*w as i64) * (*x as i64);
        acc += prod >> 4;
    }
    let mut tmp = (acc >> 12) as i32 + BIAS;
    let mut sat = false;
    if tmp < -8192 { tmp = -8192; sat = true; }
    if tmp > 8191 { tmp = 8191; sat = true; }
    let tmp1 = if tmp >= 0 { 16384 } else { -16384 };
    let mut flags = 0u8;
    if tmp >= 0 { flags |= 0x4; }
    if sat { flags |= 0x2; }
    *state = (3 * *state + tmp1) / 4;
    flags |= 0x1;
    (*state, tmp, flags)
}
