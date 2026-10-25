# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
#
defmodule TermHive.Messaging do
  @moduledoc """
  Public API for the TermHive agent messaging system.
  """

  alias TermHive.{AgentRegistry, MessageRouter}

  def register_agent(agent), do: AgentRegistry.register(agent)
  def unregister_agent(id), do: AgentRegistry.unregister(id)

  def message_agent(from_id, target_query, message) do
    MessageRouter.message_agent(from_id, target_query, message)
  end

  def list_teammates(agent_id) do
    case AgentRegistry.get(agent_id) do
      nil -> []
      agent ->
        AgentRegistry.list_project(agent.project_id)
        |> Enum.reject(&(&1.id == agent_id))
        |> Enum.map(&%{id: &1.id, name: &1.name, role: &1.role, cli: &1.cli})
    end
  end

  def set_injector(fun), do: MessageRouter.set_injector(fun)
end
