#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "uvm32.h"
#include "../common/uvm32_common_custom.h"

__AFL_FUZZ_INIT();

int main(int argc, char *argv[]) {
    __AFL_INIT();
    uvm32_state_t vmst;
    uvm32_evt_t evt;

    uvm32_init(&vmst);
    unsigned char *rom = __AFL_FUZZ_TESTCASE_BUF;
    while (__AFL_LOOP(10000)) {
        uvm32_load(&vmst, rom, __AFL_FUZZ_TESTCASE_LEN);
        uvm32_run(&vmst, &evt, 1000);
    }

    return 0;
}
