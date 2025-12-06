// Common to all target code

#include "uvm32_sys.h"

// Basic types
typedef long uint32_t;
typedef char uint8_t;
typedef int bool;
#define true 1
#define false 0

// Convenience macro for defining CSR helper functions
#define xstr(a) str(a)
#define str(a) #a
#define DEFINE_CSR_WRITE_FUNCTION(function_name, csr, typ) \
    static void function_name(typ val) { \
	    asm volatile( ".option norvc\ncsrrw x0," xstr(csr) ", %0\n" : : "r" (val)); \
    }
#define DEFINE_CSR_WRITE_FUNCTION_VOID(function_name, csr) \
    static void function_name(void) { \
	    asm volatile( ".option norvc\ncsrwi " xstr(csr) ", 0"); \
    }

#include "uvm32_common_custom.h"
#include "uvm32_target_custom.h"

// provide main, with setup()/loop() flow
void setup(void);
bool loop(void);

#ifndef USE_MAIN
void main(void) {
    setup();
    while(loop()) {
        yield();
    }
}
#endif

