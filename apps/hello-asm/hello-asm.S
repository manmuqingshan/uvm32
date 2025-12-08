#include "uvm32_sys.h"
#include "uvm32_common_custom.h"
.section .initial_jump , "ax", %progbits
.global _start
_start:
la     a0, str
li a7, IOREQ_PRINTLN
ecall
li a7, IOREQ_HALT
ecall
str:
.ascii "Hi\0"
