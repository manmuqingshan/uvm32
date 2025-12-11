# The purpose of this Makefile is to auto-generate the Arduino example
# Arduino cannot set -DUVM32_MEMORY_SIZE, so add a config file
# Arduino expects .cpp files

make:
	echo '#include "config.h"' > uvm32.cpp
	cat ../uvm32/uvm32.c >> uvm32.cpp
	cp ../uvm32/uvm32.h uvm32.h
	cp ../uvm32/mini-rv32ima.h mini-rv32ima.h
	cp ../common/uvm32_common_custom.h uvm32_common_custom.h
	cp ../common/uvm32_sys.h uvm32_sys.h
	xxd -i ../precompiled/mandel.bin | sed -e "s/unsigned char/const unsigned char/" > mandel.h

clean:
	rm -f uvm32.cpp uvm32.h mini-rv32ima.h uvm32_common_custom.h uvm32_sys.h mandel.h
