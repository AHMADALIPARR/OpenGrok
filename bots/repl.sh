#!/usr/bin/env bash
# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Local REPL that verifies the bots/ GGUF contract.
# Refuses to fall back to any cloud endpoint.
set -euo pipefail

BASE="${OPENAI_BASE_URL:-http://127.0.0.1:8080/v1}"
KEY="${OPENAI_API_KEY:-local}"

echo "=== bots/ GGUF handshake ==="
echo "base: $BASE"

# Refuse cloud
if echo "$BASE" | grep -qiE 'api\.x\.ai|openai\.com|anthropic|googleapis'; then
  echo "FAIL: base URL looks like a cloud endpoint. Refusing."
  exit 2
fi

# Confirm microagent runners if available
if command -v microagent >/dev/null 2>&1; then
  echo "-- microagent model runners --"
  microagent model runners || true
  echo "-- microagent model list --"
  microagent model list || true
else
  echo "WARN: microagent not on PATH; checking endpoint only"
fi

# Probe the local OpenAI-compatible endpoint
code=$(curl -s -o /tmp/models.json -w '%{http_code}' \
  -H "Authorization: Bearer $KEY" \
  "$BASE/models" || true)

if [ "$code" != "200" ]; then
  echo "FAIL: local endpoint $BASE/models returned $code"
  echo "Start a runner first: microagent model serve <hf-ref>"
  exit 1
fi

echo "PASS: local models endpoint responded"
python3 - << 'PY'
import json
d=json.load(open("/tmp/models.json"))
print("models:", [m.get("id") for m in d.get("data", [])])
PY

# One chat completion against the local model only
echo "-- chat completion --"
curl -s -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"local","messages":[{"role":"user","content":"ping"}]}' \
  "$BASE/chat/completions" | python3 -m json.tool | head -40

echo "PASS: local handshake complete (no cloud fallback)"
