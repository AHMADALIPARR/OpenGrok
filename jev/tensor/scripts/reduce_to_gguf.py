#!/usr/bin/env python3
"""Recursively reduce JSON tensor dumps and write a GGUF v3 tensor container."""
from __future__ import annotations
import argparse
import hashlib
import json
import math
import struct
import sys
from pathlib import Path

ALIGNMENT = 32
GGUF_VERSION = 3
GGML_TYPE_F32 = 0
DTYPE_WIDTH = {"f32": 4, "float32": 4, "f64": 8, "float64": 8}

def product(shape):
    n = 1
    for d in shape:
        if not isinstance(d, int) or isinstance(d, bool) or d <= 0:
            raise ValueError(f"invalid tensor dimension: {d!r}")
        n *= d
        if n > (1 << 40):
            raise ValueError("tensor element count exceeds safety limit")
    return n

def load_dump(path: Path):
    obj = json.loads(path.read_text(encoding="utf-8"))
    entries = obj.get("tensors")
    if not isinstance(entries, list):
        raise ValueError(f"{path}: expected a 'tensors' list")
    result = []
    for item in entries:
        name, shape, dtype, data = (item.get(k) for k in ("name", "shape", "dtype", "data"))
        if not isinstance(name, str) or not name or "\x00" in name:
            raise ValueError(f"{path}: invalid tensor name")
        if dtype not in DTYPE_WIDTH:
            raise ValueError(f"{path}: unsupported dtype {dtype!r} for {name}")
        expected = product(shape)
        if not isinstance(data, list) or len(data) != expected:
            raise ValueError(f"{path}: {name}: expected {expected} elements")
        vals = []
        for x in data:
            if not isinstance(x, (int, float)) or isinstance(x, bool) or not math.isfinite(x):
                raise ValueError(f"{path}: {name}: non-finite or non-numeric value")
            vals.append(float(x))
        result.append({"name": name, "shape": shape, "dtype": dtype, "data": vals, "source": str(path)})
    return result

def discover(directory: Path):
    return sorted((p for p in directory.rglob("*.json") if p.is_file()), key=lambda p: p.as_posix())

def reduce_group(items, op):
    first = items[0]
    for item in items[1:]:
        if item["shape"] != first["shape"] or item["dtype"] != first["dtype"]:
            raise ValueError(f"incompatible tensor group {first['name']}: shape/dtype mismatch")
    rows = [item["data"] for item in items]
    if op == "first":
        out = rows[0][:]
    elif op == "mean":
        count = len(rows)
        out = [sum(row[i] for row in rows) / count for i in range(len(rows[0]))]
    elif op == "sum":
        out = [sum(row[i] for row in rows) for i in range(len(rows[0]))]
    elif op == "maxabs":
        out = [max((row[i] for row in rows), key=lambda v: abs(v)) for i in range(len(rows[0]))]
    else:
        raise ValueError(f"unsupported reduction op: {op}")
    if not all(math.isfinite(x) for x in out):
        raise ValueError(f"reduction produced non-finite values for {first['name']}")
    return {**first, "data": out, "sources": [x["source"] for x in items], "reduction": op}

def u64s(s):
    b = s.encode("utf-8")
    return struct.pack("<Q", len(b)) + b

def kv_string(key, value):
    return u64s(key) + struct.pack("<I", 8) + u64s(value)

def kv_u32(key, value):
    return u64s(key) + struct.pack("<I", 4) + struct.pack("<I", value)

def align_up(n, alignment):
    return (n + alignment - 1) // alignment * alignment

def write_gguf(path, tensors, op):
    # The converter intentionally emits F32 for all tensors; source f64 is downcast explicitly.
    packed = []
    for t in tensors:
        raw = struct.pack("<" + "f" * len(t["data"]), *t["data"])
        packed.append({"name": t["name"], "shape": t["shape"], "raw": raw})
    metadata = [
        kv_string("general.architecture", "generic"),
        kv_string("general.name", "Recursive Tensor Reduction"),
        kv_string("general.description", "Reduced tensor dump; verify architecture compatibility before model use."),
        kv_string("reduction.operation", op),
        kv_u32("reduction.source_count", len({s for t in tensors for s in t.get("sources", [])})),
        kv_u32("reduction.tensor_count", len(tensors)),
        kv_u32("general.alignment", ALIGNMENT),
    ]
    header = bytearray(b"GGUF" + struct.pack("<IQQ", GGUF_VERSION, len(packed), len(metadata)))
    header += b"".join(metadata)
    offset = 0
    info = bytearray()
    for t in packed:
        info += u64s(t["name"])
        info += struct.pack("<I", len(t["shape"]))
        for d in t["shape"]:
            info += struct.pack("<Q", d)
        info += struct.pack("<IQ", GGML_TYPE_F32, offset)
        offset = align_up(offset + len(t["raw"]), ALIGNMENT)
    header += info
    data_start = align_up(len(header), ALIGNMENT)
    blob = header + b"\x00" * (data_start - len(header))
    for t in packed:
        blob += t["raw"]
        blob += b"\x00" * (align_up(len(blob), ALIGNMENT) - len(blob))
    path.write_bytes(blob)
    return blob

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input_dir", type=Path)
    ap.add_argument("output", type=Path)
    ap.add_argument("--op", choices=("mean", "sum", "maxabs", "first"), default="mean")
    ap.add_argument("--manifest", type=Path)
    args = ap.parse_args()
    if not args.input_dir.is_dir():
        ap.error("input_dir must be an existing directory")
    files = discover(args.input_dir)
    if not files:
        ap.error("no JSON tensor dumps found")
    grouped = {}
    for path in files:
        for t in load_dump(path):
            key = (t["name"], tuple(t["shape"]), t["dtype"])
            grouped.setdefault(key, []).append(t)
    # Same name with mismatched shape/dtype is a hard error rather than silent omission.
    by_name = {}
    for key in grouped:
        by_name.setdefault(key[0], set()).add((key[1], key[2]))
    conflicts = [name for name, signatures in by_name.items() if len(signatures) > 1]
    if conflicts:
        raise SystemExit("incompatible shape/dtype for tensor name(s): " + ", ".join(sorted(conflicts)))
    reduced = [reduce_group(grouped[k], args.op) for k in sorted(grouped, key=lambda k: (k[0], k[1], k[2]))]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    blob = write_gguf(args.output, reduced, args.op)
    manifest = {
        "format": "GGUF v3",
        "output": str(args.output),
        "bytes": len(blob),
        "sha256": hashlib.sha256(blob).hexdigest(),
        "operation": args.op,
        "source_files": [str(p) for p in files],
        "source_count": len(files),
        "tensor_count": len(reduced),
        "tensors": [
            {"name": t["name"], "shape": t["shape"], "dtype_written": "F32",
             "source_dtype": t["dtype"], "source_files": t["sources"]}
            for t in reduced
        ],
        "warning": "GGUF structural output does not establish compatibility with a particular model architecture or semantic quality."
    }
    mpath = args.manifest or args.output.with_suffix(".manifest.json")
    mpath.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"output": str(args.output), "bytes": len(blob), "sha256": manifest["sha256"],
                      "source_files": len(files), "tensor_count": len(reduced), "manifest": str(mpath)}, indent=2))

if __name__ == "__main__":
    main()
