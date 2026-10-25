/ Copyright (C) 2026 AHMAD ALI PARR
/ SPDX-License-Identifier: AGPL-3.0-or-later
/
/ This program is free software: you can redistribute it and/or modify
/ it under the terms of the GNU Affero General Public License as published
/ by the Free Software Foundation, either version 3 of the License, or
/ (at your option) any later version.
\l src/binary.k
P:0
F:0
pass:{[n] `0:"PASS ",n; P::P+1}
fail:{[n] `0:"FAIL ",n; F::F+1}
eq:{[n;a;b] $[a~b; pass n; fail n," expected ",(`k@b)," got ",`k@a]}
err:{[n;r;c] $[(`err~*r)&c~r[1]; pass n; fail n," got ",`k@r]}
ok1:{[n;r;v] $[(`ok~*r)&v~r[1]; pass n; fail n," got ",`k@r]}

eq["runtime 0N is min int"; 0N; -9223372036854775807-1]
eq["runtime max+1 is 0N"; 0N; 9223372036854775807+1]
eq["runtime 0N+1 is not null"; 0; 0N~0N+1]
eq["runtime subnormal survives"; 0; ({x%2}/[1074;1.0])~0.0]
eq["runtime 2^52 exact"; 4503599627370496; 2/1,52#0]
eq["fb of BE 1.0"; 1.0; `fb@0x3ff0000000000000]

ok1["u8 0"; u8enc 0; 0x00]
ok1["u8 255"; u8enc 255; 0xff]
err["u8 256"; u8enc 256; "range"]
err["u8 -1"; u8enc -1; "range"]
err["u8 0N"; u8enc 0N; "range"]
err["u8 type"; u8enc 1.0; "type"]
eq["u8 all"; 1; &/{(u8enc[x][1]~`c$(,x))&(u8dec[u8enc[x][1];0][1]~x)}'!256]

ok1["u16 258"; u16enc 258; 0x0102]
ok1["u16 max"; u16enc 65535; 0xffff]
err["u16 65536"; u16enc 65536; "range"]
eq["u16 rt"; 1; &/{u16dec[u16enc[x][1];0][1]~x}'0 1 2 127 128 255 256 1000 32767 32768 65535]

ok1["u32 16909060"; u32enc 16909060; 0x01020304]
ok1["u32 max"; u32enc 4294967295; 0xffffffff]
err["u32 neg"; u32enc -1; "range"]
eq["u32 rt"; 16909060; u32dec[u32enc[16909060][1];0][1]]

ok1["u64"; u64enc[1;2]; 0x0000000100000002]
eq["u64 rt"; (1;2); (u64dec[u64enc[1;2][1];0][1]; u64dec[u64enc[1;2][1];0][2])]
err["u64 hi range"; u64enc[4294967296;0]; "range"]
eq["u64 max"; (U32MAX;U32MAX); (u64dec[u64enc[U32MAX;U32MAX][1];0][1]; u64dec[u64enc[U32MAX;U32MAX][1];0][2])]

ok1["i8 -1"; i8enc -1; 0xff]
ok1["i8 -128"; i8enc -128; 0x80]
ok1["i8 127"; i8enc 127; 0x7f]
err["i8 128"; i8enc 128; "range"]
err["i8 -129"; i8enc -129; "range"]
eq["i8 rt"; 1; &/{i8dec[i8enc[x][1];0][1]~x}'-128+!256]

ok1["i16 min"; i16enc -32768; 0x8000]
ok1["i32 min"; i32enc -2147483648; 0x80000000]
ok1["i32 -2"; i32enc -2; 0xfffffffe]
eq["i32 rt"; -2; i32dec[i32enc[-2][1];0][1]]
eq["i32 min rt"; -2147483648; i32dec[i32enc[-2147483648][1];0][1]]

ok1["i64 0"; i64enc 0; 0x0000000000000000]
ok1["i64 1"; i64enc 1; 0x0000000000000001]
ok1["i64 -1"; i64enc -1; 0xffffffffffffffff]
ok1["i64 max"; i64enc I64MAX; 0x7fffffffffffffff]
ok1["i64 minh"; i64enc I64MINH; 0x8000000000000001]
ok1["i64 min sym"; i64enc `I64MIN; 0x8000000000000000]
err["i64 0N"; i64enc 0N; "range"]
eq["i64 -1 rt"; -1; i64dec[i64enc[-1][1];0][1]]
eq["i64 max rt"; I64MAX; i64dec[i64enc[I64MAX][1];0][1]]
eq["i64 minh rt"; I64MINH; i64dec[i64enc[I64MINH][1];0][1]]
eq["i64 min sym rt"; `I64MIN; i64dec[0x8000000000000000;0][1]]
eq["i64 2^53+3"; 9007199254740995; i64dec[i64enc[9007199254740995][1];0][1]]

ok1["bool 0"; boolenc 0; 0x00]
ok1["bool 1"; boolenc 1; 0x01]
err["bool 2"; boolenc 2; "bool"]
err["bool -1"; boolenc -1; "bool"]
err["bool dec 2"; booldec[0x02;0]; "bool"]

ok1["leb 0"; lebenc 0; 0x00]
ok1["leb 127"; lebenc 127; 0x7f]
ok1["leb 128"; lebenc 128; 0x8001]
ok1["leb 300"; lebenc 300; 0xac02]
err["leb neg"; lebenc -1; "range"]
eq["leb rt"; 1; &/{lebdec[lebenc[x][1];0][1]~x}'0 1 127 128 129 300 16384 2097151 I64MAX]
err["leb nonminimal"; lebdec[0x8000;0]; "canonical"]
err["leb trunc"; lebdec[0x80;0]; "truncated"]

ok1["lp hi"; lpenc 0x0001ff; 0x000000030001ff]
eq["lp rt"; 0x0001ff; lpdec[lpenc[0x0001ff][1];0][1]]
ok1["lp empty"; lpenc 0#0x00; 0x00000000]
err["lp trunc"; lpdec[0x00000005;0]; "truncated"]
err["lp type"; lpenc 1 2 3; "type"]

eq["utf8 empty"; 1; utf8ok ""]
eq["utf8 hi"; 1; utf8ok "hello"]
eq["utf8 emoji"; 1; utf8ok 0xf09f9880]
eq["utf8 overlong"; 0; utf8ok 0xc080]
eq["utf8 surrogate"; 0; utf8ok 0xeda080]
eq["utf8 big"; 0; utf8ok 0xf4908080]
eq["utf8 cont"; 0; utf8ok 0x80]
eq["utf8 trunc lead"; 0; utf8ok 0xc2]
ok1["str hi"; strenc "hello"; lpenc["hello"][1]]
err["str bad"; strenc 0xc080; "utf8"]
eq["str rt"; "KSB+"; strdec[strenc["KSB+"][1];0][1]]
eq["str emoji rt"; 0xf09f9880; strdec[strenc[0xf09f9880][1];0][1]]

ok1["null"; optlpenc (::); 0x00]
eq["null rt"; 1; optlpdec[optlpenc[(::)][1];0][1]~(::)]
eq["opt rt"; 0x0102; optlpdec[optlpenc[0x0102][1];0][1]]
err["opt bad tag"; optlpdec[0x02;0]; "null"]

ok1["align 0"; alignpad[4;0x0102]; 0x01020000]
ok1["align fit"; alignpad[4;0x01020304]; 0x01020304]
err["align 3"; alignpad[3;0x01]; "align"]
err["align 0"; alignpad[0;0x01]; "align"]

eq["uadd"; (`ok;3); uadd[1;2]]
err["uadd ovf"; uadd[I64MAX;1]; "overflow"]
err["uadd 0N"; uadd[0N;1]; "range"]
err["uadd neg"; uadd[-1;1]; "range"]
eq["ushl 3 of 1"; (`ok;8); ushl[3;1]]
eq["ushl 62 of 1"; (`ok;4611686018427387904); ushl[62;1]]
err["ushl 63 of 1"; ushl[63;1]; "overflow"]
eq["uadd 2^62"; (`err;"overflow"); uadd[4611686018427387904;4611686018427387904]]

eq["crc empty"; 0; crc32 ""]
eq["crc 123456789"; 3421780262; crc32 "123456789"]
eq["crc a"; 3904355907; crc32 "a"]
refcrc:{[bs]
 c:{[a;ch] {$[*|b32 x; xor32[shr32 x; POLY]; shr32 x]}/[8; xor32[a;`i$ch]]}/[U32MAX; bs]
 xor32[c;U32MAX]}
eq["crc ref empty"; crc32[""]; refcrc ""]
eq["crc ref vec"; crc32["123456789"]; refcrc "123456789"]
eq["crc ref bin"; crc32[0x000102ff]; refcrc 0x000102ff]

ok1["f64 1"; f64enc 1.0; 0x3ff0000000000000]
ok1["f64 2"; f64enc 2.0; 0x4000000000000000]
ok1["f64 half"; f64enc 0.5; 0x3fe0000000000000]
ok1["f64 -1"; f64enc -1.0; 0xbff0000000000000]
ok1["f64 0"; f64enc 0.0; 0x0000000000000000]
ok1["f64 -0"; f64enc -0.0; 0x8000000000000000]
ok1["f64 inf"; f64enc 0w; 0x7ff0000000000000]
ok1["f64 -inf"; f64enc -0w; 0xfff0000000000000]
ok1["f64 nan"; f64enc 0n; 0x7ff8000000000000]
ok1["f64 min normal"; f64enc {x%2}/[1022;1.0]; 0x0010000000000000]
eq["f64 rt 0.1"; 1; {x~f64dec[f64enc[x][1];0][1]}' (0.1;-0.1;10.0;-10.0;1e-10;1e20;3.141592653589793)]
eq["f64 rt tiny"; {x%2}/[1074;1.0]; f64dec[f64enc[{x%2}/[1074;1.0]][1];0][1]]
eq["f64 rt -0"; 1; -0.0~f64dec[f64enc[-0.0][1];0][1]]
err["f64 type"; f64enc 1; "type"]
eq["f64 host branch"; 1.0; f64dec[0x3ff0000000000000;0][1]]

pay:0x0001ff00
env:envenc[0;pay][1]
ok1["env rt"; envdec env; pay]
eq["env magic"; "KSB+"; 4#env]
err["env trunc"; envdec 10#env; "truncated"]
err["env magic"; envdec 0x00010203,4_env; "magic"]
badver:env
badver[5]:0x63
err["env version"; envdec badver; "version"]
flip:env
flip[20]:0xff
err["env checksum"; envdec flip; "checksum"]
err["env trailing"; envdec env,0x00; "trailing"]
huge:"KSB+", (u16enc[1][1]), (u16enc[20][1]), (u16enc[0][1]), (u16enc[0][1]), (u32enc[MAXPAY+1][1]), (u32enc[0][1])
err["env limit"; envdec huge; "limit"]
eq["env head no payload"; 5; envhead[20#envenc[0;0x0102030405][1]][3]]
err["env dec no payload"; envdec 20#envenc[0;0x0102030405][1]; "truncated"]
err["env flags"; envenc[1;0x00]; "flags"]
err["env type"; envdec `sym; "type"]
err["slice neg"; slice[0x0102;-1;1]; "range"]
err["slice past"; slice[0x0102;0;3]; "truncated"]
eq["slice"; (`ok;0x02); slice[0x0102;1;1]]

`0:"TOTAL pass ",`k@P
`0:"TOTAL fail ",`k@F
`exit@$[F=0;0;1]
