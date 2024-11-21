;layout:
;struct{
;	float m00, m01, m02, m03;
;	float m10, m11, m12, m13;
;	float m20, m21, m22, m23;
;	float m30, m31, m32, m33;
;}
;each float is 4 bytes

section .rodata
	print_line_format db "| %.3f %.3f %.3f %.3f |",10,0

section .text
	extern memcpy
	extern memset
	extern printf
	
	global mat4_print		;void mat4_print(mat4* mat)
	global mat4_init		;void mat4_init(mat4* buffer, float value)		;fills the hauptdiagonal with value
	global mat4_initDiagonal	;void mat4_initDiagonal(mat4* buffer, float a, float b, float c, float d)
	global mat4_initDetailed	;void mat4_initDetailed(mat4* buffer, float* values)
	
	global mat4_add			;void mat4_add(mat4* buffer, mat4* a, mat4* b)		//buffer can point to a or b
	global mat4_sub			;void mat4_sub(mat4* buffer, mat4* a, mat4* b)		//buffer can point to a or b
	global mat4_mul			;void mat4_mul(mat4* buffer, mat4* a, mat4* b)		//buffer can point to a or b
	global mat4_scalarMul		;void mat4_scalarMul(mat4* buffer, mat4* mat, float value)	//buffer can point to mat
	
	global mat4_transpose		;void mat4_transpose(mat4* mat)
	
mat4_print:
	push ebp
	push edi
	push esi
	mov ebp, esp
	
	sub esp, 32		;alloc space for function params
	push print_line_format
	
	mov edi, dword[ebp+16]	;mat in eax
	xor esi, esi
	
_print_loop_start:
	fld dword[edi]
	fstp qword[ebp-32]
	fld dword[edi+4]
	fstp qword[ebp-24]
	fld dword[edi+8]
	fstp qword[ebp-16]
	fld dword[edi+12]
	fstp qword[ebp-8]
	call printf
	
	add edi, 16
	inc esi
	cmp esi, 4
	jl _print_loop_start
	
	;print line break
	push 0
	push 10
	mov eax, esp
	push eax
	call printf
	
	mov esp, ebp
	pop esi
	pop edi
	pop ebp
	ret
	
	
mat4_init:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;buffer in eax
	
	push 64
	push 0
	push eax
	call memset
	pop eax
	
	mov ecx, dword[ebp+12]		;value in ecx
	
	mov dword[eax], ecx
	mov dword[eax+20], ecx
	mov dword[eax+40], ecx
	mov dword[eax+60], ecx
	
	mov esp, ebp
	pop ebp
	ret
	
	
mat4_initDiagonal:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;buffer in eax
	
	push 64
	push 0
	push eax
	call memset
	pop eax
	
	
	mov ecx, dword[ebp+12]		;value1 in ecx
	mov dword[eax], ecx
	
	mov ecx, dword[ebp+16]		;value2 in ecx
	mov dword[eax+20], ecx
	
	mov ecx, dword[ebp+20]		;value3 in ecx
	mov dword[eax+40], ecx
	
	mov ecx, dword[ebp+24]		;value4 in ecx
	mov dword[eax+60], ecx
	
	
	mov esp, ebp
	pop ebp
	ret
	
	
mat4_initDetailed:
	mov eax, dword[esp+4]		;buffer in eax
	mov ecx, dword[esp+8]		;data in ecx
	
	push 64
	push ecx
	push eax
	call memcpy
	add esp, 12
	
	ret
	
	
mat4_add:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;buffer in eax
	mov ecx, dword[ebp+12]		;a in ecx
	mov edx, dword[ebp+16]		;b in edx
	
	push edi
	
	xor edi, edi
_add_loop_start:
	movups xmm0, [ecx]
	movups xmm1, [edx]
	addps xmm0, xmm1
	movups [eax], xmm0
	
	add eax, 16
	add ecx, 16
	add edx, 16
	
	inc edi
	cmp edi , 4
	jl _add_loop_start
	
	pop edi
	
	mov esp, ebp
	pop ebp
	ret
	
	
mat4_sub:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;buffer in eax
	mov ecx, dword[ebp+12]		;a in ecx
	mov edx, dword[ebp+16]		;b in edx
	
	push edi
	
	xor edi, edi
_sub_loop_start:
	movups xmm0, [ecx]
	movups xmm1, [edx]
	subps xmm0, xmm1
	movups [eax], xmm0
	
	add eax, 16
	add ecx, 16
	add edx, 16
	
	inc edi
	cmp edi , 4
	jl _sub_loop_start
	
	pop edi
	
	mov esp, ebp
	pop ebp
	ret
	

mat4_mul:
	push ebp
	mov ebp, esp
	
	sub esp, 64		;temp result
	sub esp, 64		;b transposed (<a.line;b.column>=<a.line;bt.line>)
	
	;copy and transpose b
	push 64
	mov eax, dword[ebp+16]	;b in eax
	push eax
	lea eax, [ebp-128]
	push eax
	call memcpy
	call mat4_transpose
	add esp, 12
	
	;multipl
	push edi
	push esi
	push ebx
	
	lea eax, [ebp-64]	;temp buffer in eax
	mov ecx, dword[ebp+12]	;a in ecx
	lea edx, [ebp-128]	;b transposed in edx
	mov ebx, edx		;save for restore
	
	xor edi, edi		;line number
_mul_outer_loop_start:
	
	mov edx, ebx		;restore b transpose line offset
	xor esi, esi		;column number
_mul_inner_loop_start:
	movups xmm0, [ecx]
	movups xmm1, [edx]
	mulps xmm0, xmm1
	haddps xmm0, xmm0
	haddps xmm0, xmm0
	movss dword[eax], xmm0
	
	add eax, 4
	add edx, 16
	inc esi
	cmp esi, 4
	jl _mul_inner_loop_start
	
	add ecx, 16
	inc edi
	cmp edi, 4
	jl _mul_outer_loop_start
	
	
	pop ebx
	pop esi
	pop edi
	
	;copy the temp result into transpose
	lea eax, [ebp-64]
	mov ecx, dword[ebp+8]
	push 64
	push eax
	push ecx
	call memcpy
	
	
	mov esp, ebp
	pop ebp
	ret
	
	
	
mat4_scalarMul:
	push ebp
	mov ebp, esp
	
	movss xmm0, dword[ebp+16]
	movss xmm1, xmm0
	shufps xmm0, xmm1, 0		;xmm0 is filled with value
	
	mov eax, dword[ebp+8]		;buffer in eax
	mov ecx, dword[ebp+12]		;mat in ecx
	
	xor edx, edx
_scalarMul_loop_start:
	movups xmm1, [ecx]
	mulps xmm1, xmm0
	movups [eax], xmm1
	
	add eax, 16
	add ecx, 16
	inc edx
	cmp edx, 4
	jl _scalarMul_loop_start
	
	mov esp, ebp
	pop ebp
	ret
	
	
	
mat4_transpose:
	push ebp
	mov ebp, esp
	
	sub esp, 64		;temp mat
	
	;copy matrix to temp buffer
	mov eax, dword[ebp+8]
	push 64
	push eax
	lea eax, [ebp-64]
	push eax
	call memcpy
	add esp, 12
	
	;it's transposin' time
	push edi
	push esi
	push ebx
	
	mov eax, dword[ebp+8]	;buffer in eax
	lea ecx, [ebp-64]	;temp buffer in ecx
	
	xor edi, edi	;index1
_transpose_outer_loop_start:
	xor esi, esi	;index2
_transpose_inner_loop_start:
	mov edx, edi
	imul edx, 16
	lea edx, [edx+4*esi]
	mov ebx, dword[ecx+edx]
	
	mov edx, esi
	imul edx, 16
	lea edx, [edx+4*edi]
	mov dword[eax+edx], ebx
	
	inc esi
	cmp esi, 4
	jl _transpose_inner_loop_start
	
	inc edi
	cmp edi, 4
	jl _transpose_outer_loop_start
	
	pop ebx
	pop esi
	pop edi
	
	mov esp, ebp
	pop ebp
	ret
