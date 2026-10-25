// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
//
export {
  CONNECTOR_TOKEN_HEADER,
  ConnectorType,
  GoogleCalendarTools,
  GoogleDriveTools,
} from "./types.ts";
export type {
  CallToolOptions,
  CallToolResult,
  ConnectorTypeName,
  ToolArgs,
} from "./types.ts";
export {
  isConnectorPending,
  isLoginRequired,
  redirectToLoginIfRequired,
} from "./login.ts";
export { classifyCallToolError } from "./errors.ts";
export type { CallToolErrorKind, CallToolErrorState } from "./errors.ts";
export { useRefetchWhenConnectorReady } from "./use-connector-readiness.ts";
export type { ConnectorWaitStatus } from "./use-connector-readiness.ts";
