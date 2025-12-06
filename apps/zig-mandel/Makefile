all:
	# zig's objcopy is broken, so use external tool
	# https://ziggit.dev/t/addobjcopy-producing-zero-padding-at-start-of-binary/13384
	zig build && docker run -v `pwd`:/data -w /data --rm riscv-dev riscv64-unknown-elf-objcopy zig-out/bin/mandel -O binary mandel.bin

clean:
	rm -rf mandel.bin zig-out .zig-cache

test: all
	../../emulator/emulator mandel.bin


