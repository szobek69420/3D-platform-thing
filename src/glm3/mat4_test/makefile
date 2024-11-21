all:
	nasm -f elf32 -o vec4.o ../vec4.asm
	nasm -f elf32 -o mat3.o ../mat3.asm
	nasm -f elf32 -o mat4.o ../mat4.asm
	nasm -f elf32 -o mat4_test.o mat4_test.asm
	gcc -m32 -o program vec4.o mat3.o mat4.o mat4_test.o -nostartfiles
	echo "\n\n"
	./program
	echo "\n\n"
	rm vec4.o
	rm mat3.o
	rm mat4.o
	rm mat4_test.o
	rm program
