// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
import assert from "node:assert/strict";
import { test } from "node:test";
import { z } from "zod";

// Mirror the schema so the test does not pull in the server function runtime.
const AskInput = z.object({
  prompt: z.string().trim().min(1).max(32_000),
  model: z.string().trim().min(1).max(64).optional(),
  temperature: z.number().min(0).max(2).optional(),
});

test("accepts a normal prompt", () => {
  const r = AskInput.parse({ prompt: "hello" });
  assert.equal(r.prompt, "hello");
});

test("rejects empty prompt", () => {
  assert.throws(() => AskInput.parse({ prompt: "   " }));
});

test("rejects oversized prompt", () => {
  assert.throws(() => AskInput.parse({ prompt: "x".repeat(32_001) }));
});

test("accepts optional model and temperature", () => {
  const r = AskInput.parse({
    prompt: "hi",
    model: "grok-4.5",
    temperature: 0.2,
  });
  assert.equal(r.model, "grok-4.5");
  assert.equal(r.temperature, 0.2);
});
