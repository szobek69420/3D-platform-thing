section .rodata
	print_coords_format db "screen coords: %d, %d, %.3f",10,0
	print_deltas_format db "%.3f, %.3f",10,0
	print_line_break_format db 10,0
	print_int_format db "%d",10,0

	HALF dd 0.5
	F255 dd 255.0
	
section .bss
	FRAMEBUFFER_BYTES_PER_LINE resb 4

section .text
	extern printf
	extern memcpy
	extern memset
	
	extern FRAMEBUFFER_WIDTH
	extern FRAMEBUFFER_HEIGHT
	extern FRAMEBUFFER_WIDTH_FLOAT
	extern FRAMEBUFFER_HEIGHT_FLOAT
	
	global renderer_renderTriangle		;void renderer_renderTriangle(ScreenInfo* screen, int colour, vec3* a, vec3* b, vec3* c)
	
renderer_vec3ToScreenCoords:		;void renderer_vec3ToScreenCoords(vec3*, int* x, int* y) //it expects a clip space vec3
	push ebp
	mov ebp, esp
	
	mov ecx, dword[ebp+12]
	mov edx, dword[ebp+16]
	
	mov eax, dword[ebp+8]
	movss xmm0, dword[eax]		;vec3.x in xmm0
	push dword[eax+4]
	xor dword[esp], 0x80000000
	movss xmm1, dword[esp]	;inverted vec3.y in xmm1
	add esp, 4
	insertps xmm0, xmm1, 0b00010000	;vec3.x and vec3.y in xmm0
	
	movss xmm1, dword[HALF]
	shufps xmm1, xmm2, 0		;xmm1's lower 2 slots are filled with 0.5
	
	mulps xmm0, xmm1
	addps xmm0, xmm1
	
	
	movss xmm1, dword[FRAMEBUFFER_WIDTH_FLOAT]
	mulss xmm0, xmm1
	movss dword[ecx], xmm0		;save x
	fld dword[ecx]
	fistp dword[ecx]
	
	
	insertps xmm0, xmm0, 0b01000000
	movss xmm1, dword[FRAMEBUFFER_HEIGHT_FLOAT]
	mulss xmm0, xmm1
	movss dword[edx], xmm0		;save y
	fld dword[edx]
	fistp dword[edx]
	
	mov esp, ebp
	pop ebp
	ret
	
	
renderer_renderTriangle:
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	mov eax, dword[FRAMEBUFFER_WIDTH]
	shl eax, 2
	mov dword[FRAMEBUFFER_BYTES_PER_LINE], eax
	
	sub esp, 8	;deltaLeftBoundX, deltaRightBoundX
	sub esp, 8	;tempLeftBoundX, tempRightBoundX
	sub esp, 12	;x1, y1, depth1
	sub esp, 12	;x2, y2, depth2
	sub esp, 12	;x2_right, y2_right, depth2_right
	sub esp, 12	;x3, y3, depth3
	
	;calculate screen coords
	lea ecx, [esp+40]
	mov eax, dword[ebp+28]		;a in eax
	mov edx, dword[eax+8]
	mov dword[ecx+4], edx
	push ecx
	sub ecx, 4
	push ecx
	push eax
	call renderer_vec3ToScreenCoords
	add esp, 12
	
	lea ecx, [esp+28]
	mov eax, dword[ebp+32]		;b in eax
	mov edx, dword[eax+8]
	mov dword[ecx+4], edx
	push ecx
	sub ecx, 4
	push ecx
	push eax
	call renderer_vec3ToScreenCoords
	add esp, 12
	
	lea ecx, [esp+4]
	mov eax, dword[ebp+36]		;c in eax
	mov edx, dword[eax+8]
	mov dword[ecx+4], edx
	push ecx
	sub ecx, 4
	push ecx
	push eax
	call renderer_vec3ToScreenCoords
	add esp, 12

	
	;depths from [0,1] to [0, 255]
	movss xmm1, dword[F255]
	
	movss xmm0, dword[esp+44]
	mulss xmm0, xmm1
	movss dword[esp+44], xmm0
	
	movss xmm0, dword[esp+32]
	mulss xmm0, xmm1
	movss dword[esp+32], xmm0
	
	movss xmm0, dword[esp+8]
	mulss xmm0, xmm1
	movss dword[esp+8], xmm0
	
	
	;sort vertices based on y coords in descending order
	mov eax, dword[esp+40]
	cmp eax, dword[esp+28]
	jle _renderTriangle_height_sort_1
	
	mov eax, dword[esp+24]
	mov ecx, dword[esp+36]
	mov dword[esp+24], ecx
	mov dword[esp+36], eax
	
	mov eax, dword[esp+28]
	mov ecx, dword[esp+40]
	mov dword[esp+28], ecx
	mov dword[esp+40], eax
	
	mov eax, dword[esp+32]
	mov ecx, dword[esp+44]
	mov dword[esp+32], ecx
	mov dword[esp+44], eax
	
_renderTriangle_height_sort_1:

	mov eax, dword[esp+28]
	cmp eax, dword[esp+4]
	jle _renderTriangle_height_sort_2
	
	mov eax, dword[esp]
	mov ecx, dword[esp+24]
	mov dword[esp], ecx
	mov dword[esp+24], eax
	
	mov eax, dword[esp+28]
	mov ecx, dword[esp+4]
	mov dword[esp+28], ecx
	mov dword[esp+4], eax
	
	mov eax, dword[esp+32]
	mov ecx, dword[esp+8]
	mov dword[esp+32], ecx
	mov dword[esp+8], eax
	
_renderTriangle_height_sort_2:

	mov eax, dword[esp+40]
	cmp eax, dword[esp+28]
	jle _renderTriangle_height_sort_3
	
	mov eax, dword[esp+24]
	mov ecx, dword[esp+36]
	mov dword[esp+24], ecx
	mov dword[esp+36], eax
	
	mov eax, dword[esp+28]
	mov ecx, dword[esp+40]
	mov dword[esp+28], ecx
	mov dword[esp+40], eax
	
	mov eax, dword[esp+32]
	mov ecx, dword[esp+44]
	mov dword[esp+32], ecx
	mov dword[esp+44], eax
	
_renderTriangle_height_sort_3:
	
	;calculate x2_right and y2_right (the point on the other side at the same height as point2)
	;y
	mov eax, dword[esp+28]
	mov dword[esp+16], eax
	;x
	fild dword[esp+28]
	fild dword[esp+40]
	fsubp
	fild dword[esp+4]
	fild dword[esp+40]
	fsubp
	fdivp
	fild dword[esp]
	fild dword[esp+36]
	fsubp
	fmulp
	fild dword[esp+36]
	faddp
	fistp dword[esp+12]
	;z
	fild dword[esp+28]
	fild dword[esp+40]
	fsubp
	fild dword[esp+4]
	fild dword[esp+40]
	fsubp
	fdivp
	fld dword[esp+8]
	fld dword[esp+44]
	fsubp
	fmulp
	fld dword[esp+44]
	faddp
	fstp dword[esp+20]
	
	;switch the point2 and point2 right, so that point2 is the one with the greater x coordinate
	mov eax, dword[esp+12]
	cmp eax, dword[esp+24]
	jge _renderTriangle_point2s_swapped
	
	mov eax, dword[esp+24]
	mov ecx, dword[esp+12]
	mov dword[esp+24], ecx
	mov dword[esp+12], eax
	
	mov eax, dword[esp+28]
	mov ecx, dword[esp+16]
	mov dword[esp+28], ecx
	mov dword[esp+16], eax
	
	mov eax, dword[esp+32]
	mov ecx, dword[esp+20]
	mov dword[esp+32], ecx
	mov dword[esp+20], eax
	
_renderTriangle_point2s_swapped:

	;calculate the deltaDepthX (xmm0)
	movss xmm0, dword[esp+20]
	movss xmm1, dword[esp+32]
	subss xmm0, xmm1
	mov eax, dword[esp+12]
	sub eax, dword[esp+24]
	inc eax		;hogy ne legyen 0-val osztas
	push eax
	fild dword[esp]
	fstp dword[esp]
	movss xmm1, dword[esp]
	divss xmm0, xmm1
	add esp, 4

	;render first sub-triangle
_renderTriangle_first_subtriangle:
	mov eax, dword[esp+40]
	cmp eax, dword[esp+28]
	je _renderTriangle_second_subtriangle		;the first sub triangle has a height of 0
	
	;calculate deltaDepthY (xmm1)
	movss xmm1, dword[esp+32]
	movss xmm2, dword[esp+44]
	subss xmm1, xmm2
	mov eax, dword[esp+28]
	sub eax, dword[esp+40]
	inc eax		;ismet hogy ne legyen 0-val osztas
	push eax
	fild dword[esp]
	fstp dword[esp]
	movss xmm2, dword[esp]
	divss xmm1, xmm2
	add esp, 4
	
	;calculate deltaLeftBoundX and set tempLeftBoundX (float)
	mov eax, dword[esp+24]
	sub eax, dword[esp+36]
	mov dword[ebp-16], eax
	fild dword[ebp-16]
	mov eax, dword[esp+28]
	sub eax, dword[esp+40]
	mov dword[ebp-16], eax
	fild dword[ebp-16]
	fdivp
	fstp dword[ebp-8]
	
	fild dword[esp+36]
	fstp dword[ebp-16]
	
	
	;calculate deltaRightBoundX and set tempRightBoundX(float)
	mov eax, dword[esp+12]
	sub eax, dword[esp+36]
	mov dword[ebp-12], eax
	fild dword[ebp-12]
	mov eax, dword[esp+16]
	sub eax, dword[esp+40]
	mov dword[ebp-12], eax
	fild dword[ebp-12]
	fdivp
	fstp dword[ebp-4]
	
	fild dword[esp+36]
	fstp dword[ebp-12]
	
	;prepare for draw
	mov eax, dword[ebp+20]
	mov eax, dword[eax+28]		;drawbuffer in eax
	
	mov ebx, dword[ebp+24]		;colour in ebx
	
	mov ecx, dword[esp+40]		;y index in ecx
	movss xmm2, dword[esp+44]	;z in xmm2
_renderTriangle_first_subtriangle_outer_loop_start:
	cmp ecx, 0
	jl _renderTriangle_first_subtriangle_outer_loop_continue
	cmp ecx, dword[FRAMEBUFFER_HEIGHT]
	jge _renderTriangle_first_subtriangle_outer_loop_continue
	
	movss xmm3, xmm2		;current depth in xmm3

	mov esi, dword[FRAMEBUFFER_BYTES_PER_LINE]
	imul esi, ecx
	add esi, eax
	mov edi, esi
	
	push eax		;save eax
	push ecx		;save ecx
	sub esp, 4
	fld dword[ebp-16]
	fistp dword[esp]
	mov edx, dword[esp]
	mov eax, edx
	shl edx, 2
	add esi, edx
	
	fld dword[ebp-12]
	fistp dword[esp]
	mov edx, dword[esp]
	shl edx, 2
	add edi, edx
	
	add esp, 4
	sub esp, 4	;temp z
_renderTriangle_first_subtriangle_inner_loop_start:
	cmp eax, 0
	jl _renderTriangle_first_subtriangle_inner_loop_continue
	cmp eax, dword[FRAMEBUFFER_WIDTH]
	jge _renderTriangle_first_subtriangle_inner_loop_continue
	
	;depth test
	movss dword[esp], xmm3
	fld dword[esp]
	fistp dword[esp]
	
	mov ecx, dword[esp]
	cmp ecx, 0
	jl _renderTriangle_first_subtriangle_inner_loop_continue
	cmp ecx, 255
	jg _renderTriangle_first_subtriangle_inner_loop_continue
	cmp cl, byte[esi+3]
	ja _renderTriangle_first_subtriangle_inner_loop_continue	;ja, mert unsigned
	
	mov dword[esi], ebx
	mov byte[esi+3], cl
	
_renderTriangle_first_subtriangle_inner_loop_continue:
	addss xmm3, xmm0		;add deltaDepthX
	inc eax
	add esi, 4
	cmp esi, edi
	jle _renderTriangle_first_subtriangle_inner_loop_start
	add esp, 4
	pop ecx			;restore ecx
	pop eax			;restore eax
	
_renderTriangle_first_subtriangle_outer_loop_continue:
	fld dword[ebp-16]
	fld dword[ebp-8]
	faddp
	fstp dword[ebp-16]
	
	fld dword[ebp-12]
	fld dword[ebp-4]
	faddp
	fstp dword[ebp-12]
	
	addss xmm2, xmm1		;add deltaDepthY
	
	inc ecx
	cmp ecx, dword[esp+16]
	jl _renderTriangle_first_subtriangle_outer_loop_start
	
	
	;render second sub-triangle
_renderTriangle_second_subtriangle:
	mov eax, dword[esp+28]
	cmp eax, dword[esp+4]
	je _renderTriangle_done		;the second sub triangle has a height of 0
	
	;calculate deltaDepthY (xmm1)
	movss xmm1, dword[esp+8]
	movss xmm2, dword[esp+32]
	subss xmm1, xmm2
	mov eax, dword[esp+4]
	sub eax, dword[esp+28]
	inc eax		;ismet hogy ne legyen 0-val osztas
	push eax
	fild dword[esp]
	fstp dword[esp]
	movss xmm2, dword[esp]
	divss xmm1, xmm2
	add esp, 4
	
	;calculate deltaLeftBoundX and set tempLeftBoundX (float)
	mov eax, dword[esp]
	sub eax, dword[esp+24]
	mov dword[ebp-16], eax
	fild dword[ebp-16]
	mov eax, dword[esp+4]
	sub eax, dword[esp+28]
	mov dword[ebp-16], eax
	fild dword[ebp-16]
	fdivp
	fstp dword[ebp-8]
	
	fild dword[esp+24]
	fstp dword[ebp-16]
	
	
	;calculate deltaRightBoundX and set tempRightBoundX(float)
	mov eax, dword[esp]
	sub eax, dword[esp+12]
	mov dword[ebp-12], eax
	fild dword[ebp-12]
	mov eax, dword[esp+4]
	sub eax, dword[esp+16]
	mov dword[ebp-12], eax
	fild dword[ebp-12]
	fdivp
	fstp dword[ebp-4]
	
	fild dword[esp+12]
	fstp dword[ebp-12]
	
	;prepare for draw
	mov eax, dword[ebp+20]
	mov eax, dword[eax+28]		;drawbuffer in eax
	
	mov ebx, dword[ebp+24]		;colour in ebx
	
	mov ecx, dword[esp+28]		;y index in ecx
	movss xmm2, dword[esp+32]	;z in xmm2
_renderTriangle_second_subtriangle_outer_loop_start:
	cmp ecx, 0
	jl _renderTriangle_second_subtriangle_outer_loop_continue
	cmp ecx, dword[FRAMEBUFFER_HEIGHT]
	jge _renderTriangle_second_subtriangle_outer_loop_continue
	
	movss xmm3, xmm2		;current depth in xmm3

	mov esi, dword[FRAMEBUFFER_BYTES_PER_LINE]
	imul esi, ecx
	add esi, eax
	mov edi, esi
	
	push eax		;save eax
	push ecx		;save ecx
	sub esp, 4
	fld dword[ebp-16]
	fistp dword[esp]
	mov edx, dword[esp]
	mov eax, edx
	shl edx, 2
	add esi, edx
	
	fld dword[ebp-12]
	fistp dword[esp]
	mov edx, dword[esp]
	shl edx, 2
	add edi, edx
	
	add esp, 4
	sub esp, 4	;temp z
_renderTriangle_second_subtriangle_inner_loop_start:
	cmp eax, 0
	jl _renderTriangle_second_subtriangle_inner_loop_continue
	cmp eax, dword[FRAMEBUFFER_WIDTH]
	jge _renderTriangle_second_subtriangle_inner_loop_continue
	
	;depth test
	movss dword[esp], xmm3
	fld dword[esp]
	fistp dword[esp]
	
	mov ecx, dword[esp]
	cmp ecx, 0
	jl _renderTriangle_second_subtriangle_inner_loop_continue
	cmp ecx, 255
	jg _renderTriangle_second_subtriangle_inner_loop_continue
	cmp cl, byte[esi+3]
	ja _renderTriangle_second_subtriangle_inner_loop_continue	;ja, mert unsigned
	
	mov dword[esi], ebx
	mov byte[esi+3], cl
	
_renderTriangle_second_subtriangle_inner_loop_continue:
	addss xmm3, xmm0		;add deltaDepthX
	inc eax
	add esi, 4
	cmp esi, edi
	jle _renderTriangle_second_subtriangle_inner_loop_start
	add esp, 4
	pop ecx			;restore ecx
	pop eax			;restore eax
	
_renderTriangle_second_subtriangle_outer_loop_continue:
	fld dword[ebp-16]
	fld dword[ebp-8]
	faddp
	fstp dword[ebp-16]
	
	fld dword[ebp-12]
	fld dword[ebp-4]
	faddp
	fstp dword[ebp-12]
	
	addss xmm2, xmm1		;add deltaDepthY
	
	inc ecx
	cmp ecx, dword[esp+4]
	jl _renderTriangle_second_subtriangle_outer_loop_start
	
	
_renderTriangle_done:
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
