/ Copyright (C) 2026 AHMAD ALI PARR
/ SPDX-License-Identifier: AGPL-3.0-or-later
/ Holographic append-only ledger on KSB+ Layer 0.
/ Each tick is one KSB+ envelope. The chain is the previous payload CRC.
/ This is the ledger. The Rust file under ledger/ is a host demo only.

/ Tick payload layout (inside the envelope payload):
/   u64 ts_ns (hi;lo)
/   u8  kind   0=quote 1=trade 2=bookadjust
/   u8  side   0=bid 1=ask
/   i64 price
/   u64 size (hi;lo)
/   u64 order_id (hi;lo)
/   u32 prev_crc
/   then length-prefixed symbol

tickenc:{[ts_hi;ts_lo;kind;side;price;sz_hi;sz_lo;oid_hi;oid_lo;prev;sym]
 a:u64enc[ts_hi;ts_lo]
 b:u8enc kind
 c:u8enc side
 d:i64enc price
 e:u64enc[sz_hi;sz_lo]
 f:u64enc[oid_hi;oid_lo]
 g:u32enc prev
 h:strenc sym
 $[`err~*a; a; `err~*b; b; `err~*c; c; `err~*d; d;
   `err~*e; e; `err~*f; f; `err~*g; g; `err~*h; h;
   (`ok; a[1],b[1],c[1],d[1],e[1],f[1],g[1],h[1])]}

tickdec:{[b]
 a:u64dec[b;0]
 $[`err~*a; a;
   k:u8dec[b;a[3]]
   $[`err~*k; k;
     s:u8dec[b;k[2]]
     $[`err~*s; s;
       p:i64dec[b;s[2]]
       $[`err~*p; p;
         z:u64dec[b;p[2]]
         $[`err~*z; z;
           o:u64dec[b;z[3]]
           $[`err~*o; o;
             c:u32dec[b;o[3]]
             $[`err~*c; c;
               m:strdec[b;c[2]]
               $[`err~*m; m;
                 (`ok; a[1]; a[2]; k[1]; s[1]; p[1]; z[1]; z[2]; o[1]; o[2]; c[1]; m[1])]]]]]]]]}

/ Seal a tick into a KSB+ envelope. prev is the CRC of the previous payload (0 at genesis).
seal:{[ts_hi;ts_lo;kind;side;price;sz_hi;sz_lo;oid_hi;oid_lo;prev;sym]
 t:tickenc[ts_hi;ts_lo;kind;side;price;sz_hi;sz_lo;oid_hi;oid_lo;prev;sym]
 $[`err~*t; t; envenc[0; t[1]]]}

/ Open one envelope and return the tick plus the payload CRC for chaining.
open:{[env]
 p:envdec env
 $[`err~*p; p;
   d:tickdec p[1]
   $[`err~*d; d;
     (`ok; d; crc32 p[1])]]}

/ Verify a chain of envelopes. Each tick's prev_crc must equal the prior payload CRC.
verify:{[envs]
 prev:0
 i:0
 ok:1
 while[(i<#envs)&ok;
   o:open envs[i]
   $[`err~*o; ok:0;
     tick:o[1]
     $[~(tick[9]~prev); ok:0; prev:o[2]]]
   i:i+1]
 ok}
