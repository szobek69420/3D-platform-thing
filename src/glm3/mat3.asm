;layout:
;struct{
; float a00, a01, a02;
; float a10, a11, a12;
; float a20, a21, a22;
;}
;each float is 4 bytes long

section .data
	print_line db "| %.3f, %.3f, %.3f |",10,0

section .text
	extern printf
	extern memcpy
	extern memset
	
	global mat3_print		;void mat3_print(mat3* mat)
	global mat3_init		;void mat3_init(mat3* buffer, float value)	//fills the hauptdiagonale with the given value
	global mat3_initDetailed	;void mat3_initDetailed(mat3* buffer, float* values)
	global mat3_add			;void mat3_add(mat3* buffer, mat3* a, mat3* b)		//buffer may point to a or b
	global mat3_sub			;void mat3_sub(mat3* buffer, mat3* a, mat3* b)		//buffer may point to a or b
	
mat3_print:
	mov eax, dword[esp+4]	;&mat in eax
	
	push ebx		;save ebx
	push edi		;save edi
	
	sub esp, 24		;alloc space for 3 doubles
	push print_line
	
	mov ebx, eax		;&mat in ebx
	mov edi, 3
_print_loop_start:
	fld dword[ebx]
	fld dword[ebx+4]
	fld dword[ebx+8]
	fstp qword[esp+20]
	fstp qword[esp+12]
	fstp qword[esp+4]
	call printf
	
	add ebx, 12
	dec edi
	cmp edi, 0
	jg _print_loop_start
	
	add esp, 28
	
	;line break
	push 0
	push 10
	lea eax, [esp]
	push eax
	call printf
	add esp, 12
	
	pop edi			;restore edi
	pop ebx			;restore ebx
	ret
	
mat3_init:
	mov eax, dword[esp+4]	;buffer in eax
	mov ecx, dword[esp+8]	;value in ecx
	
	push ecx	;save ecx
	push 36
	push 0
	push eax
	call memset
	pop eax		;restore eax
	add esp, 8
	pop ecx		;restore ecx
	
	;set the hauptdiagonale
	mov dword[eax], ecx
	mov dword[eax+16], ecx
	mov dword[eax+32], ecx
	
	ret
	
	
mat3_initDetailed:
	mov eax, dword[esp+4]	;buffer in eax
	mov ecx, dword[esp+8]	;&values in ecx
	
	push 36
	push ecx
	push eax
	call memcpy
	add esp, 12
	
	ret
	

mat3_add:
	mov eax, dword[esp+4]	;buffer in eax
	mov ecx, dword[esp+8]	;a in ecx
	mov edx, dword[esp+12]	;b in edx
	
	push edi	;store edi
	push ebx	;store ebx
	
	sub esp, 36	;alloc space for temporary matrix
	
	mov edi, 9
	mov ebx, esp

	;a==b?
	cmp ecx, edx
	je _add_equal_loop_start

_add_not_equal_loop_start:
	movss xmm0, dword[ecx]
	movss xmm1, dword[edx]
	addss xmm0, xmm1
	movss dword[ebx], xmm0
	
	add ebx, 4
	add ecx, 4
	add edx, 4
	dec edi
	cmp edi, 0
	jg _add_not_equal_loop_start
	
	jmp _add_copy_data
	
_add_equal_loop_start:
	movss xmm0, dword[ecx]
	addss xmm0, xmm0
	movss dword[ebx], xmm0
	
	add ebx, 4
	add ecx, 4
	dec edi
	cmp edi, 0
	jg _add_equal_loop_start
	
_add_copy_data:

	lea ebx, [esp]		;temp matrix in ebx
	push 36
	push ebx
	push eax
	call memcpy
	add esp, 12
	
	add esp, 36
	pop ebx		;restore ebx
	pop edi		;restore edi
	
	ret
	
	
mat3_sub:
	mov eax, dword[esp+4]	;buffer in eax
	mov ecx, dword[esp+8]	;a in ecx
	mov edx, dword[esp+12]	;b in edx
	
	push edi	;store edi
	push ebx	;store ebx
	
	sub esp, 36	;alloc space for temporary matrix
	
	mov edi, 9
	mov ebx, esp

	;a==b?
	cmp ecx, edx
	je _sub_equal

_sub_not_equal_loop_start:
	movss xmm0, dword[ecx]
	movss xmm1, dword[edx]
	subss xmm0, xmm1
	movss dword[ebx], xmm0
	
	add ebx, 4
	add ecx, 4
	add edx, 4
	dec edi
	cmp edi, 0
	jg _sub_not_equal_loop_start
	
	jmp _sub_copy_data
	
_sub_equal:
	push eax	;save eax
	push 36
	push 0
	push ebx
	call memset
	add esp, 12
	pop eax		;restore eax
	
_sub_copy_data:

	lea ebx, [esp]		;temp matrix in ebx
	push 36
	push ebx
	push eax
	call memcpy
	add esp, 12
	
	add esp, 36
	pop ebx		;restore ebx
	pop edi		;restore edi
	
	ret
