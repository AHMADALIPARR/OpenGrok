#!/usr/bin/env bash
# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
# Bash tool. Runs a command and returns stdout, stderr, and exit code as JSON.
set -u
cmd="${1:-}"
if [ -z "$cmd" ]; then
  echo '{"ok":false,"stdout":"","stderr":"no command","code":2}'
  exit 2
fi
stdout=$(mktemp)
stderr=$(mktemp)
bash -c "$cmd" >"$stdout" 2>"$stderr"
code=$?
python3 - "$code" "$stdout" "$stderr" << 'PY'
import json, sys
code = int(sys.argv[1])
out = open(sys.argv[2]).read()
err = open(sys.argv[3]).read()
print(json.dumps({"ok": code == 0, "stdout": out, "stderr": err, "code": code}))
PY
rm -f "$stdout" "$stderr"
