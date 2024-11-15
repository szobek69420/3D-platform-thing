section .data 
	format db "cucc: %d",10,0
	format_print_elements db "the %d. element is: %d",10,0
	vector_info db "size:  %d, capacity: %d",10,0
	vector_element db "%d ",0
	
section .text
	extern printf
	extern vector_init
	extern vector_destroy
	extern vector_clear
	extern vector_push_back
	extern vector_pop_back
	extern vector_insert
	extern vector_remove_at
	
	global _start
	
_start:
	push ebp
	mov ebp, esp
	
	
	;alloc vector
	sub esp, 16
	
	;init vector
	push 4
	lea eax, [ebp-16]
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
	lea eax, [ebp-16]
	push eax
	call _print_vector
	add esp, 4
	
	lea eax, [ebp-16]
	push eax
	call vector_pop_back
	call vector_pop_back
	pop eax
	
	;print vector
	lea eax, [ebp-16]
	push eax
	call _print_vector
	add esp, 4
	
	;insert test
	lea eax, [ebp-16]
	push 23
	push 3
	push eax
	call vector_insert
	add esp, 12
	
	;print vector
	lea eax, [ebp-16]
	push eax
	call _print_vector
	add esp, 4
	
	;remove_at test
	lea eax, [ebp-16]
	push 4
	push eax
	call vector_remove_at
	mov dword[esp+4],7
	call vector_remove_at
	mov dword[esp+4],0
	call vector_remove_at
	add esp,8
	
	;print vector
	lea eax, [ebp-16]
	push eax
	call _print_vector
	add esp, 4

	
	;clear vector
	lea eax, [ebp-16]
	push eax
	call vector_clear
	add esp, 4
	
	lea eax, [ebp-16]
	push 69
	push eax
	call vector_push_back
	mov dword[esp+4], 420
	call vector_push_back
	add esp, 8
	
	;print vector
	lea eax, [ebp-16]
	push eax
	call _print_vector
	add esp, 4
	
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
	
	
_print_vector: 	;void _print_vector(vector*)
	push ebp
	mov ebp, esp
	
	mov ecx, dword [ebp+8]	;vector* in ecx
	
	push esi	;save esi
	push ebx	;save ebx
	
	mov esi, dword[ecx]	;size in esi
	mov ebx, dword[ecx+12]		;current element* in ebx
	
	;print size and capacity
	mov eax, dword[ecx+4]
	push eax
	push esi
	mov eax, vector_info
	push eax
	call printf
	add esp, 12
	
	;print elements
	
_print_vector_loop_start:
	cmp esi, 0
	jle _print_vector_loop_end
	
	mov eax, dword[ebx]
	push eax
	mov eax, vector_element
	push eax
	call printf
	add esp, 8
	
	add ebx, 4
	dec esi
	
	jmp _print_vector_loop_start

_print_vector_loop_end:
	push 0
	push 10
	mov eax, esp
	push eax
	call printf
	add esp,12

	pop ebx	;restore ebx
	pop esi		;restore esi
	
	mov esp, ebp
	pop ebp
	ret
	
