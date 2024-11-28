section .rodata
	print_coords_format db "screen coords: %d, %d",10,0

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
	
	sub esp, 8	;x, y
	
	lea ecx, [esp+4]
	mov eax, dword[ebp+28]		;a in eax
	
	push ecx
	sub ecx, 4
	push ecx
	push eax
	call renderer_vec3ToScreenCoords
	add esp, 12
	
	mov eax, esp
	
	push dword[eax+4]
	push dword[eax]
	push print_coords_format
	call printf
	add esp, 12
	
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
