#include "uvm32_sys.h"
#include "uvm32_common_custom.h"
.section .initial_jump , "ax", %progbits
.global _start
.align 4
_start:
# sp is already setup by vm
sw	ra,12(sp)
jal	ra, main
li a7, 0x138 #IOREQ_HALT (Rust assembler doesn't pick up def...)
ecall
.section .data

