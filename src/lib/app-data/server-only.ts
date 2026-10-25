// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
//
export function assertAppDataServerOnly(
  context = "app-data/client.server",
): void {
  if (typeof window !== "undefined") {
    throw new Error(
      `@/lib/${context} is server-only. Call connector tools from a createServerFn handler (dynamic import of @/lib/app-data/client.server), never from a React component, useEffect, or browser fetch. Types and login helpers are client-safe via @/lib/app-data.`,
    );
  }
}

assertAppDataServerOnly("app-data/client.server");
