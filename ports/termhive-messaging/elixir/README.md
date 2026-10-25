# TermHive Messaging — Elixir Port

Port of the agent-to-agent messaging system from https://github.com/0x0funky/TermHive

## What was ported

The core messaging contract:

- Agents in the same project can send messages to each other
- `message_agent(target, message)` delivers the message into the target agent's input stream as `[Message from <from>]: <message>`
- `list_teammates()` returns the other agents in the project
- Fuzzy name/role matching for targets
- Activity feed records every message
- One-way notifications (no blocking reply required)

## Architecture

```
lib/termhive/
├── application.ex          # OTP application
├── messaging.ex            # Public API
├── agent_registry.ex       # GenServer — agent presence
├── message_router.ex       # GenServer — routing + injection
├── activity.ex             # GenServer — activity feed
└── protocol.ex             # Message types
```

Uses pure OTP (no Phoenix required for the core). Can be wrapped in Phoenix.PubSub or Channels for the web UI.

## Usage

```elixir
# Start the application (or add to a supervision tree)
{:ok, _} = TermHive.Application.start(:normal, [])

# Register agents
TermHive.Messaging.register_agent(%{
  id: "a1", project_id: "p1", name: "Frontend", role: "ui", cli: :claude
})
TermHive.Messaging.register_agent(%{
  id: "a2", project_id: "p1", name: "Backend", role: "api", cli: :codex
})

# Send a message (fuzzy match on name/role)
TermHive.Messaging.message_agent("a1", "backend", "API is done, spec in shared/auth.md")
# => delivers to Backend as "[Message from Frontend]: API is done..."

# List teammates
TermHive.Messaging.list_teammates("a1")
# => [%{id: "a2", name: "Backend", role: "api", cli: :codex}]
```

## Injection point

In the original TermHive the delivery writes into the target PTY. Here `MessageRouter` calls a configurable injector (default: log + ETS store). Plug in your own:

```elixir
TermHive.Messaging.set_injector(fn agent_id, text ->
  # write `text` into the agent's input stream / PTY / GenServer mailbox
  :ok
end)
```
