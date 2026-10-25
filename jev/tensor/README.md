# Recursive Tensor Reduction → GGUF

A deterministic utility that recursively discovers tensor dump files, reduces compatible tensors, and writes the reduced tensors to a GGUF v3 container.

## Input format

This implementation accepts `.json` tensor dumps shaped like:

```json
{
  "tensors": [
    {"name": "layer.weight", "shape": [2, 2], "dtype": "f32", "data": [1, 2, 3, 4]}
  ]
}
```

`data` is row-major F32/F64 numeric data. Supported reduction operations:
- `mean`: elementwise mean over tensors with identical names, shapes, and dtypes.
- `sum`: elementwise sum over tensors with identical names, shapes, and dtypes.
- `maxabs`: element with greatest absolute magnitude at each position.
- `first`: retain the first tensor for each key in deterministic path order.

This is a tensor-data reduction utility, not a model-training algorithm. Averaging arbitrary neural-network checkpoints can be invalid when parameter alignment or architecture differs. Inputs must be semantically compatible.

## Usage

```sh
python scripts/reduce_to_gguf.py INPUT_DIR OUTPUT.gguf --op mean
python scripts/reduce_to_gguf.py INPUT_DIR OUTPUT.gguf --op mean --manifest OUTPUT.manifest.json
```

Python is used only as an offline conversion/build utility; it is not part of the GGUF runtime. GGUF stores tensor metadata and raw payloads; the output is not guaranteed to load as a runnable model unless its architecture metadata, tensor names, shapes, and required metadata match a specific loader.

## GGUF details

The writer emits GGUF v3, F32 tensors, 32-byte aligned tensor data, deterministic ordering, and a SHA-256 manifest. It supports a conservative metadata subset and validates offsets before writing.
