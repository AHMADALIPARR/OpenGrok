// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
/**
 * Client-readable marker for gate-materialized sessions ("Sign in with Grok"
 * zero-click sessions minted by `gate-session.server.ts`). Signing out of a
 * gate session is a no-op — the next request re-materializes it from
 * `x-grok-identity` — so `UserButton` uses this to hide its sign-out control.
 * `__Host-` prefixed like the other auth cookies: browsers reject a `__Host-`
 * cookie carrying a `Domain`, so an untrusted sibling `*.grok.me` app cannot
 * plant a parent-domain copy that the host-only clear could never expire.
 * Client-safe: no server imports.
 */
export const GATE_SESSION_MARKER_COOKIE = "__Host-grok_gate_session";

export function hasGateSessionMarker(): boolean {
  if (typeof document === "undefined") return false;
  return document.cookie
    .split(";")
    .some((pair) => pair.trim().startsWith(`${GATE_SESSION_MARKER_COOKIE}=`));
}
