.section .initial_jump , "ax", %progbits
.global _start
.align 4
_start:
# sp is already setup by vm
sw	ra,12(sp)
jal	ra, main
csrwi 0x138,0 # halt
.section .data

