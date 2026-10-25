defmodule TermHive.AgentRegistry do
  @moduledoc """
  GenServer that tracks registered agents (presence).
  """
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def register(agent), do: GenServer.call(__MODULE__, {:register, agent})
  def unregister(id), do: GenServer.call(__MODULE__, {:unregister, id})
  def get(id), do: GenServer.call(__MODULE__, {:get, id})
  def list_project(project_id), do: GenServer.call(__MODULE__, {:list_project, project_id})
  def all, do: GenServer.call(__MODULE__, :all)

  @impl true
  def init(_), do: {:ok, %{}}

  @impl true
  def handle_call({:register, agent}, _from, state) do
    {:reply, :ok, Map.put(state, agent.id, agent)}
  end

  def handle_call({:unregister, id}, _from, state) do
    {:reply, :ok, Map.delete(state, id)}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end

  def handle_call({:list_project, project_id}, _from, state) do
    agents =
      state
      |> Map.values()
      |> Enum.filter(&(&1.project_id == project_id))

    {:reply, agents, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, Map.values(state), state}
  end
end
