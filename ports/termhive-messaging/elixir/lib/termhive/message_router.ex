defmodule TermHive.MessageRouter do
  @moduledoc """
  Routes messages between agents and injects them into the target's input.
  Default injector writes to the local terminal (stdout).
  Fuzzy matching on name and role (case-insensitive, partial).
  """
  use GenServer

  alias TermHive.{AgentRegistry, Protocol, Activity}

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def message_agent(from_id, target_query, message) do
    GenServer.call(__MODULE__, {:message, from_id, target_query, message})
  end

  def set_injector(fun), do: GenServer.call(__MODULE__, {:set_injector, fun})

  @impl true
  def init(_) do
    {:ok, %{injector: &terminal_injector/2}}
  end

  @impl true
  def handle_call({:set_injector, fun}, _from, state) do
    {:reply, :ok, %{state | injector: fun}}
  end

  def handle_call({:message, from_id, target_query, message}, _from, state) do
    case AgentRegistry.get(from_id) do
      nil ->
        {:reply, {:error, :unknown_sender}, state}

      from_agent ->
        teammates =
          AgentRegistry.list_project(from_agent.project_id)
          |> Enum.reject(&(&1.id == from_id))

        case resolve_target(teammates, target_query) do
          nil ->
            {:reply, {:error, :no_match}, state}

          target ->
            text = Protocol.format_injection(from_agent.name, message)
            state.injector.(target.id, text)

            Activity.record(%{
              id: UUID.uuid4(),
              project_id: from_agent.project_id,
              event: :agent_message,
              from_agent: from_agent.name,
              to_agent: target.name,
              message: message,
              timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
            })

            {:reply, {:ok, %{delivered: true, to: target.name}}, state}
        end
    end
  end

  defp resolve_target(teammates, query) do
    q = String.downcase(query)

    Enum.find(teammates, fn a ->
      String.downcase(a.name) == q or
        (a.role && String.downcase(a.role) == q) or
        String.contains?(String.downcase(a.name), q) or
        (a.role && String.contains?(String.downcase(a.role), q))
    end)
  end

  # Default: write the injection to the local terminal session.
  defp terminal_injector(agent_id, text) do
    IO.puts(:stdio, "[inject → #{agent_id}] #{text}")
    :ok
  end
end
