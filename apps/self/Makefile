TOPDIR=../..
PROJECT:=$(shell basename ${PWD})
SRCS=${PROJECT}.c ${TOPDIR}/apps/common/crt0.S ${TOPDIR}/uvm32/uvm32.c
CFLAGS=-DUVM32_MEMORY_SIZE=8192 -DCUSTOM_STDLIB_H=\"uvm32_target.h\" -I../../uvm32
all:
	@echo "const unsigned char mandel[] = {" > mandel.h
	@cat ${TOPDIR}/precompiled/mandel.bin | xxd -i >> mandel.h
	@echo "};\nunsigned int mandel_len = " >> mandel.h
	@wc -c ${TOPDIR}/precompiled/mandel.bin | awk '{print $$1}' >> mandel.h
	@echo ";" >> mandel.h
	make all_common
test: test_common
clean: clean_common
include ${TOPDIR}/apps/common/makefile.common
