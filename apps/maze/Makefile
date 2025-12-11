TOPDIR=../..
PROJECT:=$(shell basename ${PWD})
SRCS=${PROJECT}.c ${TOPDIR}/apps/crt0.S
OPT=-O2
CFLAGS+=-fpeel-loops
all: all_common
test: test_common
clean: clean_common
include ${TOPDIR}/apps/makefile.common
