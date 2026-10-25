# KSB+

Original database engine implemented in K, built from the binary contract upward.
kdb+ is an architectural reference only. This tree does not contain Kx source and it does not wrap another database.

The current push is Layer 0: fixed-width integers, IEEE-754 binary64, LEB128, length-prefixed bytes, UTF-8, option tags, CRC-32, and the versioned `KSB+` envelope. Higher layers are not claimed.

## Run the tests

The runtime is [ngn/k](https://codeberg.org/growler/k) (growler fork), which is a C interpreter under AGPL-3.0-only. KSB+ source in this repository is the K code; the interpreter is not vendored.

```sh
git clone https://codeberg.org/growler/k.git
make -C k k CC=gcc
K="$PWD/k/k" sh t/run.sh
```

`t/run.sh` only executes that interpreter. A passing run prints `TOTAL fail 0` and exits 0.

## Format

See [docs/binary-format.md](docs/binary-format.md) and [docs/limitations.md](docs/limitations.md).

## License

KSB+ K sources and docs: MIT. See [LICENSE](LICENSE).
The separate ngn/k interpreter you build to run them keeps its own AGPL-3.0-only license.
