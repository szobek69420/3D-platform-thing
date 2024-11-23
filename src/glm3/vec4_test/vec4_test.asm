section .data
	init_values dd 45.67, -98.12, 17.69, -87.2
	initUniform_value dd -4.2
	scale_value dd 0.69
	
	init_message db "init vectors",10,0
	add_message db "vector1+=vector2",10,0
	sub_message db "vector1-=vector2",10,0
	scale_message db "vector1 scaled by 0.69",10,0
	dot_message db "<vector1; vector2> = %.3f",10,0
	sqrMagnitude_message db "vector1 sqrmag: %.3f",10,0
	magnitude_message db "vector1 mag: %.3f",10,0
	normalize_message db "vector1 normalized: ",0
	
section .text
	extern memcpy
	extern printf
	
	extern vec4_print
	extern vec4_init
	extern vec4_initUniform
	extern vec4_add
	extern vec4_sub
	extern vec4_scale
	extern vec4_dot
	extern vec4_sqrMagnitude
	extern vec4_magnitude
	extern vec4_normalize
	
	global _start
	
_start:
	push ebp
	mov ebp, esp
	
	sub esp, 16		;alloc space for vector1
	sub esp, 16		;alloc space for vector2
	
	mov eax, init_message
	push eax
	call printf
	add esp, 4
	
	;init vector1
	mov eax, init_values
	mov ecx, dword[eax+12]
	push ecx
	mov ecx, dword[eax+8]
	push ecx
	mov ecx, dword[eax+4]
	push ecx
	mov ecx, dword[eax]
	push ecx
	lea eax, [ebp-16]
	push eax
	call vec4_init
	add esp, 20
	
	;init vector2
	mov eax, initUniform_value
	mov eax, dword[eax]
	push eax
	lea eax, [ebp-32]
	push eax
	call vec4_initUniform
	add esp, 8
	
	;print vector1 and vector2
	lea eax, [ebp-16]
	push eax
	call vec4_print
	lea eax, [ebp-32]
	mov dword[esp], eax
	call vec4_print
	add esp, 4
	
	;vector1+=vector2
	mov eax, add_message
	push eax
	call printf
	add esp, 4
	
	lea eax, [ebp-32]
	push eax
	lea eax, [ebp-16]
	push eax
	push eax
	call vec4_add
	add esp, 12
	
	;print vector1 and vector2
	lea eax, [ebp-16]
	push eax
	call vec4_print
	lea eax, [ebp-32]
	mov dword[esp], eax
	call vec4_print
	add esp, 4
	
	
	
	;vector1+=vector2
	mov eax, sub_message
	push eax
	call printf
	add esp, 4
	
	lea eax, [ebp-32]
	push eax
	lea eax, [ebp-16]
	push eax
	push eax
	call vec4_sub
	add esp, 12
	
	;print vector1 and vector2
	lea eax, [ebp-16]
	push eax
	call vec4_print
	lea eax, [ebp-32]
	mov dword[esp], eax
	call vec4_print
	add esp, 4
	
	
	;vector1*=0.69 and print it
	mov eax, scale_message
	push eax 
	call printf
	add esp, 4
	
	mov eax, scale_value
	mov eax, dword[eax]
	push eax
	lea eax, [ebp-16]
	push eax
	push eax
	call vec4_scale
	call vec4_print
	add esp, 12
	
	
	;dot product test
	lea eax, [ebp-16]
	push eax
	lea eax, [ebp-32]
	push eax
	call vec4_dot
	fstp qword[esp]
	mov eax, dot_message
	push eax
	call printf
	add esp, 12
	
	;sqrMagnitude and magnitude test
	lea eax, [ebp-16]
	push eax
	call vec4_sqrMagnitude
	sub esp, 8
	fstp qword[esp+4]
	mov dword[esp], sqrMagnitude_message
	call printf
	add esp, 12
	
	lea eax, [ebp-16]
	push eax
	call vec4_magnitude
	sub esp, 8
	fstp qword[esp+4]
	mov dword[esp], magnitude_message
	call printf
	add esp, 12
	
	;normalize vector1
	lea eax, [ebp-16]
	push eax
	call vec4_normalize
	add esp, 4
	
	push normalize_message
	call printf
	add esp, 4
	lea eax, [ebp-16]
	push eax
	call vec4_print
	add esp, 4
	
	;normalize null vector
	mov dword[ebp-32],0
	mov dword[ebp-28],0
	mov dword[ebp-24],0
	mov dword[ebp-20],0
	lea eax, [ebp-32]
	push eax
	call vec4_normalize
	add esp, 4
	
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 80h
