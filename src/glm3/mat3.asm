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
	global mat3_scalarMul		;void mat3_scalarMul(mat3* buffer, mat3* mat, float value)	//buffer can point to mat	
	global mat3_det			;float mat3_det(mat3* mat)		//pushes the result onto the FPU stack
	global mat3_inverse		;void mat3_inverse(mat3* buffer, mat3* mat)	//buffer can point to mat
	
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
	
	
mat3_scalarMul:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;&buffer in eax
	mov ecx, dword[ebp+12]		;&mat in ecx
	movss xmm0, dword[ebp+16]	;value in xmm0
	movss xmm1, xmm0
	shufps xmm0, xmm1, 0		;all slots in xmm0 are filled with value
	
	movups xmm1, [ecx]
	mulps xmm1, xmm0
	movups [eax], xmm1
	
	movups xmm1, [ecx+16]
	mulps xmm1, xmm0
	movups [eax+16], xmm1
	
	movss xmm1, dword[ecx+32]
	mulss xmm1, xmm0
	movss dword[eax+32], xmm1
	
	mov esp, ebp
	pop ebp
	ret
	
mat3_det:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;&mat in eax
	
	fld dword[eax]
	fld dword[eax+16]
	fld dword[eax+32]
	fmulp
	fld dword[eax+20]
	fld dword[eax+28]
	fmulp
	fsubp
	fmulp
	
	fld dword[eax+4]
	fld dword[eax+12]
	fld dword[eax+32]
	fmulp
	fld dword[eax+20]
	fld dword[eax+24]
	fmulp
	fsubp
	fmulp
	fsubp
	
	fld dword[eax+8]
	fld dword[eax+12]
	fld dword[eax+28]
	fmulp
	fld dword[eax+16]
	fld dword[eax+24]
	fmulp
	fsubp
	fmulp
	faddp
	
	mov esp, ebp
	pop ebp
	ret
	
	
mat3_inverse:
	push ebp
	mov ebp, esp
	
	sub esp, 36		;alloc space for temporary matrix
	sub esp, 16		;alloc space for temporary submatrix
	sub esp, 4		;current line offset (12 byte increment)
	sub esp, 4		;current column offset	(4 byte increment)
	sub esp, 4		;determinant
	
	;calculate determinant
	mov eax, dword[ebp+12]
	push eax
	call mat3_det
	add eax, 4
	fstp dword[ebp-64]
	
	push 36
	mov eax, dword[ebp+12]
	push eax
	lea eax, [ebp-36]
	push eax
	call memcpy
	add esp, 12
	
	push edi		;save edi
	push esi		;save esi
	push ebx		;save ebx
	
	movss xmm4, dword[ebp-64]
	mov ebx, 0		;negation indicator
	mov dword[ebp-56], 0
_inverse_line_loop_start:
	mov dword[ebp-60], 0
_inverse_column_loop_start:

	push ebx		;save ebx once again
	
	lea edx, [ebp-52]		;pointer to current element in the submatrix buffer
	mov eax, 0
_inverse_submatrix_line_loop_start:
	mov ecx, 0
_inverse_submatrix_column_loop_start:

	cmp eax, dword[ebp-56]		;check if the line is part of the submatrix
	je _inverse_submatrix_column_loop_continue
	cmp ecx, dword[ebp-60]		;check if the column is part of the submatrix
	je _inverse_submatrix_column_loop_continue
	
	lea ebx, [ebp-36]		;temp matrix buffer in ebx
	add ebx, eax
	add ebx, ecx
	mov ebx, dword[ebx]
	mov dword[edx], ebx
	
	add edx, 4			;increment submatrix buffer pointer
	
_inverse_submatrix_column_loop_continue:
	add ecx, 4
	cmp ecx, 12
	jl _inverse_submatrix_column_loop_start
	
	add eax, 12
	cmp eax, 36
	jl _inverse_submatrix_line_loop_start
	
	pop ebx			;restore ebx
	
	;here I have the submatrix in the submatrix buffer
	lea eax, [ebp-52]	;submatrix buffer in eax
	lea ecx, [ebp-36]
	add ecx, dword[ebp-56]
	add ecx, dword[ebp-60]	;current element pointer in ecx
	
	movss xmm1, dword[eax]
	movss xmm2, dword[eax+12]
	mulss xmm1, xmm2
	movss xmm2, dword[eax+4]
	movss xmm3, dword[eax+8]
	mulss xmm2, xmm3
	subss xmm1, xmm2
	
	movss xmm0, dword[ecx]
	mulss xmm0, xmm1
	divss xmm0, xmm4	;divide by determinant
	
	mov ecx, dword[ebp+8]
	add ecx, dword[ebp-56]
	add ecx, dword[ebp-60]	;current element pointer in buffer in ecx
	
	movss dword[ecx], xmm0
	xor dword[ecx], ebx
	
	xor ebx, 0x80000000	;negate the negation indicator
	
	add dword[ebp-60],4
	mov edx, dword[ebp-60]
	cmp edx, 12
	jl _inverse_column_loop_start
	
	add dword[ebp-56], 12
	mov edx, dword[ebp-56]
	cmp edx, 36
	jl _inverse_line_loop_start
	
	pop ebx			;restore ebx
	pop esi			;restore esi
	pop edi			;restore edi
	
	mov esp, ebp
	pop ebp
	ret
