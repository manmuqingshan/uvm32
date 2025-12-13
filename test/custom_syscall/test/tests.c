#include <string.h>
#include "unity.h"
#include "uvm32.h"
#include "../common/uvm32_common_custom.h"

#include "rom-header.h"

static uvm32_state_t vmst;
static uvm32_evt_t evt;

void setUp(void) {
    // runs before each test
    uvm32_init(&vmst);
    uvm32_load(&vmst, rom_bin, rom_bin_len);
}

void tearDown(void) {
}

void test_custom_syscall_normal(void) {
    // run the vm
    uvm32_run(&vmst, &evt, 100);
    // check for custom syscall
    TEST_ASSERT_EQUAL(evt.typ, UVM32_EVT_SYSCALL);
    TEST_ASSERT_EQUAL(evt.data.syscall.code, 0xDEADBEEF);
    TEST_ASSERT_EQUAL(0xABCD1234, uvm32_arg_getval(&vmst, &evt, ARG0));
    TEST_ASSERT_EQUAL(0xDECAFBAD, uvm32_arg_getval(&vmst, &evt, ARG1));
    uvm32_arg_setval(&vmst, &evt, RET, 0xAABBCCDD);

    uvm32_run(&vmst, &evt, 100);
    // check for print syscall
    TEST_ASSERT_EQUAL(evt.typ, UVM32_EVT_SYSCALL);
    TEST_ASSERT_EQUAL(evt.data.syscall.code, UVM32_SYSCALL_PRINT);
    const char *str = uvm32_arg_getcstr(&vmst, &evt, ARG0);
    TEST_ASSERT_EQUAL(0, strcmp(str, "ok"));
    // run vm to completion
    uvm32_run(&vmst, &evt, 100);
    TEST_ASSERT_EQUAL(evt.typ, UVM32_EVT_END);
}

void test_custom_syscall_badval(void) {
    // run the vm
    uvm32_run(&vmst, &evt, 100);
    // check for custom syscall
    TEST_ASSERT_EQUAL(evt.typ, UVM32_EVT_SYSCALL);
    TEST_ASSERT_EQUAL(evt.data.syscall.code, 0xDEADBEEF);
    TEST_ASSERT_EQUAL(0xABCD1234, uvm32_arg_getval(&vmst, &evt, ARG0));
    TEST_ASSERT_EQUAL(0xDECAFBAD, uvm32_arg_getval(&vmst, &evt, ARG1));
    uvm32_arg_setval(&vmst, &evt, RET, 0);  // send value that is not being expected

    uvm32_run(&vmst, &evt, 100);
    // check for print syscall
    TEST_ASSERT_EQUAL(evt.typ, UVM32_EVT_SYSCALL);
    TEST_ASSERT_EQUAL(evt.data.syscall.code, UVM32_SYSCALL_PRINT);
    const char *str = uvm32_arg_getcstr(&vmst, &evt, ARG0);
    TEST_ASSERT_EQUAL(0, strcmp(str, "fail"));
    // run vm to completion
    uvm32_run(&vmst, &evt, 100);
    TEST_ASSERT_EQUAL(evt.typ, UVM32_EVT_END);
}

void test_custom_syscall_badarg(void) {
    // run the vm
    uvm32_run(&vmst, &evt, 100);
    // check for custom syscall
    TEST_ASSERT_EQUAL(evt.typ, UVM32_EVT_SYSCALL);
    TEST_ASSERT_EQUAL(evt.data.syscall.code, 0xDEADBEEF);
    TEST_ASSERT_EQUAL(0, uvm32_arg_getval(&vmst, &evt, (uvm32_arg_t)123));   // not ARG0, ARG1 or RET

    // check for error state
    uvm32_run(&vmst, &evt, 100);
    TEST_ASSERT_EQUAL(evt.typ, UVM32_EVT_ERR);
    TEST_ASSERT_EQUAL(evt.data.err.errcode, UVM32_ERR_ARGS);

}


