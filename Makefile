all:
	(cd emulator && make)
	(cd emulator-mini && make)
	(cd emulator-parallel && make)
	#(cd apps && make)  # do not build apps by default, as they require a variety of dev tools

clean:
	(cd emulator && make clean)
	(cd emulator-mini && make clean)
	(cd emulator-parallel && make clean)
	(cd apps && make clean)

