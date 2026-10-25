---
name: tool-calls
description: >
  Invoke IPython and Bash tools from the main OpenGrok agent.
  Triggers when the agent needs to run Python or a shell command.
metadata:
  short-description: "Tool calls: IPython and Bash"
  category: agent
  call: /tool-calls
---

# tool-calls

**Purpose:** Let the main OpenGrok agent dispatch tool calls to IPython and Bash.

## Tools

| Name | Arg | Returns |
|------|-----|---------|
| `ipython` | Python source | JSON `{ok, result, error, engine}` |
| `bash` | shell command | JSON `{ok, stdout, stderr, code}` |

## Call

From Rust:

```rust
let tc = tools::parse("ipython:print(2+2)").unwrap();
let r = tools::call("tools", &tc);
```

From the dispatcher:

```bash
python3 tools/calls/dispatch.py ipython 'print(2+2)'
python3 tools/calls/dispatch.py bash 'uname -s'
```

## Rules

- Do not call a tool that is not listed.
- Capture and return the tool result. Do not swallow errors.
- Prefer `ipython` for computation and `bash` for system commands.
