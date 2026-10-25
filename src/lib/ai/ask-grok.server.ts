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
import { askWithAccounting, getAccounting } from "./ask-with-accounting";
import { DEFAULT_THRESHOLDS } from "./token-accounting";

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
    const localBase = env("OPENAI_BASE_URL") ?? "http://127.0.0.1:8080/v1";
    const model = data.model ?? env("XAI_MODEL") ?? DEFAULT_MODEL;

    const cloud = async (prompt: string) => {
      if (!apiKey) return { ok: false as const, error: "AI is not available" };
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
      try {
        const res = await fetch("https://api.x.ai/v1/chat/completions", {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({ model, messages: [{ role: "user", content: prompt }], temperature: data.temperature }),
          signal: controller.signal,
        });
        if (!res.ok) return { ok: false as const, error: `xAI API ${res.status}` };
        const body = (await res.json()) as { choices?: { message?: { content?: string | null } }[]; model?: string };
        const text = body.choices?.[0]?.message?.content;
        if (typeof text !== "string" || text.length === 0) return { ok: false as const, error: "empty response" };
        return { ok: true as const, text };
      } catch (err) {
        if (err instanceof Error && err.name === "AbortError") return { ok: false as const, error: "request timed out" };
        return { ok: false as const, error: "network error" };
      } finally { clearTimeout(timer); }
    };

    const local = async (prompt: string) => {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
      try {
        const res = await fetch(`${localBase}/chat/completions`, {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: "Bearer local" },
          body: JSON.stringify({ model: "local", messages: [{ role: "user", content: prompt }] }),
          signal: controller.signal,
        });
        if (!res.ok) return { ok: false as const, error: `local GGUF ${res.status}` };
        const body = (await res.json()) as { choices?: { message?: { content?: string | null } }[] };
        const text = body.choices?.[0]?.message?.content;
        if (typeof text !== "string" || text.length === 0) return { ok: false as const, error: "empty local response" };
        return { ok: true as const, text };
      } catch (err) {
        if (err instanceof Error && err.name === "AbortError") return { ok: false as const, error: "local timed out" };
        return { ok: false as const, error: "local GGUF unavailable" };
      } finally { clearTimeout(timer); }
    };

    const out = await askWithAccounting(data.prompt, { cloud, local, thresholds: DEFAULT_THRESHOLDS });
    if (!out.ok) return { ok: false, error: out.error ?? "failed" };
    return { ok: true, text: out.text ?? "", model: out.route === "local" ? "local-gguf" : model };
  });
