all:
	nasm -felf32 -o vec3.o ../glm3/vec3.asm
	nasm -felf32 -o vec4.o ../glm3/vec4.asm
	nasm -felf32 -o mat3.o ../glm3/mat3.asm
	nasm -felf32 -o mat4.o ../glm3/mat4.asm
	nasm -felf32 -o camera.o camera.asm
	nasm -felf32 -o camera_test.o camera_test.asm
	gcc -m32 vec3.o vec4.o mat3.o mat4.o camera.o camera_test.o -o program -lX11 -nostartfiles
	echo "\n\n"
	./program
	echo "\n\n"
	rm vec3.o
	rm vec4.o
	rm mat3.o
	rm mat4.o
	rm camera.o
	rm camera_test.o
	rm program
