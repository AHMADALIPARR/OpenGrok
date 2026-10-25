defmodule TermHive.Activity do
  @moduledoc "Simple activity feed GenServer."
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def record(event), do: GenServer.cast(__MODULE__, {:record, event})
  def recent(limit \\ 50), do: GenServer.call(__MODULE__, {:recent, limit})

  @impl true
  def init(_), do: {:ok, []}

  @impl true
  def handle_cast({:record, event}, state) do
    {:noreply, [event | state] |> Enum.take(500)}
  end

  @impl true
  def handle_call({:recent, limit}, _from, state) do
    {:reply, Enum.take(state, limit), state}
  end
end
