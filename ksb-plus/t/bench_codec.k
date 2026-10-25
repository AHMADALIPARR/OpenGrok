\l src/codec.k
n:100000
a:{u8enc x}'!n
b:{u16enc x}'!n
c:{u32enc x}'!n
d:{u8dec[u8enc[x][1];0]}'!10000
`0:"u8 enc ",`k@#a
`0:"u16 enc ",`k@#b
`0:"u32 enc ",`k@#c
`0:"u8 rt ",`k@#d
`exit 0
