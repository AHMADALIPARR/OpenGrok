// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
import type { LocationRewrite } from "@tanstack/react-router";

/**
 * Path-based preview hosts serve the dev server under `/{port_id}/` and strip
 * that prefix before forwarding, so SSR sees `/` while the browser URL keeps the
 * prefix. TanStack Start resets `basepath` on hydration, so a `rewrite` keeps
 * client routing and generated links aligned with the public URL.
 */
const PATH_BASED_PREVIEW_HOSTS = new Set([
  "preview.grok.genai.mil",
  "preview.grok.mil",
  "preview.grokgsac.com",
]);

const PORT_ID_PREFIX = /^\/hds-[a-z0-9]+-\d+-[a-z0-9]+(?=\/|$)/i;

export function previewPathPrefix(hostname: string, pathname: string): string | undefined {
  if (!PATH_BASED_PREVIEW_HOSTS.has(hostname.toLowerCase())) return undefined;
  return PORT_ID_PREFIX.exec(pathname)?.[0];
}

export function prefixRewrite(prefix: string): LocationRewrite {
  return {
    input: ({ url }) => {
      if (url.pathname === prefix) url.pathname = "/";
      else if (url.pathname.startsWith(`${prefix}/`))
        url.pathname = url.pathname.slice(prefix.length);
      return url;
    },
    output: ({ url }) => {
      url.pathname = `${prefix}${url.pathname}`;
      return url;
    },
  };
}

export function previewPathRewrite(): LocationRewrite | undefined {
  if (typeof window === "undefined") return undefined;
  const prefix = previewPathPrefix(window.location.hostname, window.location.pathname);
  return prefix ? prefixRewrite(prefix) : undefined;
}
