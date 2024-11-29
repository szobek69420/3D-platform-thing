section .rodata
	print_coords_format db "screen coords: %d, %d, %.3f",10,0

	HALF dd 0.5

section .text
	extern printf
	extern memcpy
	extern memset
	
	extern FRAMEBUFFER_WIDTH
	extern FRAMEBUFFER_HEIGHT
	extern FRAMEBUFFER_WIDTH_FLOAT
	extern FRAMEBUFFER_HEIGHT_FLOAT
	
	global renderer_renderTriangle		;void renderer_renderTriangle(ScreenInfo* screen, int colour, vec3* a, vec3* b, vec3* c)
	
renderer_vec3ToScreenCoords:		;void renderer_vec3ToScreenCoords(vec3*, int* x, int* y) //it accepts a clip space vec3
	push ebp
	mov ebp, esp
	
	mov ecx, dword[ebp+12]
	mov edx, dword[ebp+16]
	
	mov eax, dword[ebp+8]
	movss xmm0, dword[eax]		;vec3.x in xmm0
	movss xmm1, dword[eax+4]	;vec3.y in xmm1
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
	movss dword[edx], xmm0
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
	
	;sort vertices based on y coords in descending order
	mov eax, dword[esp+40]
	cmp eax, dword[esp+28]
	jge _renderTriangle_height_sort_1
	
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
	jge _renderTriangle_height_sort_2
	
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
	jge _renderTriangle_height_sort_3
	
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
	
	lea eax, dword[esp+36]
	sub esp, 8
	fld dword[eax+8]
	fstp qword[esp]
	push dword[eax+4]
	push dword[eax]
	push print_coords_format
	call printf
	add esp, 20
	
	lea eax, dword[esp+24]
	sub esp, 8
	fld dword[eax+8]
	fstp qword[esp]
	push dword[eax+4]
	push dword[eax]
	push print_coords_format
	call printf
	add esp, 20
	
	lea eax, dword[esp+12]
	sub esp, 8
	fld dword[eax+8]
	fstp qword[esp]
	push dword[eax+4]
	push dword[eax]
	push print_coords_format
	call printf
	add esp, 20
	
	lea eax, dword[esp]
	sub esp, 8
	fld dword[eax+8]
	fstp qword[esp]
	push dword[eax+4]
	push dword[eax]
	push print_coords_format
	call printf
	add esp, 20
	
	
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
