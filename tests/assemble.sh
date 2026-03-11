#!/bin/bash
# Usage: ./tests/assemble.sh <test_name>
# Example: ./tests/assemble.sh add

set -e

NAME=$1
DIR="$(cd "$(dirname "$0")" && pwd)"

riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o "${DIR}/${NAME}.o" "${DIR}/${NAME}.s"
riscv64-unknown-elf-ld -m elf32lriscv -Ttext=0x0 -o "${DIR}/${NAME}.elf" "${DIR}/${NAME}.o"
riscv64-unknown-elf-objcopy -O binary "${DIR}/${NAME}.elf" "${DIR}/${NAME}.bin"

python3 -c "
import struct, sys
name = sys.argv[1]
with open(name + '.bin', 'rb') as f:
    data = f.read()
with open(name + '.hex', 'w') as f:
    for i in range(0, len(data), 4):
        f.write('{:08x}\n'.format(struct.unpack_from('<I', data, i)[0]))
" "${DIR}/${NAME}"

echo "Done: ${DIR}/${NAME}.hex"
