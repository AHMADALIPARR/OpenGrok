# Streaming source audit. Usage: awk -f blocks/audit.awk FILE
BEGIN { bytes = 0; lines = 0; empty = 0 }
{
    bytes += length($0) + 1
    lines++
    if (length($0) == 0) empty++
}
END {
    printf "lines=%d\nbytes_approx=%d\nempty_lines=%d\n", lines, bytes, empty
}
