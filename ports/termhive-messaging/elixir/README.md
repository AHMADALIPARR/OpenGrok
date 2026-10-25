# TermHive Elixir — CLI entry

**Purpose:** Route agent messages and write them directly into the local terminal session.

## CLI

```bash
cd ports/termhive-messaging/elixir
mix escript.build
./termhive send a1 bob "hello from the CLI"
./termhive demo
```

Output goes to stdout of the current terminal:

```
[inject → a2] [Message from alice]: hello from the CLI
delivered to bob
```

`MessageRouter` default injector is `terminal_injector/2`, which calls `IO.puts(:stdio, ...)`.
