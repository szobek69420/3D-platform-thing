all:
	nasm -felf32 -o math.o math.asm
	nasm -felf32 -o math_test.o math_test.asm
	gcc -m32 -o program math.o math_test.o -nostartfiles
	echo "\n\n"
	./program
	echo "\n\n"
	rm program
	rm math.o
	rm math_test.o
