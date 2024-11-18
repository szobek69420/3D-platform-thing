;layout:
;struct{
; float a, b, c, d; //egyenkent 4 byte
;}

section data
	print_format dd "(%.3f, %.3f, %.3f, %.3f)",10,0

section .text
	extern printf
	extern memcpy
	
	global vec4_print		;void vec4_print(vec4*)
	global vec4_init		;void vec4_init(vec4* buffer, float a, float b, float c, float d)
	global vec4_initUniform		;void vec4_initUniform(vec4* buffer, float value)
	
vec4_print:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	
	sub esp, 32	;alloc space for the 4 double args
	fld dword[eax]
	fstp qword[esp]
	fld dword[eax+4]
	fstp qword[esp+8]
	fld dword[eax+8]
	fstp qword[esp+16]
	fld dword[eax+12]
	fstp qword[esp+24]
	mov eax, print_format
	push eax
	call printf
	add esp, 36
	
	mov esp, ebp
	pop ebp
	ret
	
	
vec4_init:
	push ebp
	mov ebp, esp
	
	push 16
	lea eax, [ebp+12]
	push eax
	mov eax, dword[ebp+8]
	push eax
	call memcpy
	
	mov esp, ebp
	pop ebp
	ret
	
vec4_initUniform:
	mov eax, dword[esp+4]		;vec4* in eax
	mov ecx, dword[esp+8]		;value in ecx
	
	mov dword[eax], ecx
	mov dword[eax+4], ecx
	mov dword[eax+8], ecx
	mov dword[eax+12], ecx
	
	ret
