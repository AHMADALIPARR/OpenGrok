# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Copyright (c) 2026 Ahmad Ali Parr. All rights reserved.
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
# JSONL-oriented rough audit, not a JSON parser.
# Usage: awk -f scripts/audit_tensor_dumps.awk dump.jsonl
BEGIN { records=0; bytes=0; bad=0 }
{
  records++
  bytes += length($0) + 1
  if ($0 !~ /"name"[[:space:]]*:/ || $0 !~ /"shape"[[:space:]]*:/ ||
      $0 !~ /"data"[[:space:]]*:/) bad++
}
END {
  printf "records=%d\napprox_bytes=%d\nrecords_missing_expected_fields=%d\n", records, bytes, bad
}
