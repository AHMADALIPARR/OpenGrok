// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
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
