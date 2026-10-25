# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
#
defmodule TermHive.Protocol do
  @moduledoc """
  Message types matching TermHive's agent messaging contract.
  """

  @doc "Format a message as it appears in the target agent's terminal."
  def format_injection(from_name, message) do
    "[Message from #{from_name}]: #{message}"
  end
end
