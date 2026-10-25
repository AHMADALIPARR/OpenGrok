// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
export const CONNECTOR_TOKEN_HEADER = "x-connector-access-token";

export const CONNECTOR_TOKEN_PENDING_CODE = "connector_token_pending";

export const CONNECTOR_TOKEN_READY_EVENT = "grok:connector-token-ready";

export const ConnectorType = {
  GoogleDrive: "GoogleDrive",
  Gmail: "Gmail",
  GoogleCalendar: "GoogleCalendar",
  Outlook: "Outlook",
  OutlookCalendar: "OutlookCalendar",
  MicrosoftTeams: "MicrosoftTeams",
  Mcp: "Mcp",
} as const;

export type ConnectorTypeName =
  (typeof ConnectorType)[keyof typeof ConnectorType];

export const GoogleDriveTools = {
  search: "google_drive_search",
  readFile: "google_drive_read_file",
  listFolder: "google_drive_list_folder",
  createFolder: "google_drive_create_folder",
  trashFile: "google_drive_trash_file",
} as const;

export const GoogleCalendarTools = {
  listCalendars: "google_calendar_list_calendars",
  search: "google_calendar_search",
  getEvent: "google_calendar_get_event",
  availability: "google_calendar_availability",
} as const;

export type CallToolResult<T = unknown> = {
  ok: boolean;
  data: T | null;
  errorMessage?: string;
  loginRequired?: boolean;
  loginUrl?: string;
  pending?: boolean;
};

export type CallToolOptions = {
  connectorType: ConnectorTypeName;
  connectorCatalogId?: string;
  token?: string | null;
};

export type ToolArgs = Record<string, unknown>;
