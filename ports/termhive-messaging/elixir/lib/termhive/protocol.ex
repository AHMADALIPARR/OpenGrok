defmodule TermHive.Protocol do
  @moduledoc """
  Message types matching TermHive's agent messaging contract.
  """

  @doc "Format a message as it appears in the target agent's terminal."
  def format_injection(from_name, message) do
    "[Message from #{from_name}]: #{message}"
  end
end
