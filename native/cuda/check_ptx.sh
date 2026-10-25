#!/usr/bin/env bash
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
