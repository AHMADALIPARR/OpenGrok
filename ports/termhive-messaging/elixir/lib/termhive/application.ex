# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
#
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
