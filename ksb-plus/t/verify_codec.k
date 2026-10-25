/ Copyright (C) 2026 AHMAD ALI PARR
/ SPDX-License-Identifier: AGPL-3.0-or-later
/
/ This program is free software: you can redistribute it and/or modify
/ it under the terms of the GNU Affero General Public License as published
/ by the Free Software Foundation, either version 3 of the License, or
/ (at your option) any later version.
\l src/codec.k
P:0
F:0
pass:{[n]; `0:"PASS ",n; P::P+1}
fail:{[n]; `0:"FAIL ",n; F::F+1}
chk:{[n;v]; $[v~1; pass n; fail n]}

chk["u8 0"; u8dec[u8enc[0][1];0][1]~0]
chk["u8 1"; u8dec[u8enc[1][1];0][1]~1]
chk["u8 127"; u8dec[u8enc[127][1];0][1]~127]
chk["u8 128"; u8dec[u8enc[128][1];0][1]~128]
chk["u8 255"; u8dec[u8enc[255][1];0][1]~255]
chk["u16 0"; u16dec[u16enc[0][1];0][1]~0]
chk["u16 258"; u16dec[u16enc[258][1];0][1]~258]
chk["u16 max"; u16dec[u16enc[65535][1];0][1]~65535]
chk["u32"; u32dec[u32enc[16909060][1];0][1]~16909060]
chk["u32 max"; u32dec[u32enc[4294967295][1];0][1]~4294967295]
d:u64dec[u64enc[1;2][1];0]
chk["u64"; (d[1]~1)&(d[2]~2)]
d:u64dec[u64enc[U32MAX;U32MAX][1];0]
chk["u64 max"; (d[1]~U32MAX)&(d[2]~U32MAX)]
chk["i8 -1"; i8dec[i8enc[-1][1];0][1]~-1]
chk["i8 min"; i8dec[i8enc[-128][1];0][1]~-128]
chk["i8 max"; i8dec[i8enc[127][1];0][1]~127]
chk["i16 min"; i16dec[i16enc[-32768][1];0][1]~-32768]
chk["i32 -2"; i32dec[i32enc[-2][1];0][1]~-2]
chk["i32 min"; i32dec[i32enc[-2147483648][1];0][1]~-2147483648]
chk["u8 range"; `err~*u8enc[256]]
chk["u16 range"; `err~*u16enc[65536]]
chk["u32 neg"; `err~*u32enc[-1]]
chk["i8 range"; `err~*i8enc[128]]

`0:"TOTAL pass ",`k@P
`0:"TOTAL fail ",`k@F
`exit@$[F=0;0;1]
