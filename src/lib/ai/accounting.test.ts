// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
// Verify local fallback routing: cloud halts at threshold, local picks up context.

import { askWithAccounting, resetAccounting, getAccounting } from "./ask-with-accounting";
import { fitLocalContext, estimateTokens } from "./token-accounting";

function assert(cond: unknown, msg: string): void {
  if (!cond) throw new Error(msg);
}

async function main() {
  const thresholds = { cycleLimit: 100, velocityLimit: 10_000 };
  let cloudCalls = 0;
  let localCalls = 0;
  let lastLocalPrompt = "";

  const deps = {
    thresholds,
    now: () => 1_000,
    cloud: async (p: string) => { cloudCalls++; return { ok: true as const, text: "cloud:" + p.slice(0, 8) }; },
    local: async (p: string) => { localCalls++; lastLocalPrompt = p; return { ok: true as const, text: "local:" + p.slice(0, 8) }; },
  };

  resetAccounting(1_000);

  // Under budget: cloud
  const a = await askWithAccounting("short prompt", deps);
  assert(a.route === "cloud", "expected cloud under budget");
  assert(cloudCalls === 1, "cloud should have been called");
  assert(localCalls === 0, "local should not yet be called");

  // Push over the limit
  const big = "x".repeat(500); // ~125 tokens
  const b = await askWithAccounting(big, deps);
  assert(b.route === "local", "expected local after threshold");
  assert(localCalls === 1, "local should pick up");
  assert(getAccounting().handoffs === 1, "handoff counted");

  // Subsequent calls stay local
  const c = await askWithAccounting("another", deps);
  assert(c.route === "local", "stays local after handoff");
  assert(localCalls === 2, "second local call");
  assert(cloudCalls === 1, "no further cloud calls");

  // Context fit: oversized prompt is trimmed, not overflowing
  const huge = "y".repeat(100_000);
  const fitted = fitLocalContext(huge, 8192);
  assert(estimateTokens(fitted) <= 8192, "fitted prompt within local context");
  assert(fitted.startsWith("[context trimmed"), "trim marker present");
  assert(fitted.endsWith("y"), "tail preserved");

  console.log("PASS accounting gates");
  console.log("PASS threshold triggers");
  console.log("PASS local fallback routing");
  console.log("cloud calls:", cloudCalls, "local calls:", localCalls, "handoffs:", getAccounting().handoffs);
}

main().catch((e) => { console.error(e); process.exit(1); });
