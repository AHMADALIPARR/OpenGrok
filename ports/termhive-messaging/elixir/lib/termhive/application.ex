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
