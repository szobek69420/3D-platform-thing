all:
	nasm -felf32 -o vec3.o ../glm3/vec3.asm
	nasm -felf32 -o vec4.o ../glm3/vec4.asm
	nasm -felf32 -o mat3.o ../glm3/mat3.asm
	nasm -felf32 -o mat4.o ../glm3/mat4.asm
	nasm -felf32 -o vector.o ../vector/vector.asm
	nasm -felf32 -o window.o window.asm
	nasm -felf32 -o window_test.o window_test.asm
	nasm -felf32 -o renderer.o ../renderer/renderer.asm
	nasm -felf32 -o renderable.o ../renderer/renderable.asm
	gcc -m32 -o program vec3.o mat3.o vec4.o mat4.o vector.o window.o renderer.o renderable.o window_test.o -lX11 -nostartfiles
	rm vec3.o
	rm vec4.o
	rm mat3.o
	rm mat4.o
	rm vector.o
	rm renderer.o
	rm renderable.o
	rm window.o
	rm window_test.o
