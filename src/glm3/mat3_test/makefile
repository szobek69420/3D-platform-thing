all:
	nasm -f elf32 -o vec3.o ../vec3.asm
	nasm -f elf32 -o mat3.o ../mat3.asm
	nasm -f elf32 -o mat3_test.o mat3_test.asm
	gcc -m32 -o mat3_test vec3.o mat3.o mat3_test.o -nostartfiles
	echo "\n\n"
	./mat3_test
	echo "\n\n"
	rm vec3.o
	rm mat3.o
	rm mat3_test.o
	rm mat3_test
