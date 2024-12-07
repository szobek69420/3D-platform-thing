all:
	echo "sugus"

install:
	apt install libX11.dev:i386

amogus:
	mkdir -p build
	nasm -felf32 -o ./build/vector.o ./vector/vector.asm
	nasm -felf32 -o ./build/vec3.o ./glm3/vec3.asm
	nasm -felf32 -o ./build/vec4.o ./glm3/vec4.asm
	nasm -felf32 -o ./build/mat3.o ./glm3/mat3.asm
	nasm -felf32 -o ./build/mat4.o ./glm3/mat4.asm
	nasm -felf32 -o ./build/window.o ./window/window.asm
	nasm -felf32 -o ./build/renderer.o ./renderer/renderer.asm
	nasm -felf32 -o ./build/renderable.o ./renderer/renderable.asm
	nasm -felf32 -o ./build/collider.o ./physics/collider.asm
	nasm -felf32 -o ./build/collider_group.o ./physics/collider_group.asm
	nasm -felf32 -o ./build/physics.o ./physics/physics.asm
	nasm -felf32 -o ./build/input.o ./input/input.asm
	nasm -felf32 -o ./build/camera.o ./camera/camera.asm
	nasm -felf32 -o ./build/player.o ./player/player.asm
	nasm -felf32 -o ./build/ulala.o ./ulala.asm
	gcc -m32 -o ./build/program \
	./build/vector.o \
	./build/vec3.o \
	./build/vec4.o \
	./build/mat3.o \
	./build/mat4.o \
	./build/window.o \
	./build/renderer.o \
	./build/renderable.o \
	./build/collider.o \
	./build/collider_group.o \
	./build/physics.o \
	./build/input.o \
	./build/camera.o \
	./build/player.o \
	./build/ulala.o -lX11 -nostartfiles
	find . -name "*.o" -delete
