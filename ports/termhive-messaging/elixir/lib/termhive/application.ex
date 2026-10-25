# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
defmodule TermHive.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TermHive.AgentRegistry,
      TermHive.Activity,
      TermHive.MessageRouter
    ]

    opts = [strategy: :one_for_one, name: TermHive.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
