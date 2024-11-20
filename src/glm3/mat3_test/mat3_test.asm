section .rodata
	init_message db "init mat1 and mat2",10,0
	add_message db "mat2+=mat1",10,0
	add_message_itself db "mat1+=mat1",10,0
	sub_message db "mat2-=mat1", 10,0
	transpose_message db "mat2 transposed: ",10,0
	mul_message db "mat2*=mat2:",10,0
	scalarMul_message db "mat2*=0.69",10,0
	vectorMul_message db "mat2*vector",10,0
	det_message db "determinant of mat2: %.5f",10,0
	det_message2 db "morbed mat2:",10,0
	inverse_message db "mat2 inverted:",10,0
	
section .data
	init_value dd 2.0
	initDetailed_values dd 1.0,2.1,3.2,4.3,5.4,6.5,7.6,8.7,9.8
	scalarMul_value dd 0.69
	random_value dd -23.69
	vector_values dd 2.3, -0.59, 10.4
	
section .text
	extern printf
	
	extern mat3_print
	extern mat3_init
	extern mat3_initDetailed
	extern mat3_add
	extern mat3_sub
	extern mat3_transpose
	extern mat3_mul
	extern mat3_scalarMul
	extern mat3_det
	extern mat3_inverse
	
	extern vec3_print
	extern vec3_mulWithMat
	extern vec3_init
	
	global _start
_start:
	push ebp
	mov ebp, esp
	
	
	sub esp, 36		;alloc space for mat1
	sub esp, 36		;alloc space for mat2
	
	;init test on mat1
	mov eax, dword[init_value]
	push eax
	lea eax, [ebp-36]
	push eax
	call mat3_init
	add esp, 8
	
	;initDetailed test on mat2
	mov eax, initDetailed_values
	push eax
	lea eax, [ebp-72]
	push eax
	call mat3_initDetailed
	add esp,8
	
	;print mat1 and mat2
	lea eax, [ebp-36]
	push eax
	call mat3_print
	lea eax, [ebp-72]
	mov dword[esp], eax
	call mat3_print
	add esp, 4
	
	;test addition to itself
	lea eax, [ebp-36]
	push eax
	push eax
	push eax
	call mat3_add
	add esp, 12
	
	push add_message_itself
	call printf
	
	;print mat1
	lea eax, [ebp-36]
	push eax
	call mat3_print
	
	;test normal addition
	lea eax, [ebp-36]
	push eax
	lea eax, [ebp-72]
	push eax
	push eax
	call mat3_add
	add esp, 12
	
	push add_message
	call printf
	add esp, 4
	
	;print mat1 and mat2
	lea eax, [ebp-36]
	push eax
	call mat3_print
	lea eax, [ebp-72]
	mov dword[esp], eax
	call mat3_print
	add esp, 4
	
	
	;test sub
	lea eax, [ebp-36]
	push eax
	lea eax, [ebp-72]
	push eax
	push eax
	call mat3_sub
	add esp, 16
	
	push sub_message
	call printf
	add esp, 4
	
	;print mat1 and mat2
	lea eax, [ebp-36]
	push eax
	call mat3_print
	lea eax, [ebp-72]
	mov dword[esp], eax
	call mat3_print
	add esp, 4
	
	;test transpose
	push transpose_message
	call printf
	add esp, 4
	
	lea eax, [ebp-72]
	push eax
	call mat3_transpose
	call mat3_print
	add esp, 4
	
	
	;test multiplication
	push mul_message
	call printf
	add esp, 4
	
	lea eax, [ebp-72]		;&mat2 in eax
	push eax
	push eax
	push eax
	call mat3_print
	call mat3_mul
	call mat3_print
	add esp, 12
	
	;test scalarMul
	push scalarMul_message
	call printf
	add esp, 4
	
	mov eax, dword[scalarMul_value]
	push eax
	lea eax, [ebp-72]
	push eax
	push eax
	call mat3_scalarMul
	call mat3_print
	add esp, 12
	
	;test multiplication with vec3
	push vectorMul_message
	call printf
	add esp, 4
	
	sub esp, 12	;temp vector
	mov eax, dword[vector_values+8]
	push eax
	mov eax, dword[vector_values+4]
	push eax
	mov eax, dword[vector_values]
	push eax
	lea eax, [esp+12]
	push eax
	call vec3_init
	call vec3_print
	add esp, 16
	
	lea eax, [ebp-72]
	push eax
	call mat3_print
	lea eax, [esp+4]
	push eax
	call vec3_mulWithMat
	call vec3_print
	add esp, 20
	
	;test determinant
	push det_message2
	call printf
	lea eax, [ebp-72]
	mov ecx, dword[random_value]
	mov dword[eax+8], ecx
	mov dword[esp], eax
	call mat3_print
	add esp, 4
	
	sub esp, 4
	lea eax, [ebp-72]
	push eax
	call mat3_det
	fstp qword[esp]
	push det_message
	call printf
	add esp, 12
	
	;test inverse
	push inverse_message
	call printf
	add esp, 4
	
	lea eax, [ebp-72]
	push eax
	push eax
	call mat3_inverse
	call mat3_print
	add esp, 8
	
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
