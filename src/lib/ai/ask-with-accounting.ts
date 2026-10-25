// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Execution loop with token accounting gates.
// Cloud calls stop at the free-tier threshold; payload is handed to local GGUF.

import {
  AccountingState,
  Thresholds,
  DEFAULT_THRESHOLDS,
  charge,
  estimateTokens,
  fitLocalContext,
  shouldHaltCloud,
  freshState,
} from "./token-accounting";

export interface AskDeps {
  cloud: (prompt: string) => Promise<{ ok: true; text: string } | { ok: false; error: string }>;
  local: (prompt: string) => Promise<{ ok: true; text: string } | { ok: false; error: string }>;
  thresholds?: Thresholds;
  now?: () => number;
}

export interface AskOutcome {
  ok: boolean;
  text?: string;
  error?: string;
  route: "cloud" | "local";
  state: AccountingState;
}

let state: AccountingState = freshState();

export function resetAccounting(now = Date.now()): void {
  state = freshState(now);
}

export function getAccounting(): AccountingState {
  return state;
}

/**
 * One turn of the execution loop.
 * Charges the prompt, checks the gate, and routes cloud or local.
 */
export async function askWithAccounting(prompt: string, deps: AskDeps): Promise<AskOutcome> {
  const thresholds = deps.thresholds ?? DEFAULT_THRESHOLDS;
  const now = deps.now ? deps.now() : Date.now();
  const tokens = estimateTokens(prompt);
  state = charge(state, tokens, now, thresholds);

  if (shouldHaltCloud(state, thresholds)) {
    const trimmed = fitLocalContext(prompt);
    const res = await deps.local(trimmed);
    return { ...res, route: "local", state };
  }

  const res = await deps.cloud(prompt);
  return { ...res, route: "cloud", state };
}
