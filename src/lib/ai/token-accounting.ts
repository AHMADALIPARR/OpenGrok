// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
//
// Cycle accounting for free-tier token consumption.
// Wired into the execution loop. Halts cloud calls at the threshold
// and hands the payload to the local GGUF endpoint.

export type Route = "cloud" | "local";

export interface AccountingState {
  cycleTokens: number;
  velocity: number;       // tokens per second over the current window
  windowStart: number;
  route: Route;
  handoffs: number;
}

export interface Thresholds {
  cycleLimit: number;     // hard stop for cloud
  velocityLimit: number;  // tokens/sec soft signal
}

export const DEFAULT_THRESHOLDS: Thresholds = {
  cycleLimit: 50_000,     // free-tier cycle budget
  velocityLimit: 2_000,   // tokens/sec
};

const LOCAL_CONTEXT = 8_192; // safe context for typical local GGUF

export function freshState(now = Date.now()): AccountingState {
  return { cycleTokens: 0, velocity: 0, windowStart: now, route: "cloud", handoffs: 0 };
}

/** Rough token estimate: ~4 chars per token. */
export function estimateTokens(text: string): number {
  return Math.max(1, Math.ceil(text.length / 4));
}

/**
 * Charge tokens against the cycle and decide the route.
 * At or over the cycle limit, halt cloud and hand off to local.
 */
export function charge(
  state: AccountingState,
  tokens: number,
  now: number,
  thresholds: Thresholds = DEFAULT_THRESHOLDS,
): AccountingState {
  const elapsed = Math.max(1, (now - state.windowStart) / 1000);
  const cycleTokens = state.cycleTokens + tokens;
  const velocity = cycleTokens / elapsed;
  const over = cycleTokens >= thresholds.cycleLimit;
  const handoff = over && state.route === "cloud";
  return {
    cycleTokens,
    velocity,
    windowStart: state.windowStart,
    route: over ? "local" : "cloud",
    handoffs: state.handoffs + (handoff ? 1 : 0),
  };
}

/**
 * Trim a prompt so it fits the local GGUF context window.
 * Keeps the tail (most recent context) and a short head marker.
 */
export function fitLocalContext(prompt: string, maxTokens = LOCAL_CONTEXT): string {
  const budget = maxTokens * 4;
  if (prompt.length <= budget) return prompt;
  const head = "[context trimmed for local GGUF]\n";
  const keep = budget - head.length;
  return head + prompt.slice(-keep);
}

export function shouldHaltCloud(state: AccountingState, thresholds: Thresholds = DEFAULT_THRESHOLDS): boolean {
  return state.cycleTokens >= thresholds.cycleLimit || state.route === "local";
}
