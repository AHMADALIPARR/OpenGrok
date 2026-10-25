\l src/ledger.k
P:0
F:0
pass:{[n]; `0:"PASS ",n; P::P+1}
fail:{[n]; `0:"FAIL ",n; F::F+1}
eq:{[n;a;b]; $[a~b; pass n; fail n]}

t1:(1000;0;0;3500;10;101;0;3;"ETH")
e1:seal t1
eq["seal1"; `ok; *e1]
eq["magic"; "KSB+"; 4#e1[1]]
o1:open e1[1]
eq["open1"; `ok; *o1]
eq["roundtrip"; t1; o1[1]]

t2:(1100;0;1;3501;8;102;o1[2];3;"ETH")
e2:seal t2
eq["seal2"; `ok; *e2]
eq["chain"; 1; verify2[e1[1]; e2[1]]]

`0:"TOTAL pass ",`k@P
`0:"TOTAL fail ",`k@F
`exit@$[F=0;0;1]
