# tools/

**Purpose:** Callable tools for Grok Bots and the OpenGrok core.

| Tool | Path | What it does |
|------|------|--------------|
| IPython | `ipython/tool.py` | Runs Python. Uses IPython when installed, otherwise a plain exec namespace. |
| Bash | `bash/tool.sh` | Runs a shell command. Returns stdout, stderr, and exit code as JSON. |
| Tool calls | `calls/dispatch.py` | Routes a named call to IPython or Bash. |

## Run

```bash
python3 tools/ipython/tool.py 'print(2+2)'
bash tools/bash/tool.sh 'echo hello'
python3 tools/calls/dispatch.py ipython 'print(6*7)'
python3 tools/calls/dispatch.py bash 'uname -s'
```
