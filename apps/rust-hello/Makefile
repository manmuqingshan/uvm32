all:
	cargo build -r --target riscv32im-unknown-none-elf && docker run -v `pwd`:/data -w /data --rm riscv-dev riscv64-unknown-elf-objcopy target/riscv32im-unknown-none-elf/release/rust-hello -O binary rust-hello.bin

test: all
	../../emulator/emulator rust-hello.bin

clean:
	rm -rf rust-hello.bin target
