/* Linker script for the kyson RV32I core test environment.
 *
 * Address map (must match testbench MEM_WORDS / TOHOST_ADDR parameters):
 *   0x00000000 - 0x00003FFF  .text  (≤16 KB, instruction memory)
 *   0x00004000 - 0x00007FFF  .data  (≤16 KB, data memory)
 *      tohost    @ 0x00004000  (first word of .data)
 *      fromhost  @ 0x00004004
 *
 * The testbench backs both regions with the same 32 KB unified memory
 * (8192 x 32-bit words) so instruction fetches and data accesses work
 * from the same flat array.
 */

OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS
{
    . = 0x00000000;

    .text.init : { *(.text.init) }
    .text      : { *(.text*) }

    . = ALIGN(4);
    . = 0x00004000;

    .data :
    {
        *(.data*)
        *(.sdata*)
    }

    .bss :
    {
        *(.bss*)
        *(.sbss*)
    }

    . = ALIGN(4);
    _end = .;
}
