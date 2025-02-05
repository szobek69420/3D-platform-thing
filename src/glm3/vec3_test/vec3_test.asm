section .data:
	init_values dd 69.42,42.69,-69.69
	initUniform_value dd 2.0
	float_print_format db "%.3f",10,0
	scale_value dd 3.0
	
section .text:
	extern printf
	extern vec3_print
	extern vec3_init
	extern vec3_initUniform
	extern vec3_add
	extern vec3_sub
	extern vec3_dot
	extern vec3_cross
	extern vec3_scale
	extern vec3_sqrMagnitude
	extern vec3_magnitude
	extern vec3_normalize
	
	global _start:
_start:
	push ebp
	mov ebp, esp
	
	fninit			;init FPU
	
	sub esp, 12		;alloc space for vector1
	sub esp, 12		;alloc space for vector2
	
	;call init on vector1
	mov eax, init_values
	push dword[eax+8]
	push dword[eax+4]
	push dword[eax]
	lea eax, [ebp-12]
	push eax
	call vec3_init
	add esp, 16
	
	;call initUniform on vector2
	mov eax, initUniform_value
	push dword[eax]
	lea eax, [ebp-24]
	push eax
	call vec3_initUniform
	add esp, 8
	
	;call print on vector1 and vector2
	lea eax, [ebp-12]
	push eax
	call vec3_print
	lea eax, [ebp-24]
	mov dword[esp], eax
	call vec3_print
	add esp, 4
	
	;vector1+=vector2
	lea eax, [ebp-12]	;&vector1 in eax
	lea ecx, [ebp-24]	;&vector2 in ecx
	push ecx
	push eax
	push eax
	call vec3_add
	add esp, 12
	
	;call print on vector1 and vector2
	lea eax, [ebp-12]
	push eax
	call vec3_print
	lea eax, [ebp-24]
	mov dword[esp], eax
	call vec3_print
	add esp, 4
	
	;vector1-=vector2
	lea eax, [ebp-12]	;&vector1 in eax
	lea ecx, [ebp-24]	;&vector2 in ecx
	push ecx
	push eax
	push eax
	call vec3_sub
	add esp, 12
	
	;call print on vector1 and vector2
	lea eax, [ebp-12]
	push eax
	call vec3_print
	lea eax, [ebp-24]
	mov dword[esp], eax
	call vec3_print
	add esp, 4
	
	;dot test
	lea eax, [ebp-12]
	push eax
	lea eax, [ebp-24]
	push eax
	call vec3_dot
	add esp, 8
	
	;retrieve vec3_dot return value and print it
	sub esp,8
	fstp qword[esp]
	mov eax, float_print_format
	push eax
	call printf
	add esp, 12
	
	;vector1 = vector1 x vector2
	lea eax, [ebp-24]
	push eax
	lea eax, [ebp-12]
	push eax
	push eax
	call vec3_cross
	add esp, 12
	
	;call print on vector1 and vector2
	lea eax, [ebp-12]
	push eax
	call vec3_print
	lea eax, [ebp-24]
	mov dword[esp], eax
	call vec3_print
	add esp, 4
	
	;test scale on vector2
	mov eax, scale_value
	push dword[eax]
	lea eax, [ebp-24]
	push eax
	push eax
	call vec3_scale
	add esp,8
	
	;call print on vector1 and vector2
	lea eax, [ebp-12]
	push eax
	call vec3_print
	lea eax, [ebp-24]
	mov dword[esp], eax
	call vec3_print
	add esp, 4
	
	;get the length of vector1 and print it
	lea eax, [ebp-12]
	push eax
	call vec3_magnitude
	add esp,4
	
	sub esp,8
	fstp qword[esp]
	mov eax, float_print_format
	push eax
	call printf
	add esp, 12
	
	;normalize vector1 and print it
	lea eax, [ebp-12]
	push eax
	call vec3_normalize
	call vec3_print
	add esp, 4
	
	;normalize null vector
	mov dword[ebp-24], 0
	mov dword[ebp-20], 0
	mov dword[ebp-16], 0
	lea eax, [ebp-24]
	push eax
	call vec3_normalize
	add esp, 4
	
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 80h
