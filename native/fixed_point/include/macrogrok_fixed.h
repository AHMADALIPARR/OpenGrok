// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
//
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
