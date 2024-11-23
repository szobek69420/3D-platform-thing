all:
	nasm -felf32 -o window.o window.asm
	nasm -felf32 -o window_test.o window_test.asm
	gcc -m32 -o program window.o window_test.o -lX11 -nostartfiles
	echo "\n\n"
	./program
	echo "\n\n"
	rm window.o
	rm window_test.o
	rm program
