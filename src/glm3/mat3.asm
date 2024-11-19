;layout:
;struct{
; float a00, a01, a02;
; float a10, a11, a12;
; float a20, a21, a22;
;}
;each float is 4 bytes long

section .data
	print_line db "| %.3f, %.3f, %.3f |",10,0
	zero dd 0.0

section .text
	extern printf
	extern memcpy
	extern memset
	extern vec3_dot
	
	global mat3_print		;void mat3_print(mat3* mat)
	global mat3_init		;void mat3_init(mat3* buffer, float value)	//fills the hauptdiagonale with the given value
	global mat3_initDetailed	;void mat3_initDetailed(mat3* buffer, float* values)
	global mat3_add			;void mat3_add(mat3* buffer, mat3* a, mat3* b)		//buffer may point to a or b
	global mat3_sub			;void mat3_sub(mat3* buffer, mat3* a, mat3* b)		//buffer may point to a or b
	global mat3_transpose		;void mat3_transpose(mat3* mat)
	global mat3_mul			;void mat3_mul(mat3* buffer, mat3* a, mat3*)		//buffer can point to a or b
	
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
	
	
mat3_transpose:
	push ebp
	mov ebp, esp
	
	sub esp, 36		;alloc space for temporary matrix
	
	;copy matrix
	push 36
	mov eax, dword[ebp+8]	;&mat in eax
	push eax
	lea eax, [ebp-36]
	push eax
	call memcpy
	add esp, 12
	
	;move back the transposed values
	push edi	;save edi
	push esi	;save esi
	push ebx	;save ebx
	
	xor edi, edi	;line number
	xor esi, esi	;column number
	
	lea eax, [ebp-36]	;src* in eax
	mov ecx, dword[ebp+8]	;dst* in ecx
_transpose_outer_loop_start:
_transpose_inner_loop_start:
	mov ebx, edi
	imul ebx, 12
	lea ebx, [ebx+4*esi]
	add ebx, eax
	
	mov edx, dword[ebx]
	
	mov ebx, esi
	imul ebx, 12
	lea ebx, [ebx+4*edi]
	add ebx, ecx
	
	mov dword[ebx], edx
	
	inc esi
	cmp esi, 3
	jl _transpose_inner_loop_start
	
	xor esi, esi
	inc edi
	cmp edi, 3
	jl _transpose_outer_loop_start
	
	
	pop ebx		;restore ebx
	pop esi		;restore esi
	pop edi		;restore edi
	
	mov esp, ebp
	pop ebp
	ret
	
	
mat3_mul:
	push ebp
	mov ebp, esp
	
	sub esp, 36		;alloc space for temporary result matrix
	sub esp, 36		;alloc space for b's duplicate
	
	
	;copy b to the temporary space and transpose it
	push 36
	mov ecx, dword[ebp+16]		;b in ecx
	push ecx
	lea ecx, [ebp-72]
	push ecx
	call memcpy
	call mat3_transpose
	add esp, 12
	
	mov eax, dword[ebp+12]		;a in eax
	lea ecx, [ebp-72]		;b in ecx
	lea edx, [ebp-36]		;temporary buffer in edx
	
	push edi			;save edi
	push esi			;save esi
	push ebx			;save ebx
	push ebp			;save ebp
	
	mov edi, 0			;line offset
	mov esi, 0			;columns offset (actually line in the transposed one)
	
_line_loop_start:
	mov esi, 0
_column_loop_start:
	
	lea ebx, [eax+edi]	;current a* in ebx
	lea ebp, [ecx+esi]	;current b* in ebp
	
	movss xmm0, dword[zero]
	
	movss xmm1, dword[ebx]
	movss xmm2, dword[ebp]
	mulss xmm1, xmm2
	addss xmm0, xmm1
	
	movss xmm1, dword[ebx+4]
	movss xmm2, dword[ebp+4]
	mulss xmm1, xmm2
	addss xmm0, xmm1
	
	movss xmm1, dword[ebx+8]
	movss xmm2, dword[ebp+8]
	mulss xmm1, xmm2
	addss xmm0, xmm1
	
	movss dword[edx], xmm0
	add edx, 4		;increment buffer pointer
	
	add esi, 12
	cmp esi, 36
	jl _column_loop_start
	
	add edi, 12
	cmp edi, 36
	jl _line_loop_start
	
	pop ebp				;restore ebp
	pop ebx				;restore ebx
	pop esi				;restore esi
	pop edi				;restore edi
	
	;copy the temporary matrix into the buffer
	push 36
	lea eax, [ebp-36]
	push eax
	mov eax, dword[ebp+8]
	push eax
	call memcpy
	
	
	mov esp, ebp
	pop ebp
	ret
