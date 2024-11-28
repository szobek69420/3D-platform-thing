all:
	nasm -felf32 -o window.o window.asm
	nasm -felf32 -o window_test.o window_test.asm
	nasm -felf32 -o renderer.o ../renderer/renderer.asm
	gcc -m32 -o program window.o renderer.o window_test.o -lX11 -nostartfiles
	rm renderer.o
	rm window.o
	rm window_test.o
