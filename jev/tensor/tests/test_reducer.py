# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Copyright (c) 2026 Ahmad Ali Parr. All rights reserved.
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "reduce_to_gguf.py"
spec = importlib.util.spec_from_file_location("reducer", SCRIPT)
reducer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reducer)

class ReducerTests(unittest.TestCase):
    def test_mean(self):
        items = [
            {"name":"w","shape":[2],"dtype":"f32","data":[1.,3.],"source":"a"},
            {"name":"w","shape":[2],"dtype":"f32","data":[3.,5.],"source":"b"},
        ]
        result = reducer.reduce_group(items, "mean")
        self.assertEqual(result["data"], [2.,4.])

    def test_maxabs(self):
        items = [
            {"name":"w","shape":[2],"dtype":"f32","data":[-4.,2.],"source":"a"},
            {"name":"w","shape":[2],"dtype":"f32","data":[3.,-8.],"source":"b"},
        ]
        self.assertEqual(reducer.reduce_group(items, "maxabs")["data"], [-4.,-8.])

    def test_bad_shape(self):
        items = [
            {"name":"w","shape":[1],"dtype":"f32","data":[1.],"source":"a"},
            {"name":"w","shape":[2],"dtype":"f32","data":[1.,2.],"source":"b"},
        ]
        with self.assertRaises(ValueError):
            reducer.reduce_group(items, "mean")

    def test_gguf_header(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "test.gguf"
            tensor = {"name":"x","shape":[2],"data":[1.,2.]}
            blob = reducer.write_gguf(p, [tensor], "mean")
            self.assertEqual(blob[:4], b"GGUF")
            self.assertEqual(int.from_bytes(blob[4:8], "little"), 3)
            self.assertEqual(int.from_bytes(blob[8:16], "little"), 1)

if __name__ == "__main__":
    unittest.main()
