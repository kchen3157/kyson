#!/usr/bin/env python3
"""
elf2hex.py – convert a RISC-V ELF to a flat word-per-line hex file
suitable for Verilog $readmemh.

Usage:
    python3 elf2hex.py <input.elf> <output.hex> [mem_bytes]

The output is a flat sequence of 32-bit little-endian words, one per
line, with NO address prefix.  The file covers [0, mem_bytes) so that
$readmemh("file.hex", mem) fills the array directly:

    word 0  → mem[0]   (byte address 0x0000)
    word 1  → mem[1]   (byte address 0x0004)
    ...
    word N  → mem[N]   (byte address 0x4000 ÷ 4 = 4096 → tohost)

Default mem_bytes = 0x8000 (32 KB = 8192 words), matching the
testbench TOHOST_ADDR = 0x4000 / MEM_WORDS = 8192 parameters.
"""

import struct
import subprocess
import sys
import os
import tempfile


def elf2hex(elf_path: str, hex_path: str, mem_bytes: int = 0x8000) -> None:
    if not os.path.isfile(elf_path):
        sys.exit(f"elf2hex: file not found: {elf_path}")

    with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as tf:
        tmp_bin = tf.name

    try:
        # Flatten the ELF into a single binary image padded to mem_bytes.
        subprocess.run(
            [
                "riscv64-unknown-elf-objcopy",
                "-O", "binary",
                "--gap-fill", "0x00",
                "--pad-to", hex(mem_bytes),
                elf_path,
                tmp_bin,
            ],
            check=True,
            stderr=subprocess.PIPE,
        )

        with open(tmp_bin, "rb") as f:
            data = f.read()

    finally:
        if os.path.exists(tmp_bin):
            os.unlink(tmp_bin)

    if len(data) != mem_bytes:
        # objcopy may not pad if the ELF already reaches mem_bytes; just
        # extend with zeros.
        data = data[:mem_bytes].ljust(mem_bytes, b"\x00")

    words = len(data) // 4
    with open(hex_path, "w") as out:
        for i in range(words):
            chunk = data[i * 4 : i * 4 + 4]
            (word,) = struct.unpack("<I", chunk)
            out.write(f"{word:08x}\n")

    print(f"  {os.path.basename(elf_path)}  →  {hex_path}  ({words} words)")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(f"Usage: {sys.argv[0]} <input.elf> <output.hex> [mem_bytes]")
    mem = int(sys.argv[3], 0) if len(sys.argv) > 3 else 0x8000
    elf2hex(sys.argv[1], sys.argv[2], mem)
