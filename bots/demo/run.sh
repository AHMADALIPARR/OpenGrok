#!/usr/bin/env bash
# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
set -euo pipefail
BASE="http://127.0.0.1:8080/v1"
KEY="local"

echo "=== 1. Handshake ==="
code=$(curl -s -o /tmp/models.json -w '%{http_code}' -H "Authorization: Bearer $KEY" "$BASE/models")
echo "models status: $code"
python3 -c 'import json; print("models:", [m["id"] for m in json.load(open("/tmp/models.json"))["data"]])'

echo "=== 2. Demo turns ==="
for msg in "ping" "what is 2+2" "summarize: grok bots local gguf"; do
  start=$(date +%s%N)
  curl -s -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" \
    -d "{\"model\":\"local\",\"messages\":[{\"role\":\"user\",\"content\":\"$msg\"}]}" \
    "$BASE/chat/completions" > /tmp/chat.json
  end=$(date +%s%N)
  ms=$(( (end-start)/1000000 ))
  text=$(python3 -c 'import json; print(json.load(open("/tmp/chat.json"))["choices"][0]["message"]["content"])')
  echo "Q: $msg"
  echo "A: $text  (${ms} ms)"
done

echo "=== 3. Benchmark (20 turns) ==="
start=$(date +%s%N)
for i in $(seq 1 20); do
  curl -s -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" \
    -d "{\"model\":\"local\",\"messages\":[{\"role\":\"user\",\"content\":\"bench $i\"}]}" \
    "$BASE/chat/completions" >/dev/null
done
end=$(date +%s%N)
total_ms=$(( (end-start)/1000000 ))
echo "20 turns in ${total_ms} ms  ($(( 20000/total_ms )) turns/sec approx)"

echo "=== 4. Server stats ==="
curl -s http://127.0.0.1:8080/stats | python3 -m json.tool

echo "=== DONE ==="
