// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
//
import { createServerFn } from "@tanstack/react-start";

export type ConnectorReadiness = { ready: boolean };

export const getConnectorReadiness = createServerFn({ method: "POST" }).handler(
  async (): Promise<ConnectorReadiness> => {
    const { isConnectorTokenReady } = await import("./client.server.ts");
    return { ready: isConnectorTokenReady() };
  },
);
