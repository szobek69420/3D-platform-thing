section .data 
	format db "cucc: %d",10,0
	format_print_elements db "the %d. element is: %d",10,0
	
section .text
	extern printf
	extern vector_init
	extern vector_destroy
	extern vector_push_back
	
	global _start
	
_start:
	push ebp
	mov ebp, esp
	
	
	;alloc vector
	sub esp, 16
	
	;init vector
	push 4
	lea eax, [esp+4]
	push eax ;push the vector* for the return
	call vector_init
	add esp, 8
	
	;fil up vector
	push esi	;save esi
	mov esi, 0
	lea eax, [ebp-16]
_main_loop_start:
	cmp esi, 10
	jge _main_loop_end
	
	mov edx, 10
	sub edx, esi
	push edx
	push eax
	call vector_push_back
	pop eax
	add esp, 4
	
	inc esi
	jmp _main_loop_start
	
_main_loop_end:
	pop esi		;restore esi
	
	;print vector
	push esi	;save esi
	push edi	;save edi
	push ebx	;save ebx
	mov esi, dword[ebp-16]	;size in esi
	mov edi, 0
	mov ebx, dword[ebp-4]	;data* in ebx
_main_print_loop_start:
	cmp esi, edi
	jle _main_print_loop_end
	
	mov eax, dword[ebx]
	push eax
	push edi
	mov eax, format_print_elements
	push eax
	call printf
	add esp, 12
	
	inc edi
	add ebx, 4
	jmp _main_print_loop_start

_main_print_loop_end:
	pop ebx		;restore ebx
	pop edi		;resture edi
	pop esi		;restore esi
	
	;destroy vector
	lea eax, [ebp-16]
	push eax
	call vector_destroy
	add esp, 4
	
	
	;cleanup
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 80h
