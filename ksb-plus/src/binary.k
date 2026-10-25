/ Copyright (C) 2026 AHMAD ALI PARR
/ SPDX-License-Identifier: AGPL-3.0-or-later
/
/ This program is free software: you can redistribute it and/or modify
/ it under the terms of the GNU Affero General Public License as published
/ by the Free Software Foundation, either version 3 of the License, or
/ (at your option) any later version.
/ KSB+ layer 0 — canonical big-endian binary contract.
/ Host: ngn/k (growler fork). Persistent bytes are not host endianness.
/ Host int64 has no null distinct from -2^63. 0N is that bit pattern.
/ Unsigned 64-bit values are pairs of u32 (hi;lo), never a single host int.
/ CRC-32/ISO-HDLC is an integrity check, not an authenticity proof.
/ Error results are (`err;code). Success is (`ok; ...) with the values that follow.

U8MAX:255
U16MAX:65535
U32MAX:4294967295
I64MAX:9223372036854775807
I64MINH:-9223372036854775807
MAXPAY:16777216
POLY:3988292384
F64MANT:4503599627370496

isC:{(`C~@x)|(`c~@x)}
asC:{[x]
 $[`C~@x; (`ok;x);
   `c~@x; (`ok;`c$(,`i$x));
   (`err;"type")]}

bits64:{[x] b:2\x; ((64-#b)#0),b}
nor:{[b] $[0=#b; 1; ~|/b]}
fitpos:{[w;x]
 $[~`i~@x; 0;
   x~0N; 0;
   x<0; 0;
   (w<1)|(w>63); 0;
   nor (64-w)#bits64 x]}
joinb:{[xs] {x,y}/[0#0x00; xs]}
bytebits:{[ch] (-8)#bits64 `i$ch}
bitscat:{[xs] {x,y}/[!0; xs]}
beU:{[b] 2/ bitscat {bytebits x}'b}
beenc:{[n;x]
 bits:(-8*n)#bits64 x
 joinb {`c$2/x}'((8*!n)_bits)}

uadd2:{[a;b] s:a+b; $[(s~0N)|(s<0); (`err;"overflow"); (`ok;s)]}
uadd:{[a;b]
 $[~`i~@a; (`err;"type");
   ~`i~@b; (`err;"type");
   (a~0N)|(b~0N)|(a<0)|(b<0); (`err;"range");
   uadd2[a;b]]}
ushl:{[n;x]
 $[~`i~@n; (`err;"type");
   ~`i~@x; (`err;"type");
   (n~0N)|(x~0N)|(n<0)|(x<0); (`err;"range");
   n>63; (`err;"overflow");
   n=0; (`ok;x);
   hi:n#bits64 x
   $[|/hi; (`err;"overflow"); (`ok; 2/ (-64)# (bits64 x), n#0)]]}

slice:{[b;i;n]
 $[~(isC b); (`err;"type");
   ~`i~@i; (`err;"type");
   ~`i~@n; (`err;"type");
   (i~0N)|(n~0N)|(i<0)|(n<0); (`err;"range");
   i>#b; (`err;"truncated");
   n>(#b)-i; (`err;"truncated");
   (`ok; n#i_b)]}

u8enc:{[x]
 $[~`i~@x; (`err;"type");
   ~(fitpos[8;x]); (`err;"range");
   (`ok; `c$(,x))]}
u8dec:{[b;i]
 s:slice[b;i;1]
 $[`err~*s; s; (`ok; `i$*s[1]; i+1)]}
u16enc:{[x]
 $[~`i~@x; (`err;"type");
   ~(fitpos[16;x]); (`err;"range");
   (`ok; beenc[2;x])]}
u16dec:{[b;i]
 s:slice[b;i;2]
 $[`err~*s; s; (`ok; beU s[1]; i+2)]}
u32enc:{[x]
 $[~`i~@x; (`err;"type");
   ~(fitpos[32;x]); (`err;"range");
   (`ok; beenc[4;x])]}
u32dec:{[b;i]
 s:slice[b;i;4]
 $[`err~*s; s; (`ok; beU s[1]; i+4)]}
u64enc:{[hi;lo]
 a:u32enc hi
 b:u32enc lo
 $[`err~*a; a; `err~*b; b; (`ok; a[1],b[1])]}
u64dec:{[b;i]
 a:u32dec[b;i]
 $[`err~*a; a;
   c:u32dec[b; a[2]]
   $[`err~*c; c; (`ok; a[1]; c[1]; c[2])]]}

i8enc:{[x]
 $[~`i~@x; (`err;"type");
   x~0N; (`err;"range");
   (x<-128)|(x>127); (`err;"range");
   u8enc $[x<0; 256+x; x]]}
i8dec:{[b;i]
 r:u8dec[b;i]
 $[`err~*r; r;
   u:r[1]
   (`ok; $[u>=128; u-256; u]; r[2])]}
i16enc:{[x]
 $[~`i~@x; (`err;"type");
   x~0N; (`err;"range");
   (x<-32768)|(x>32767); (`err;"range");
   u16enc $[x<0; 65536+x; x]]}
i16dec:{[b;i]
 r:u16dec[b;i]
 $[`err~*r; r;
   u:r[1]
   (`ok; $[u>=32768; u-65536; u]; r[2])]}
i32enc:{[x]
 $[~`i~@x; (`err;"type");
   x~0N; (`err;"range");
   (x<-2147483648)|(x>2147483647); (`err;"range");
   u32enc $[x<0; 4294967296+x; x]]}
i32dec:{[b;i]
 r:u32dec[b;i]
 $[`err~*r; r;
   u:r[1]
   (`ok; $[u>=2147483648; u-4294967296; u]; r[2])]}

add1bits:{[b]
 acc:{[st;i]
  bits:*st
  c:st[1]
  bit:bits[i]
  nb:~bit=c
  nc:bit&c
  bits[i]:nb
  (bits;nc)}/[ (b;1); |!#b]
 *acc}

i64enc:{[x]
 $[x~`I64MIN; (`ok; 0x8000000000000000);
   ~`i~@x; (`err;"type");
   x~0N; (`err;"range");
   x>=0; (`ok; beenc[8;x]);
   tb:add1bits[~(bits64[-x])]
   (`ok; joinb {`c$2/x}'((8*!8)_tb))]}
i64dec:{[b;i]
 s:slice[b;i;8]
 $[`err~*s; s;
   raw:s[1]
   raw~0x8000000000000000; (`ok; `I64MIN; i+8);
   bits:bitscat {bytebits x}'raw
   $[~(*bits); (`ok; 2/bits; i+8);
     (`ok; -2/ add1bits ~bits; i+8)]]}

boolenc:{[x]
 $[~`i~@x; (`err;"type");
   (x~0)|x~1; (`ok; `c$(,x));
   (`err;"bool")]}
booldec:{[b;i]
 r:u8dec[b;i]
 $[`err~*r; r;
   (r[1]~0)|r[1]~1; (`ok; r[1]; r[2]);
   (`err;"bool")]}

lebraw:{[x]
 lo:2/ (-7)#bits64 x
 hi:2/ 64#(7#0), bits64 x
 $[x<128; `c$(,lo); (`c$(,lo+128)), o hi]}
lebenc:{[x]
 $[~`i~@x; (`err;"type");
   ~(fitpos[63;x]); (`err;"range");
   (`ok; lebraw x)]}
lebwalk:{[b;i;acc;sh]
 $[(i<0)|i>=#b; (`err;"truncated");
   sh>56; (`err;"limit");
   by:`i$b[i]
   cont:by>127
   lo:$[cont; by-128; by]
   lebadd[b;i;acc;sh;lo;cont]]}
lebadd:{[b;i;acc;sh;lo;cont]
 sp:ushl[sh;lo]
 $[`err~*sp; sp; lebadd2[b;i;acc;sh;sp[1];cont]]}
lebadd2:{[b;i;acc;sh;piece;cont]
 sm:uadd[acc;piece]
 $[`err~*sm; sm;
   cont; lebwalk[b;i+1;sm[1];sh+7];
   (`ok; sm[1]; i+1)]}
lebdec:{[b;i]
 $[~(isC b); (`err;"type");
   ~`i~@i; (`err;"type");
   (i~0N)|(i<0); (`err;"range");
   r:lebwalk[b;i;0;0]
   $[`err~*r; r;
     enc:lebenc r[1]
     $[`err~*enc; enc;
       raw:(r[2]-i)#i_b
       ~(raw~enc[1]); (`err;"canonical");
       r]]]}

lpenc:{[bs]
 r:asC bs
 $[`err~*r; r;
   b:r[1]
   (#b)>U32MAX; (`err;"limit");
   u:u32enc #b
   $[`err~*u; u; (`ok; u[1],b)]]}
lpdec:{[b;i]
 r:u32dec[b;i]
 $[`err~*r; r;
   s:slice[b; r[2]; r[1]]
   $[`err~*s; s; (`ok; s[1]; r[2]+r[1])]]}

u2b:{[bb;i;y] $[((y>127)&(y<192)); (bb;i+2;0); (bb;i;1)]}
u2:{[bb;i] $[(i+2)>#bb; (bb;i;1); u2b[bb;i;bb[i+1]]]}
u3b:{[bb;i;y;z]
 x:bb[i]
 okc:((y>127)&(y<192))&((z>127)&(z<192))
 oky:$[x=224; y>=160; x=237; y<160; 1]
 $[(okc)&(oky); (bb;i+3;0); (bb;i;1)]}
u3:{[bb;i] $[(i+3)>#bb; (bb;i;1); u3b[bb;i;bb[i+1];bb[i+2]]]}
u4b:{[bb;i;y;z;w]
 x:bb[i]
 okc:(((y>127)&(y<192))&((z>127)&(z<192)))&((w>127)&(w<192))
 oky:$[x=240; y>=144; x=244; y<144; 1]
 $[(okc)&(oky); (bb;i+4;0); (bb;i;1)]}
u4:{[bb;i] $[(i+4)>#bb; (bb;i;1); u4b[bb;i;bb[i+1];bb[i+2];bb[i+3]]]}
ustep:{[st]
 bb:*st
 i:st[1]
 bad:st[2]
 $[bad; st;
   i>=#bb; st;
   x:bb[i]
   $[x<128; (bb;i+1;0);
     ((x>193)&(x<224)); u2[bb;i];
     ((x>223)&(x<240)); u3[bb;i];
     ((x>239)&(x<245)); u4[bb;i];
     (bb;i;1)]]}
utf8ok:{[bs]
 r:asC bs
 $[`err~*r; 0;
   bb:{`i$x}'r[1]
   fin:ustep/[#bb; (bb;0;0)]
   (fin[2]=0)&fin[1]>=#bb]}
strenc:{[bs]
 r:asC bs
 $[`err~*r; r;
   ~(utf8ok r[1]); (`err;"utf8");
   lpenc r[1]]}
strdec:{[b;i]
 r:lpdec[b;i]
 $[`err~*r; r;
   ~(utf8ok r[1]); (`err;"utf8");
   r]}

optlpenc:{[payload]
 $[payload~(::); (`ok; ,0x00);
   p:asC payload
   $[`err~*p; p;
     q:lpenc p[1]
     $[`err~*q; q; (`ok; 0x01,q[1])]]]}
optlpdec:{[b;i]
 s:slice[b;i;1]
 $[`err~*s; s;
   t:`i$*s[1]
   $[t=0; (`ok; (::); i+1);
     t<>1; (`err;"null");
     r:lpdec[b;i+1]
     $[`err~*r; r; (`ok; r[1]; r[2])]]]}

ispow2:{[a] $[~(fitpos[16;a]); 0; 1=+/bits64 a]}
alignpad:{[a;b]
 r:asC b
 $[~`i~@a; (`err;"type");
   ~(ispow2 a); (`err;"align");
   `err~*r; r;
   m:a!#r[1]
   $[m=0; (`ok; r[1]); (`ok; r[1],(a-m)#0x00)]]}

b32:{[x] (-32)#bits64 x}
from32:{[b] 2/b}
xor32:{[a;b] from32[~((b32 a)=(b32 b))]}
shr32:{[a] from32 32#(0, b32 a)}
shr8:{[a] from32 32#(8#0), b32 a}
low8:{[a] from32 (-8)#b32 a}
crcbyte:{[c] {$[*|b32 x; xor32[shr32 x; POLY]; shr32 x]}/[8;c]}
CRCT:{crcbyte x}'!256
crc32:{[bs]
 r:asC bs
 $[`err~*r; (`err;"type");
   c:{[a;ch] xor32[shr8 a; CRCT low8 xor32[a; `i$ch]]}/[U32MAX; r[1]]
   xor32[c; U32MAX]]}

u16be:{[b] beU b}
u32be:{[b] beU b}
envhead:{[b]
 $[~(isC b); (`err;"type");
   (#b)<20; (`err;"truncated");
   ~("KSB+"~4#b); (`err;"magic");
   ver:u16be 2#4_b
   hln:u16be 2#6_b
   fl:u16be 2#8_b
   rs:u16be 2#10_b
   plen:u32be 4#12_b
   crc:u32be 4#16_b
   $[ver<>1; (`err;"version");
     hln<>20; (`err;"header");
     fl<>0; (`err;"flags");
     rs<>0; (`err;"reserved");
     (`ok; ver; fl; plen; crc)]]}
envenc:{[flags;payload]
 $[~`i~@flags; (`err;"type");
   flags<>0; (`err;"flags");
   p:asC payload
   $[`err~*p; p;
     pb:p[1]
     (#pb)>MAXPAY; (`err;"limit");
     c:crc32 pb
     h:"KSB+", (u16enc[1][1]), (u16enc[20][1]), (u16enc[0][1]), (u16enc[0][1]), (u32enc[#pb][1]), (u32enc[c][1])
     (`ok; h,pb)]]}
envdec:{[b]
 h:envhead b
 $[`err~*h; h;
   plen:h[3]
   crc:h[4]
   $[plen>MAXPAY; (`err;"limit");
     (#b)<20+plen; (`err;"truncated");
     (#b)>20+plen; (`err;"trailing");
     pay:plen#20_b
     ~(crc32[pay]~crc); (`err;"checksum");
     (`ok; pay)]]}

fscale:{[st]
 a:*st
 e:st[1]
 $[(a~0w)|(a~-0w)|(a~0n); (a;e);
   a>=2; (a%2; e+1);
   (a<1)&(e>-1022); (a*2; e-1);
   st]}
packf:{[sign;exp;mant]
 bits:(,sign), ((-11)#bits64 exp), (-52)#bits64 mant
 joinb {`c$2/x}'((8*!8)_bits)}
f64norm:{[neg;af;e]
 mant:_(af-1)*F64MANT
 exp:e+1023
 $[(exp>2046)|(exp<1); (`err;"float");
   (mant<0)|(mant>=F64MANT); (`err;"float");
   (`ok; packf[neg;exp;mant])]}
f64sub:{[neg;af]
 mant:_(af*F64MANT)
 $[(mant<0)|(mant>=F64MANT); (`err;"float");
   (`ok; packf[neg;0;mant])]}
f64finite:{[x]
 neg:x<0
 a:$[neg; -x; x]
 st:fscale/[2200; (a;0)]
 af:*st
 e:st[1]
 $[af>=1; f64norm[neg;af;e]; f64sub[neg;af]]}
f64enc:{[x]
 $[~`f~@x; (`err;"type");
   x~0n; (`ok; 0x7ff8000000000000);
   x~0w; (`ok; 0x7ff0000000000000);
   x~-0w; (`ok; 0xfff0000000000000);
   x~-0.0; (`ok; 0x8000000000000000);
   x~0.0; (`ok; 0x0000000000000000);
   f64finite x]}
f64dec:{[b;i]
 s:slice[b;i;8]
 $[`err~*s; s;
   raw:s[1]
   v:$[1.0~`fb@0x3ff0000000000000; `fb@raw; `fb@|raw]
   (`ok; v; i+8)]}
