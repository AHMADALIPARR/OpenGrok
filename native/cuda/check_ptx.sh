#!/usr/bin/env bash
# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
#
set -euo pipefail
PTX="${1:-native/cuda/tma.ptx}"
echo "=== PTX compile check ==="
echo "file: $PTX"
echo "target: sm_80 (RTX 3080 / Ampere)"
if ! command -v nvcc >/dev/null 2>&1; then
  echo "FAIL: nvcc not on PATH"
  exit 1
fi
nvcc -arch=sm_80 -ptx "$PTX" -o /tmp/tma_sm80_out.ptx
echo "PASS: nvcc -arch=sm_80 -ptx succeeded"
echo "output: /tmp/tma_sm80_out.ptx"
