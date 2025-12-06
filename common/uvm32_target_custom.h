// Define wrapper functions for target code to call CSRs

DEFINE_CSR_WRITE_FUNCTION(print, IOREQ_PRINT, const char *)
DEFINE_CSR_WRITE_FUNCTION(printd, IOREQ_PRINTD, uint32_t)
DEFINE_CSR_WRITE_FUNCTION(printx, IOREQ_PRINTX, uint32_t)
DEFINE_CSR_WRITE_FUNCTION(printc, IOREQ_PRINTC, char)
DEFINE_CSR_WRITE_FUNCTION(println, IOREQ_PRINTLN, const char *)
DEFINE_CSR_WRITE_FUNCTION_VOID(halt, IOREQ_HALT)
DEFINE_CSR_WRITE_FUNCTION_VOID(yield, IOREQ_YIELD)
DEFINE_CSR_WRITE_FUNCTION(millis_internal, IOREQ_MILLIS, uint32_t *)

static inline uint32_t millis(void) {
    static uint32_t m;
    millis_internal(&m);
    return m;
}

