defmodule TermHive.Protocol do
  @moduledoc """
  Message types matching TermHive's agent messaging contract.
  Ported from src/types.ts and src/daemon/protocol.ts.
  """

  defmodule Agent do
    @type t :: %{
            id: String.t(),
            project_id: String.t(),
            name: String.t(),
            role: String.t() | nil,
            cli: :claude | :codex | :gemini | :opencode,
            status: :stopped | :running | :idle | :awaiting_input
          }
  end

  defmodule AgentMessage do
    @type t :: %{
            from_agent_id: String.t(),
            from_agent_name: String.t(),
            to_agent_id: String.t(),
            to_agent_name: String.t(),
            message: String.t(),
            timestamp: String.t()
          }
  end

  defmodule ActivityEvent do
    @type t :: %{
            id: String.t(),
            project_id: String.t(),
            event: :agent_message | :agent_started | :agent_stopped,
            from_agent: String.t() | nil,
            to_agent: String.t() | nil,
            message: String.t() | nil,
            timestamp: String.t()
          }
  end

  @doc "Format a message as it appears in the target agent's input."
  def format_injection(from_name, message) do
    "[Message from #{from_name}]: #{message}"
  end
end
