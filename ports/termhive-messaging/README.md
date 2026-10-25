# TermHive Messaging Ports

Ports of the agent-to-agent messaging system from https://github.com/0x0funky/TermHive

## Ports

| Language | Path | Notes |
|----------|------|-------|
| Elixir | `elixir/` | OTP GenServers (AgentRegistry, MessageRouter, Activity). Pure OTP, no Phoenix required. |
| PHP | `php/` | Single class, in-memory. Drop-in for any PHP process or framework. |

## Shared contract

- Register agents with `id`, `project_id`, `name`, `role`, `cli`
- `message_agent(from_id, target_query, message)` — fuzzy match on name/role, injects `[Message from <name>]: <msg>` into the target
- `list_teammates(agent_id)`
- Configurable injector so you can write into a PTY, stdin, queue, or GenServer mailbox
- Activity feed records every delivery

The original TermHive delivers by writing into the target agent's PTY. These ports keep the same contract and leave the injection point pluggable.
