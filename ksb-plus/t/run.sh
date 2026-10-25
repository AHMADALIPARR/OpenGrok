#!/bin/sh
# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
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

"$K" t/t_ledger.k
