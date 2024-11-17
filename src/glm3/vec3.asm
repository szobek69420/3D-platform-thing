;layout: (12 bytes)
;struct{
;	float x,y,z;
;}

section .data
	print_format db "(%.3f, %.3f, %.3f)",10,0

section .bss
	print_helper resb 8

section .text
	extern printf

	global vec3_print	;void vec3_print(vec3* vector)
	global vec3_init	;void vec3_init(vec3* buffer, float x, float y, float z)
	global vec3_initUniform	;void vec3_initUniform(vec3* buffer, float value)	//fills the vector with the same value
	global vec3_add		;void vec3_add(vec3* buffer, vec3* a, vec3* b)			//buffer may point to a or b
	global vec3_sub		;void vec3_sub(vec3* buffer, vec3* a, vec3* b)			//buffer may point to a or b
	global vec3_dot		;void vec3_dot(vec3* a, vec3* b)			//returns the value on the FPU stack
	
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
