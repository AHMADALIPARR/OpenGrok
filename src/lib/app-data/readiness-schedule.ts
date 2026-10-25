// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
//
export const READINESS_PROBE_DELAYS_MS = [1_000, 2_000, 3_000, 5_000] as const;

export const READINESS_PROBE_MAX_TOTAL_MS = 3 * 60_000;

export function readinessProbeDelayMs(attempt: number): number {
  const index = Math.min(
    Math.max(attempt, 0),
    READINESS_PROBE_DELAYS_MS.length - 1,
  );
  return READINESS_PROBE_DELAYS_MS[index];
}

export function readinessProbeExhausted(
  startedAtMs: number,
  nowMs: number,
): boolean {
  return nowMs - startedAtMs >= READINESS_PROBE_MAX_TOTAL_MS;
}
