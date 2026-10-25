# KSB+ binary contract (version 1)

Persistent integers are **big-endian**. The host's native endianness is not the file format.
On the selected runtime (ngn/k, growler fork, little-endian x86_64), `` `fb `` reverses 8 bytes and then reads a native IEEE-754 binary64. `f64dec` branches on that probe so the stored bytes stay big-endian. `f64enc` does not use the host float bits; it writes IEEE-754 binary64 explicitly.

Integrity is CRC-32/ISO-HDLC (reflected polynomial `0xEDB88320`, init `0xFFFFFFFF`, xor-out `0xFFFFFFFF`). A matching checksum detects many accidental corruptions. It is not an authenticity proof and not a MAC.

## Host limits that the format does not inherit

| Host fact | Format consequence |
|---|---|
| `0N` and `-2^63` are the same value | i64 bit pattern `8000000000000000` decodes as the symbol `` `I64MIN ``, not as a host int |
| No unsigned 64-bit atom | u64 is `(hi;lo)` with each half a u32 in `0..4294967295` |
| `1%0` yields `0w`, not an error | Float division by zero is an infinity at the host layer. Integer helpers in this layer reject it separately |
| No `fsync` and path `1:` truncates | Not a Layer 0 concern. The storage layer must not treat a successful write as power-fail durable |

## Fixed-width numbers

| Name | Width | Encoding | Valid values | Null |
|---|---|---|---|---|
| bool | 1 | `00` or `01` only | 0, 1 | not a bool; use option tag |
| u8 | 1 | raw | 0..255 | option tag |
| i8 | 1 | two's complement | -128..127 | option tag |
| u16 | 2 | big-endian | 0..65535 | option tag |
| i16 | 2 | two's complement BE | -32768..32767 | option tag |
| u32 | 4 | big-endian | 0..4294967295 | option tag |
| i32 | 4 | two's complement BE | -2147483648..2147483647 | option tag |
| u64 | 8 | BE u32 hi, BE u32 lo | full unsigned 64-bit range | option tag |
| i64 | 8 | two's complement BE | host `-2^63+1 .. 2^63-1`, plus `` `I64MIN `` for `0x8000000000000000` | option tag |
| f64 | 8 | IEEE-754 binary64 BE | finite, ±0, ±inf, canonical qNaN `7ff8000000000000` | `0n` encodes as that canonical NaN; missing values still use the option tag |

Out-of-range encodes return `(`err;"range")` or `(`err;"type")`. Decoders do not wrap.

## Variable length

Unsigned LEB128, canonical only (the shortest encoding). Non-minimal input is `(`err;"canonical")`. Values must fit in a non-negative host int (`0 .. 2^63-1`).

Length-prefixed bytes: u32 BE length, then that many bytes. A declared length past the buffer is `(`err;"truncated")`.

Strings are length-prefixed UTF-8. Overlong sequences, surrogates, code points above U+10FFFF, and truncated sequences are `(`err;"utf8")`. This is not Unicode normalization.

## Option

| Tag | Meaning |
|---|---|
| `00` | missing (`::`) |
| `01` | present, followed by a length-prefixed byte string |

Any other tag is `(`err;"null")`.

## Alignment

`alignpad` accepts power-of-two alignments `1,2,4,8,16` and appends `00` bytes. The version-1 envelope is naturally aligned and has no interior padding.

## Version-1 envelope

| Offset | Width | Field | Rule |
|---|---|---|---|
| 0 | 4 | magic | `4B 53 42 2B` (`KSB+`) else `magic` |
| 4 | 2 | version | u16 BE `1` else `version` |
| 6 | 2 | header length | u16 BE `20` else `header` |
| 8 | 2 | flags | u16 BE `0` else `flags` |
| 10 | 2 | reserved | u16 BE `0` else `reserved` |
| 12 | 4 | payload length | u32 BE, must be `<= 16777216` else `limit` |
| 16 | 4 | payload CRC-32 | u32 BE of the payload bytes else `checksum` |
| 20 | plen | payload | opaque at this layer |

`envhead` reads the 20-byte header and does not require the payload bytes to be present.
`envdec` requires `len(buffer) = 20 + payload_length`. Short buffers are `truncated`. Extra bytes are `trailing`.

A header that declares a payload larger than 16 MiB is rejected before any offset addition, including when the buffer is shorter than that declaration.
