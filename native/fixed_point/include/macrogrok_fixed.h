// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
#ifndef MACROGROK_FIXED_H
#define MACROGROK_FIXED_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
 * MACROGROK fixed-point INFER4 C ABI
 * Q1.14 inputs, Q3.12 score, Q1.14 state output.
 */

int macrogrok_infer4(
    int16_t i0,
    int16_t i1,
    int16_t i2,
    int16_t i3,
    int16_t *out_state,
    int32_t *out_score,
    uint16_t *out_flags);

void macrogrok_reset_state(void);
int16_t macrogrok_get_state(void);
void macrogrok_set_state(int16_t v);

/* Flag bits */
#define MACROGROK_FLAG_VALID    0x1
#define MACROGROK_FLAG_SAT      0x2
#define MACROGROK_FLAG_POSITIVE 0x4

#ifdef __cplusplus
}
#endif

#endif /* MACROGROK_FIXED_H */
