all:
	nasm -f elf32 -o vector.o vector.asm
	nasm -f elf32 -o vector_test.o vector_test.asm
	gcc -m32 -o vector_test vector.o vector_test.o -nostartfiles
	echo "\n\n"
	./vector_test
	echo "\n\n"
	rm vector.o
	rm vector_test.o
	rm vector_test
