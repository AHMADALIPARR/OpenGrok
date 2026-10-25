---
name: tool-calls
description: >
  Call the OpenGrok tools. Use when the agent needs to run Python
  (IPython) or a shell command (Bash). Triggers on "run", "execute",
  "compute", "shell", "python", "ipython", "bash".
metadata:
  short-description: "Call IPython and Bash tools"
  category: agent
  tier: core
  call: /tool-calls
---

# tool-calls

**Purpose:** Call the IPython and Bash tools from the main agent.

## When to use

- The user asks to run Python, compute something, or use IPython.
- The user asks to run a shell command.
- A workflow step needs a tool result before continuing.

## Tools

| Call | Argument | Returns |
|------|----------|---------|
| `ipython` | Python source | `{ok, result, error, engine}` |
| `bash` | shell command | `{ok, stdout, stderr, code}` |

## How to call

Dispatcher:

```bash
python3 tools/calls/dispatch.py ipython 'print(2+2)'
python3 tools/calls/dispatch.py bash 'uname -s'
```

From the Rust main agent:

```rust
use opengrok::tools;
let tc = tools::parse("ipython:print(2+2)").unwrap();
let r = tools::call("tools", &tc);
```

## What not to do

- Do not invent a tool name. Only `ipython` and `bash` are registered.
- Do not drop the result. Return `ok`, the output, and any error.
- Do not send secrets to either tool.

## Examples

```
/tool-calls ipython print(sum(range(10)))
/tool-calls bash echo hello
```
