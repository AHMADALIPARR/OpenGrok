#!/bin/sh
# Launch the KSB+ test suite on an ngn/k (growler fork) interpreter.
# This script only starts the K runtime. It does not implement database operations.
set -e
cd "$(dirname "$0")/.."
if [ -z "${K:-}" ]; then
  if [ -x /tmp/growler-k/k ]; then
    K=/tmp/growler-k/k
  elif command -v k >/dev/null 2>&1; then
    K=k
  else
    echo "Set K to an ngn/k binary. Build: git clone https://codeberg.org/growler/k.git && make k CC=gcc" >&2
    exit 2
  fi
fi
echo "K=$K"
"$K" t/t_binary.k
