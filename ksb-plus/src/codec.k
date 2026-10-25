/ KSB+ codec — single-line for ngn/k (growler)
/ This build: >= returns enlisted; use > only.
U8MAX:255
U16MAX:65535
U32MAX:4294967295
I64MAX:9223372036854775807
I64MINH:-9223372036854775807
MAXPAY:16777216

bits64:{[x]; b:2\x; ((64-#b)#0),b}
nor:{[b]; $[0=#b; 1; ~|/b]}
fitpos:{[w;x]; $[~`i~@x; 0; x~0N; 0; x<0; 0; (w<1)|(w>63); 0; nor (64-w)#bits64 x]}
joinb:{[xs]; {x,y}/[0#0x00; xs]}
bytebits:{[ch]; (-8)#bits64 `i$ch}
bb:{bytebits x}
bitscat:{[xs]; {x,y}/[!0; xs]}
beU:{[b]; ib:256!`i$b; bits:bb'ib; 2/ bitscat bits}
beenc:{[n;x]; bits:(-8*n)#bits64 x; cuts:(8*!n)_bits; tb:{2/x}'cuts; bytes:`c$tb; joinb (,bytes)}
gt:{[a;b]; a>b}
u8enc:{[x]; $[~`i~@x; (`err;"type"); ~(fitpos[8;x]); (`err;"range"); (`ok; `c$(,x))]}
u8dec:{[b;i]; $[~(i<#b); (`err;"truncated"); (`ok; 256!`i$b[i]; i+1)]}
u16enc:{[x]; $[~`i~@x; (`err;"type"); ~(fitpos[16;x]); (`err;"range"); (`ok; beenc[2;x])]}
u16dec:{[b;i]; $[~(i+1<#b); (`err;"truncated"); (`ok; beU 2#i_b; i+2)]}
u32enc:{[x]; $[~`i~@x; (`err;"type"); ~(fitpos[32;x]); (`err;"range"); (`ok; beenc[4;x])]}
u32dec:{[b;i]; $[~(i+3<#b); (`err;"truncated"); (`ok; beU 4#i_b; i+4)]}
u64enc:{[hi;lo]; a:u32enc hi; b:u32enc lo; $[`err~*a; a; `err~*b; b; (`ok; a[1],b[1])]}
u64dec:{[b;i]; a:u32dec[b;i]; $[`err~*a; a; c:u32dec[b;a[2]]; $[`err~*c; c; (`ok; a[1]; c[1]; c[2])]]}
i8enc:{[x]; $[~`i~@x; (`err;"type"); x~0N; (`err;"range"); (x<-128)|(x>127); (`err;"range"); u8enc $[x<0; 256+x; x]]}
i8dec:{[b;i]; r:u8dec[b;i]; $[`err~*r; r; u:r[1]; (`ok; $[u>127; u-256; u]; r[2])]}
i16enc:{[x]; $[~`i~@x; (`err;"type"); x~0N; (`err;"range"); (x<-32768)|(x>32767); (`err;"range"); u16enc $[x<0; 65536+x; x]]}
i16dec:{[b;i]; r:u16dec[b;i]; $[`err~*r; r; u:r[1]; (`ok; $[u>32767; u-65536; u]; r[2])]}
i32enc:{[x]; $[~`i~@x; (`err;"type"); x~0N; (`err;"range"); (x<-2147483648)|(x>2147483647); (`err;"range"); u32enc $[x<0; 4294967296+x; x]]}
i32dec:{[b;i]; r:u32dec[b;i]; $[`err~*r; r; u:r[1]; (`ok; $[u>2147483647; u-4294967296; u]; r[2])]}
