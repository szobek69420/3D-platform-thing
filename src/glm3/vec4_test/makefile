all:
	nasm -f elf32 -o vec4.o ../vec4.asm
	nasm -f elf32 -o vec4_test.o vec4_test.asm
	gcc -m32 -o vec4_test vec4.o vec4_test.o -nostartfiles
	echo "\n\n"
	./vec4_test
	echo "\n\n"
	rm vec4.o
	rm vec4_test.o
	rm vec4_test
