/ Copyright (C) 2026 AHMAD ALI PARR
/ SPDX-License-Identifier: AGPL-3.0-or-later
/ Holographic append-only ledger on KSB+ Layer 0.
/ Single-line for ngn/k. Uses codec.k. Each tick is one KSB+ envelope.

\l src/codec.k

POLY:3988292384
b32:{[x]; (-32)#bits64 x}
from32:{[b]; 2/b}
xor32:{[a;b]; from32[~((b32 a)=(b32 b))]}
shr32:{[a]; from32 32#(0, b32 a)}
shr8:{[a]; from32 32#(8#0), b32 a}
low8:{[a]; from32 (-8)#b32 a}
crcbyte:{[c]; {$[*|b32 x; xor32[shr32 x; POLY]; shr32 x]}/[8;c]}
CRCT:{crcbyte x}'!256
crc32:{[bs]; c:{[a;ch]; xor32[shr8 a; CRCT low8 xor32[a; `i$ch]]}/[4294967295; bs]; xor32[c; 4294967295]}

envenc:{[p]; c:crc32 p; h:"KSB+",(u16enc[1][1]),(u16enc[20][1]),(u16enc[0][1]),(u16enc[0][1]),(u32enc[#p][1]),(u32enc[c][1]); (`ok; h,p)}

envdec:{[b]
 $[~(4#b)~"KSB+"; (`err;"magic"); envdec2 b]}
envdec2:{[b]
 plen:u32dec[b;12][1]
 crc:u32dec[b;16][1]
 pay:plen#20_b
 $[~(crc32[pay])~crc; (`err;"checksum"); (`ok; pay)]}

tickenc:{[t]; (`ok; (u64enc[0;t[0]][1]),(u8enc t[1])[1],(u8enc t[2])[1],(u64enc[0;t[3]][1]),(u64enc[0;t[4]][1]),(u64enc[0;t[5]][1]),(u32enc t[6])[1],(u8enc t[7])[1],t[8])}

tickdec:{[b]
 ts:u64dec[b;0]
 k:u8dec[b;ts[3]]
 s:u8dec[b;k[2]]
 p:u64dec[b;s[2]]
 z:u64dec[b;p[3]]
 o:u64dec[b;z[3]]
 c:u32dec[b;o[3]]
 n:u8dec[b;c[2]]
 sym:n[1]#n[2]_b
 (`ok; (ts[2];k[1];s[1];p[2];z[2];o[2];c[1];n[1];sym))}

seal:{[t]; e:tickenc t; envenc e[1]}
open:{[env]; p:envdec env; $[`err~*p; p; open2 p]}
open2:{[p]; d:tickdec p[1]; (`ok; d[1]; crc32 p[1])}

verify2:{[a;b]
 oa:open a
 ob:open b
 $[`err~*oa; 0; `err~*ob; 0; ~(oa[1][6]~0); 0; ~(ob[1][6]~oa[2]); 0; 1]}
