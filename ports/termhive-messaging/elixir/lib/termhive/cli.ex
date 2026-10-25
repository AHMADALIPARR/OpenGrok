defmodule TermHive.CLI do
  @moduledoc """
  CLI entry for TermHive.MessageRouter.
  Routes a message and writes the injection directly to the local terminal (stdout).
  """

  alias TermHive.{AgentRegistry, MessageRouter, Protocol}

  def main(args) do
    # Start the registry and router so the CLI owns the processes.
    {:ok, _} = AgentRegistry.start_link([])
    {:ok, _} = TermHive.Activity.start_link([])
    {:ok, _} = MessageRouter.start_link([])

    # Force the injector to write to the local terminal.
    MessageRouter.set_injector(&terminal_injector/2)

    case args do
      ["send", from_id, target, message] ->
        ensure_demo_agents()
        case MessageRouter.message_agent(from_id, target, message) do
          {:ok, %{to: name}} ->
            IO.puts(:stdio, "delivered to #{name}")
            System.halt(0)
          {:error, reason} ->
            IO.puts(:stderr, "error: #{reason}")
            System.halt(1)
        end

      ["demo"] ->
        ensure_demo_agents()
        MessageRouter.message_agent("a1", "bob", "hello from the CLI")
        System.halt(0)

      _ ->
        IO.puts(:stderr, "usage: termhive send <from_id> <target> <message>")
        IO.puts(:stderr, "       termhive demo")
        System.halt(2)
    end
  end

  # Writes the routed message straight to the local terminal session.
  defp terminal_injector(agent_id, text) do
    IO.puts(:stdio, "[inject → #{agent_id}] #{text}")
    :ok
  end

  defp ensure_demo_agents do
    AgentRegistry.register(%{
      id: "a1", project_id: "p1", name: "alice", role: "dev",
      cli: :opencode, status: :running
    })
    AgentRegistry.register(%{
      id: "a2", project_id: "p1", name: "bob", role: "reviewer",
      cli: :opencode, status: :running
    })
  end
end
