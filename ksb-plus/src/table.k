/ Copyright (C) 2026 AHMAD ALI PARR
/ SPDX-License-Identifier: AGPL-3.0-or-later
/
/ This program is free software: you can redistribute it and/or modify
/ it under the terms of the GNU Affero General Public License as published
/ by the Free Software Foundation, either version 3 of the License, or
/ (at your option) any later version.
/ KSB+ Layer 1 — columnar table on top of the Layer 0 envelope.
/ A table is a named collection of columns. Each column is a typed vector.
/ On disk: one envelope whose payload is a sequence of column chunks.
/
/ Column chunk layout (inside payload):
/   u8  type tag   (0=i32, 1=i64, 2=f64, 3=bytes)
/   u32 count
/   then raw values (BE for ints, IEEE for f64, length-prefixed for bytes)

/ Type tags
T_I32:0
T_I64:1
T_F64:2
T_BYTES:3

/ Encode one column: (tag; values) -> bytes
colenc:{[tag;vals]
 n:#vals
 h:(u8enc tag)[1], (u32enc n)[1]
 body:$[tag=T_I32; joinb {i32enc x}'vals;
        tag=T_I64; joinb {i64enc x}'vals;
        tag=T_F64; joinb {f64enc x}'vals;
        tag=T_BYTES; joinb {lpenc x}'vals;
        (`err;"type")]
 $[`err~*body; body; (`ok; h, body)]}

/ Decode one column from buffer at offset. Returns (`ok; tag; values; new_offset)
coldec:{[b;i]
 t:u8dec[b;i]
 $[`err~*t; t;
   n:u32dec[b; t[2]]
   $[`err~*n; n;
     tag:t[1]
     cnt:n[1]
     pos:n[2]
     vals:()
     r:$[tag=T_I32; { [st;j] s:i32dec[b; st[1]]; $[`err~*s; s; (st[0], s[1]; s[2])] }/[ (!0;pos); !cnt ];
          tag=T_I64; { [st;j] s:i64dec[b; st[1]]; $[`err~*s; s; (st[0], s[1]; s[2])] }/[ (!0;pos); !cnt ];
          tag=T_F64; { [st;j] s:f64dec[b; st[1]]; $[`err~*s; s; (st[0], s[1]; s[2])] }/[ (!0;pos); !cnt ];
          tag=T_BYTES; { [st;j] s:lpdec[b; st[1]]; $[`err~*s; s; (st[0], s[1]; s[2])] }/[ (!0;pos); !cnt ];
          (`err;"type")]
     $[`err~*r; r; (`ok; tag; *r; r[1])]]]}

/ Table encode: dict of name->(tag;vector) -> envelope bytes
tableenc:{[cols]
 payload:0x00
 names:!cols
 i:0
 while[i<#names;
   n:names[i]
   c:cols[n]
   e:colenc[c[0]; c[1]]
   $[`err~*e; :e;
     payload:payload, (strenc n)[1], e[1]]
   i:i+1]
 envenc[0; payload]}

/ Table decode: envelope bytes -> dict of name->(tag;vector)
tabledec:{[env]
 p:envdec env
 $[`err~*p; p;
   b:p[1]
   i:0
   cols:()
   while[i<#b;
     s:strdec[b;i]
     $[`err~*s; :s;
       c:coldec[b; s[2]]
       $[`err~*c; :c;
         cols:cols, enlist[s[1]; (c[1]; c[2])]
         i:c[3]]]]
   (`ok; !cols!cols)]}

/ Append a row (dict of name->value) to an in-memory table.
/ Table is a dict of name->(tag; vector).
appendrow:{[table; row]
 names:!table
 $[#names=0; (`err;"empty");
   r:table
   i:0
   while[i<#names;
     n:names[i]
     $[n~!row; (`err;"missing");
       col:r[n]
       r[n]:(col[0]; col[1], row[n])]
     i:i+1]
   (`ok; r)]}

/ Simple scan: return all rows as list of dicts
scan:{[table]
 names:!table
 $[#names=0; !0;
   n:#table[names[0]][1]
   {[i] (!table)!'{x[1][i]}'table}'!n]}
