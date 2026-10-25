// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
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
