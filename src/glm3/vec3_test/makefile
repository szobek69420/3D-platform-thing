all:
	nasm -f elf32 -o vec3.o ../vec3.asm
	nasm -f elf32 -o vec3_test.o vec3_test.asm
	gcc -m32 -o vec3_test vec3.o vec3_test.o -nostartfiles
	echo "\n\n"
	./vec3_test
	echo "\n\n"
	rm vec3.o
	rm vec3_test.o
	rm vec3_test
