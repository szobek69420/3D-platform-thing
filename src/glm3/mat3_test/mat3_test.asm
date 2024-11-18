section .rodata
	init_message db "init mat1 and mat2",10,0
	add_message db "mat2+=mat1",10,0
	add_message_itself db "mat1+=mat1",10,0
	sub_message db "mat2-=mat1", 10,0
	
section .data
	init_value dd 2.0
	initDetailed_values dd 1.0,2.1,3.2,4.3,5.4,6.5,7.6,8.7,9.8
	
	
section .text
	extern printf
	
	extern mat3_print
	extern mat3_init
	extern mat3_initDetailed
	extern mat3_add
	extern mat3_sub
	
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
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
