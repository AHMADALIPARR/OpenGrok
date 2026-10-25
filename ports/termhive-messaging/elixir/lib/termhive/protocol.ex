# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
defmodule TermHive.Protocol do
  @moduledoc """
  Message types matching TermHive's agent messaging contract.
  """

  @doc "Format a message as it appears in the target agent's terminal."
  def format_injection(from_name, message) do
    "[Message from #{from_name}]: #{message}"
  end
end
