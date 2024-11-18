;layout: (12 bytes)
;struct{
;	float x,y,z;
;}

section .data
	print_format db "(%.3f, %.3f, %.3f)",10,0
	print_float db "%.3f",10,0
	zero dd 0.0
	epsilon dd 0.0001

section .bss
	print_helper resb 8

section .text
	extern printf

	global vec3_print		;void vec3_print(vec3* vector)
	global vec3_init		;void vec3_init(vec3* buffer, float x, float y, float z)
	global vec3_initUniform		;void vec3_initUniform(vec3* buffer, float value)	//fills the vector with the same value
	global vec3_add			;void vec3_add(vec3* buffer, vec3* a, vec3* b)			//buffer may point to a or b
	global vec3_sub			;void vec3_sub(vec3* buffer, vec3* a, vec3* b)			//buffer may point to a or b
	global vec3_dot			;void vec3_dot(vec3* a, vec3* b)			//returns the value on the FPU stack
	global vec3_cross		;void vec3_cross(vec3* buffer, vec3* a, vec3* b)	//buffer may point to a or b
	global vec3_scale		;void vec3_scale(vec3* vec, float factor)
	global vec3_sqrMagnitude	;float vec3_sqrMagnitude(vec3* vec)			//returns the value on the FPU stack
	global vec3_magnitude		;float vec3_magnitude(vec3* vec)			//returns the value on the FPU stack
	global vec3_normalize		;void vec3_normalize(vec3* vec)			
	
vec3_print:
	push ebp
	mov ebp, esp
	
	mov ecx, dword[ebp+8]	;vec3* in ecx
	
	;init args
	fld dword[ecx+8]		;push z(4 bytes) onto the fpu stack
	fstp qword[print_helper]	;pop z (8 bytes) from the fpu stack
	push dword[print_helper+4]	;push the MSB of our double onto the stack
	push dword[print_helper]	;push the LSB...
	
	fld dword[ecx+4]
	fstp qword[print_helper]
	push dword[print_helper+4]
	push dword[print_helper]
	
	fld dword[ecx]
	fstp qword[print_helper]
	push dword[print_helper+4]
	push dword[print_helper]
	
	mov eax, print_format
	push eax
	call printf
	add esp, 28
	
	mov esp, ebp
	pop ebp
	ret
	
	
vec3_init:
	push ebp
	mov ebp,esp
	
	mov eax, dword[ebp+8]	;vec3* in eax
	
	mov ecx, dword[ebp+12]	;x in ecx
	mov dword[eax], ecx
	mov ecx, dword[ebp+16]	;y in ecx
	mov dword[eax+4], ecx
	mov ecx, dword[ebp+20]	;z in ecx
	mov dword[eax+8], ecx
	
	mov esp, ebp
	pop ebp
	ret
	
vec3_initUniform:
	mov eax, dword[esp+4]	;vec3* in eax
	mov ecx, dword[esp+8]	;value in ecx
	mov dword[eax], ecx
	mov dword[eax+4], ecx
	mov dword[eax+8], ecx
	ret
	
vec3_add:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+12]		;a in eax
	mov ecx, dword[ebp+16]		;b in ecx
	
	;push all of the numbers to the fpu stack
	fld dword[eax]		;a.x
	fld dword[ecx]		;b.x
	fld dword[eax+4]	;a.y
	fld dword[ecx+4]	;b.y
	fld dword[eax+8]	;a.z
	fld dword[ecx+8]	;b.z
	
	;do the calculations and pop the numbers from the fpu stack
	mov eax, dword[ebp+8]	;buffer in eax
	
	faddp			;add the two z values
	fstp dword[eax+8]	;store the new z
	faddp
	fstp dword[eax+4]
	faddp
	fstp dword[eax]
	
	mov esp, ebp
	pop ebp
	ret
	

vec3_sub:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+12]		;a in eax
	mov ecx, dword[ebp+16]		;b in ecx
	
	;push all of the numbers to the fpu stack
	fld dword[eax]		;a.x
	fld dword[ecx]		;b.x
	fld dword[eax+4]	;a.y
	fld dword[ecx+4]	;b.y
	fld dword[eax+8]	;a.z
	fld dword[ecx+8]	;b.z
	
	;do the calculations and pop the numbers from the fpu stack
	mov eax, dword[ebp+8]	;buffer in eax
	
	fsubp			;add the two z values
	fstp dword[eax+8]	;store the new z
	fsubp
	fstp dword[eax+4]
	fsubp
	fstp dword[eax]
	
	mov esp, ebp
	pop ebp
	ret
	
vec3_dot:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]	;a in eax
	mov ecx, dword[ebp+12]	;b in ecx
	
	fld dword[eax]
	fld dword[ecx]
	fmulp
	fld dword[eax+4]
	fld dword[ecx+4]
	fmulp
	fld dword[eax+8]
	fld dword[ecx+8]
	fmulp
	
	faddp
	faddp
	
	mov esp, ebp
	pop ebp
	ret
	
vec3_cross:
	push ebp
	mov ebp, esp
	
	sub esp, 12		;alloc space for temporary vector
	
	mov eax, dword[ebp+8]	;&buffer in 
	mov ecx, dword[ebp+12]	;&a in ecx
	mov edx, dword[ebp+16]	;&b in edx
	
	;calculate x
	fld dword[ecx+4]
	fld dword[edx+8]
	fmulp
	fld dword[ecx+8]
	fld dword[edx+4]
	fmulp
	fsubp
	fstp dword[esp]
	
	;calculate y
	fld dword[ecx+8]
	fld dword[edx]
	fmulp
	fld dword[ecx]
	fld dword[edx+8]
	fmulp
	fsubp
	fstp dword[esp+4]
	
	;calculate z
	fld dword[ecx]
	fld dword[edx+4]
	fmulp
	fld dword[ecx+4]
	fld dword[edx]
	fmulp
	fsubp
	fstp dword[esp+8]
	
	;copying the result into the buffer
	mov edx, dword[esp]
	mov dword[eax], edx
	mov edx, dword[esp+4]
	mov dword[eax+4], edx
	mov edx, dword[esp+8]
	mov dword[eax+8], edx
	
	mov esp, ebp
	pop ebp
	ret
	
	
vec3_scale:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;&vec in eax
	
	movss xmm1, dword[ebp+12]	;scale factor in xmm1
	
	movss xmm0, dword[eax]
	mulss xmm0, xmm1
	movss dword[eax], xmm0
	
	movss xmm0, dword[eax+4]
	mulss xmm0, xmm1
	movss dword[eax+4], xmm0
	
	movss xmm0, dword[eax+8]
	mulss xmm0, xmm1
	movss dword[eax+8], xmm0
	
	mov esp, ebp
	pop ebp
	ret
	
vec3_sqrMagnitude:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	lea ecx, zero
	movss xmm1, dword[ecx]
	
	movups xmm0,[eax]
	insertps xmm0, xmm1, 0b00110000	;fill in the last element with 0.0 (mask meaning: https://www.officedaytime.com/simd512e/simdimg/si.php?f=insertps figure 1)
	
	vmulps xmm0, xmm0	;elementwise multiplication
	haddps xmm0, xmm0	;felixcloutier.com/x86/haddps
	haddps xmm0, xmm0	;the sum of the four elements are in the lower 32 bits of xmm0
	
	sub esp, 4
	movss dword[esp], xmm0
	fld dword[esp]
	
	mov esp, ebp
	pop ebp
	ret
	
vec3_magnitude:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	push eax
	call vec3_sqrMagnitude
	add esp, 4
	fsqrt
	
	mov esp, ebp
	pop ebp
	ret
	
vec3_normalize:
	push ebp
	mov ebp, esp
	
	sub esp, 16	;alloc space for temporary vector
	sub esp, 4	;alloc space for temporary value
	
	;get length
	mov eax, dword[ebp+8]
	push eax
	call vec3_magnitude
	pop eax
	fstp dword[ebp-20]
	
	
	;check if the vector is a null vector
	mov ecx, epsilon
	movss xmm1, dword[ecx]		;epsilon in xmm1
	movss xmm0, dword[ebp-20]	;length in xmm0
	ucomiss xmm0, xmm1
	jb normalize_done
	
	;fill up the 4 slots of xmm0 with the length (https://www.officedaytime.com/simd512e/simdimg/si.php?f=shufps figure 1)
	movss xmm1, xmm0	;length also in xmm1
	shufps xmm0, xmm1, 0b00000000
	
	sub esp, 16
	movups [esp], xmm0
	push eax
	push ecx
	lea eax, [esp+8]
	push eax
	call vec3_print
	add esp, 4
	pop ecx
	pop eax
	add esp, 16
	
	;vector in xmm1, the 4th value is zeroed
	movups xmm1, [eax]		;movups, mert a movaps koveteli a 16 byte-os igazitast
	insertps xmm1, xmm1, 0b00001000
	
	;divide
	divps xmm1, xmm0
	
	;save result
	movups [ebp-16], xmm1
	
	mov ecx, dword[ebp-16]
	mov dword[eax], ecx
	mov ecx, dword[ebp-12]
	mov dword[eax+4], ecx
	mov ecx, dword[ebp-8]
	mov dword[eax+8], ecx
	
normalize_done:
	mov esp, ebp
	pop ebp
	ret
