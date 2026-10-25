// Copyright (C) 2026 AHMAD ALI PARR
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// See the GNU Affero General Public License for more details.
// You should have received a copy of the license along with this program.
// If not, see <https://www.gnu.org/licenses/>.

import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { env } from "@/lib/env.server";

const AskInput = z.object({
  prompt: z.string().trim().min(1).max(32_000),
  model: z.string().trim().min(1).max(64).optional(),
  temperature: z.number().min(0).max(2).optional(),
});

type AskResult =
  | { ok: true; text: string; model: string }
  | { ok: false; error: string };

const DEFAULT_MODEL = "grok-4.7";
const TIMEOUT_MS = 30_000;

export const askGrok = createServerFn({ method: "POST" })
  .validator((input: unknown) => AskInput.parse(input))
  .handler(async ({ data }): Promise<AskResult> => {
    const apiKey = env("XAI_API_KEY");
    if (!apiKey) {
      return { ok: false, error: "AI is not available" };
    }

    const model = data.model ?? env("XAI_MODEL") ?? DEFAULT_MODEL;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);

    try {
      const res = await fetch("https://api.x.ai/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model,
          messages: [{ role: "user", content: data.prompt }],
          temperature: data.temperature,
        }),
        signal: controller.signal,
      });

      if (!res.ok) {
        // Do not leak the full body; it can contain request echoes.
        const status = res.status;
        const hint =
          status === 401 || status === 403
            ? "unauthorized"
            : status === 429
              ? "rate limited"
              : status >= 500
                ? "upstream error"
                : "request rejected";
        return { ok: false, error: `xAI API ${status} (${hint})` };
      }

      const body = (await res.json()) as {
        choices?: { message?: { content?: string | null } }[];
        model?: string;
      };

      const text = body.choices?.[0]?.message?.content;
      if (typeof text !== "string" || text.length === 0) {
        return { ok: false, error: "empty response" };
      }

      return { ok: true, text, model: body.model ?? model };
    } catch (err) {
      if (err instanceof Error && err.name === "AbortError") {
        return { ok: false, error: "request timed out" };
      }
      return { ok: false, error: "network error" };
    } finally {
      clearTimeout(timer);
    }
  });