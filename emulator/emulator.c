#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "uvm32.h"

#include "../common/uvm32_common_custom.h"

// ioreqs exposed to vm environement
typedef enum {
    F_PRINT,
    F_PRINTD,
    F_PRINTX,
    F_PRINTC,
    F_PRINTLN,
    F_MILLIS,
} f_code_t;

// Map exposed ioreqs to CSRs
const uvm32_mapping_t env[] = {
    { .csr = IOREQ_PRINTLN, .typ = IOREQ_TYP_BUF_TERMINATED_WR, .code = F_PRINTLN },
    { .csr = IOREQ_PRINT, .typ = IOREQ_TYP_BUF_TERMINATED_WR, .code = F_PRINT },
    { .csr = IOREQ_PRINTD, .typ = IOREQ_TYP_U32_WR, .code = F_PRINTD },
    { .csr = IOREQ_PRINTX, .typ = IOREQ_TYP_U32_WR, .code = F_PRINTX },
    { .csr = IOREQ_PRINTC, .typ = IOREQ_TYP_U32_WR, .code = F_PRINTC },
    { .csr = IOREQ_MILLIS, .typ = IOREQ_TYP_U32_RD, .code = F_MILLIS },
};

static uint8_t *read_file(const char* filename, int *len) {
    FILE* f = fopen(filename, "rb");
    uint8_t *buf = NULL;

    if (f == NULL) {
        fprintf(stderr, "error: can't open file '%s'.\n", filename);
        return NULL;
    }

    fseek(f, 0, SEEK_END);
    size_t file_size = ftell(f);
    rewind(f);

    if (NULL == (buf = malloc(file_size))) {
        fclose(f);
        return NULL;
    }

    size_t result = fread(buf, sizeof(uint8_t), file_size, f);
    if (result != file_size) {
        fprintf(stderr, "error: while reading file '%s'\n", filename);
        free(buf);
        fclose(f);
        return NULL;
    }

    *len = file_size;
    return buf;
}

void hexdump(const uint8_t *p, int len) {
    while(len--) {
        printf("%02x", *p++);
    }
}


int main(int argc, char *argv[]) {
    uvm32_state_t vmst;

    argc--;
    argv++;

    if (argc < 1) {
        printf("<romfile>\n");
        return 1;
    }

    int romlen = 0;
    uint8_t *rom = read_file(argv[0], &romlen);
    if (NULL == rom) {
        printf("file read failed!\n");
        return 1;
    }

    uvm32_init(&vmst, env, sizeof(env) / sizeof(env[0]));
    if (!uvm32_load(&vmst, rom, romlen)) {
        printf("load failed!\n");
        return 1;
    }

    uvm32_evt_t evt;
    bool isrunning = true;
    uint32_t total_instrs = 0;
    uint32_t num_ioreqs = 0;

    while(isrunning) {
        total_instrs += uvm32_run(&vmst, &evt, 100);   // num instructions before vm considered hung
        num_ioreqs++;

        switch(evt.typ) {
            case UVM32_EVT_END:
                printf("UVM32_EVT_END\n");
                isrunning = false;
            break;
            case UVM32_EVT_YIELD:
                //printf("UVM32_EVT_YIELD\n");
                // program has paused, but no ioreq
            break;
            case UVM32_EVT_ERR:
                printf("UVM32_EVT_ERR '%s' (%d)\n", evt.data.err.errstr, (int)evt.data.err.errcode);
                isrunning = false;
            break;
            case UVM32_EVT_IOREQ:
                switch((f_code_t)evt.data.ioreq.code) {
                    case F_PRINT:
                        printf("%.*s", evt.data.ioreq.val.buf.len, evt.data.ioreq.val.buf.ptr);
                    break;
                    case F_PRINTLN:
                        printf("%.*s\n", evt.data.ioreq.val.buf.len, evt.data.ioreq.val.buf.ptr);
                    break;
                    case F_PRINTD:
                        printf("%d\n", evt.data.ioreq.val.u32);
                    break;
                    case F_PRINTC:
                        printf("%c", evt.data.ioreq.val.u32);
                    break;
                    case F_PRINTX:
                        printf("%08x", evt.data.ioreq.val.u32);
                    break;
                    case F_MILLIS: {
                        static uint32_t t = 0;
                        *evt.data.ioreq.val.u32p = t;
                        t++;
                    } break;
                    default:    // catch any others
                        switch(evt.data.ioreq.typ) {
                            case IOREQ_TYP_BUF_TERMINATED_WR:
                                printf("IOREQ_TYP_BUF_TERMINATED_WR code=%d val=", evt.data.ioreq.code);
                                hexdump(evt.data.ioreq.val.buf.ptr, evt.data.ioreq.val.buf.len);
                                printf("\n");
                            break;
                            case IOREQ_TYP_VOID:
                                printf("IOREQ_TYP_VOID code=%d\n", evt.data.ioreq.code);
                            break;
                            case IOREQ_TYP_U32_WR:
                                printf("IOREQ_TYP_U32_WR code=%d val=%d (0x%08x)\n", evt.data.ioreq.code, evt.data.ioreq.val.u32, evt.data.ioreq.val.u32);
                            break;
                            case IOREQ_TYP_U32_RD:
                                printf("IOREQ_TYP_U32_RD code=%d\n", evt.data.ioreq.code);
                                *evt.data.ioreq.val.u32p = 123456;
                            break;
                        }
                    break;
                }
            break;
            default:
                printf("Bad evt %d\n", evt.typ);
                return 1;
            break;
        }
    }

    printf("Executed total of %d instructions and %d ioreqs\n", (int)total_instrs, (int)num_ioreqs);

    free(rom);
    return 0;
}
