section .rodata
	init_message db "mat1 and mat2 initialized",10,0
	add_message db "mat2+=mat1",10,0
	sub_message db "mat2-=mat1",10,0
	transpose_message db "mat2 transposed:",10,0
	mul_message db "mat2*=mat2",10,0
	scalarMul_message db "mat2*=0.5",10,0
	death_message db "det(mat2): %.3f",10,0
	
section .data
	init_value dd 0.69
	initDetailed_values dd 1.5, 8.1, -2.8, 0.23, 5.1, -2.1, 4.2, -6.9, 0.4, -9.11, 0.911, 7.1, 2.6, -3.31, -8.4, 0.2
	scalarMul_value dd -0.5

section .text
	extern printf
	extern memcpy
	
	extern mat4_print
	extern mat4_init
	extern mat4_initDetailed
	
	extern mat4_add
	extern mat4_sub
	extern mat4_mul
	extern mat4_scalarMul
	
	extern mat4_transpose
	extern mat4_det
	
	global _start
_start:
	push ebp
	mov ebp, esp
	
	finit
	
	sub esp, 64		;mat1
	sub esp, 64		;mat2
	
	;init matrices
	push init_message
	call printf
	add esp, 4
	
	mov eax, dword[init_value]
	push eax
	lea eax, [ebp-64]
	push eax
	call mat4_init
	add esp, 8
	
	push initDetailed_values
	lea eax, [ebp-128]
	push eax
	call mat4_initDetailed
	add esp, 8
	
	;print matrices
	lea eax, [ebp-64]
	push eax
	call mat4_print
	sub dword[esp], 64
	call mat4_print
	add esp, 4
	
	
	
	;add test	
	push add_message
	call printf
	add esp, 4
	
	lea eax, [ebp-64]
	push eax
	lea eax, [ebp-128]
	push eax
	push eax
	call mat4_add
	add esp, 12
	
	;print matrices
	lea eax, [ebp-64]
	push eax
	call mat4_print
	sub dword[esp], 64
	call mat4_print
	add esp, 4
	
	
	
	;sub test	
	push sub_message
	call printf
	add esp, 4
	
	lea eax, [ebp-64]
	push eax
	lea eax, [ebp-128]
	push eax
	push eax
	call mat4_sub
	add esp, 12
	
	;print matrices
	lea eax, [ebp-64]
	push eax
	call mat4_print
	sub dword[esp], 64
	call mat4_print
	add esp, 4
	
	;transpose test
	push transpose_message
	call printf
	add esp, 4
	
	lea eax, [ebp-128]
	push eax
	call mat4_transpose
	call mat4_print
	add esp, 4
	
	
	;multiply test
	push mul_message
	call printf
	add esp, 4
	
	lea eax, [ebp-128]
	push eax
	push eax
	push eax
	call mat4_mul
	call mat4_print
	add esp, 12
	
	;scalarMul test
	push scalarMul_message
	call printf
	add esp, 4
	
	mov eax, dword[scalarMul_value]
	push eax
	lea eax, [ebp-128]
	push eax
	push eax
	call mat4_scalarMul
	call mat4_print
	add esp, 12
	
	;det test
	lea eax, [ebp-128]
	sub esp, 4
	push eax
	call mat4_det
	fstp qword[esp]
	push death_message
	call printf
	add esp, 12
	
	
	
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
