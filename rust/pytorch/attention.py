# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later
"""PyTorch attention sidecar. Used when torch is installed."""
try:
    import torch
    HAS_TORCH = True
except ImportError:
    HAS_TORCH = False

def attention(q, k, v):
    if not HAS_TORCH:
        raise RuntimeError("torch not installed")
    q, k, v = map(torch.tensor, (q, k, v))
    d = q.shape[-1] ** 0.5
    scores = q @ k.transpose(-2, -1) / d
    weights = torch.softmax(scores, dim=-1)
    return (weights @ v).tolist()

if __name__ == "__main__":
    print("torch available:", HAS_TORCH)
    if HAS_TORCH:
        print(attention([[1,0],[0,1]], [[1,0],[0,1]], [[2,3],[4,5]]))
