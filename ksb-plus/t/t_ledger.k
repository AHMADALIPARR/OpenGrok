/ Copyright (C) 2026 AHMAD ALI PARR
/ SPDX-License-Identifier: AGPL-3.0-or-later
/ Holographic ledger on KSB+. Round-trip and chain check.

e1:seal[0;1000;0;0;350000000000;0;10;0;101;0;"ETH-USD"]
$[ `err~*e1; -1 "seal1 failed"; ]
o1:open e1[1]
$[ `err~*o1; -1 "open1 failed"; ]
crc1:o1[2]

e2:seal[0;1100;0;1;350100000000;0;8;0;102;crc1;"ETH-USD"]
$[ `err~*e2; -1 "seal2 failed"; ]

envs:(e1[1]; e2[1])
$[ verify envs; 0 "PASS ledger chain"; -1 "FAIL ledger chain"]
