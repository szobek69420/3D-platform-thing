section .rodata
	print_float_format db "%.3f",10,0
	
	number1 dd 1.6
	number2 dd -3.5
	number3 dd 0.17
	number4 dd 0.08
	
section .text
	extern printf
	
	extern math_powf
	extern math_lerp
	extern math_basedLerp
	
	global _start
_start:
	push ebp
	mov ebp, esp
	
	finit
	
	push ebp	;save ebp
	mov ebp, 20
	_pow_test_loop_start:			;test multiply times so that it makes sure the fpu stack is cleared correctlys
		push dword[number2]
		push dword[number1]
		call math_powf
		add esp, 8
		
		sub esp, 8
		fstp qword[esp]
		push print_float_format
		call printf
		add esp, 12
		dec ebp
		cmp ebp, 0
		jg _pow_test_loop_start
	pop ebp		;restore ebp
	
	
	;test lerp
	push dword[number3]
	push dword[number2]
	push dword[number1]
	call math_lerp
	fstp qword[esp+4]
	mov dword[esp], print_float_format
	call printf
	add esp, 12
	
	
	;test based lerp
	push ebp		;save ebp
	mov ebp, 20
	_basedLerp_test_loop_start:
		push dword[number4]
		push dword[number3]
		push dword[number2]
		push dword[number1]
		call math_basedLerp
		fstp qword[esp+4]
		mov dword[esp], print_float_format
		call printf
		add esp, 16
		dec ebp
		cmp ebp, 0
		jg _basedLerp_test_loop_start
	pop ebp		;restore ebp
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
