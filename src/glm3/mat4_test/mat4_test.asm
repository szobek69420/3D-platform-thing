section .rodata
	init_message db "mat1 and mat2 initialized",10,0
	add_message db "mat2+=mat1",10,0
	sub_message db "mat2-=mat1",10,0
	transpose_message db "mat2 transposed:",10,0
	mul_message db "mat2*=mat2",10,0
	scalarMul_message db "mat2*=-0.5",10,0
	death_message db "det(mat2): %.3f",10,0
	inverse_message db "mat2 tenet: ",10,0
	scale_message db "mat2 scaled by ( 2.0, 3.0, 0.69, 1.5):",10,0
	translate_message db "mat1 translated by (2.0, 3.0, 0.69): ",10,0
	rotate_message db "mat1 rotated around (2.0, 3.0, 0.69) by 69 degrees:",10,0
	view_message db "mat1 is now a view matrix with pos=(3.1, 83.1, -2.0), direction=(-23.0, 0.4, 2.0), worldUp=(0.0, 1.0, 0.0)",10,0
	perspective_message db "mat1 is now a perspective matrix with fov=69.0, aspectXY=1.5, near=0.1, far=100.0",10,0
	ortho_message db "mat1 is now an orthogonal proj matrix with the values -69,69,-42,42,-6.9,6.9",10,0
	mulWithMat_message db "mat2*(2.0, 3.0, 0.69, 1.5):",10,0
	
	
section .data
	init_value dd 0.69
	initDetailed_values dd 1.5, 8.1, -2.8, 0.23, 5.1, -2.1, 4.2, -6.9, 0.4, -9.11, 0.911, 7.1, 2.6, -3.31, -8.4, 0.2
	scalarMul_value dd -0.5
	scale_values dd 2.0, 3.0, 0.69, 1.5
	rotational_angle dd 69.0
	
	position_values dd 3.1, 83.1, -2.0
	direction_values dd -23.0, 0.4, 2.0
	worldUp_values dd 0.0, 1.0, 0.0
	
	fov dd 69.0
	aspectXY dd 1.5
	near_clip dd 0.1
	far_clip dd 100.0
	
	ortho_left dd -69.0
	ortho_right dd 69.0
	ortho_bottom dd -42.0
	ortho_top dd 42.0
	ortho_near dd -6.9
	ortho_far dd 6.9

section .text
	extern printf
	extern memcpy
	
	extern mat4_print
	extern mat4_init
	extern mat4_initDetailed
	
	extern mat4_add
	extern mat4_sub
	extern mat4_mul
	extern mat4_scalarMul
	
	extern mat4_transpose
	extern mat4_det
	extern mat4_inverse
	
	extern mat4_scale
	extern mat4_translate
	extern mat4_rotate
	
	extern mat4_view
	extern mat4_perspective
	extern mat4_ortho
	
	extern vec4_mulWithMat
	extern vec4_print
	
	global _start
_start:
	push ebp
	mov ebp, esp
	
	finit
	
	sub esp, 64		;mat1
	sub esp, 64		;mat2
	
	;init matrices
	push init_message
	call printf
	add esp, 4
	
	mov eax, dword[init_value]
	push eax
	lea eax, [ebp-64]
	push eax
	call mat4_init
	add esp, 8
	
	push initDetailed_values
	lea eax, [ebp-128]
	push eax
	call mat4_initDetailed
	add esp, 8
	
	;print matrices
	lea eax, [ebp-64]
	push eax
	call mat4_print
	sub dword[esp], 64
	call mat4_print
	add esp, 4
	
	
	
	;add test	
	push add_message
	call printf
	add esp, 4
	
	lea eax, [ebp-64]
	push eax
	lea eax, [ebp-128]
	push eax
	push eax
	call mat4_add
	add esp, 12
	
	;print matrices
	lea eax, [ebp-64]
	push eax
	call mat4_print
	sub dword[esp], 64
	call mat4_print
	add esp, 4
	
	
	
	;sub test	
	push sub_message
	call printf
	add esp, 4
	
	lea eax, [ebp-64]
	push eax
	lea eax, [ebp-128]
	push eax
	push eax
	call mat4_sub
	add esp, 12
	
	;print matrices
	lea eax, [ebp-64]
	push eax
	call mat4_print
	sub dword[esp], 64
	call mat4_print
	add esp, 4
	
	;transpose test
	push transpose_message
	call printf
	add esp, 4
	
	lea eax, [ebp-128]
	push eax
	call mat4_transpose
	call mat4_print
	add esp, 4
	
	
	;multiply test
	push mul_message
	call printf
	add esp, 4
	
	lea eax, [ebp-128]
	push eax
	push eax
	push eax
	call mat4_mul
	add esp, 12
	
	lea eax, [ebp-64]
	push eax
	call mat4_print
	sub dword[esp], 64
	call mat4_print
	add esp, 4
	
	;scalarMul test
	push scalarMul_message
	call printf
	add esp, 4
	
	mov eax, dword[scalarMul_value]
	push eax
	lea eax, [ebp-128]
	push eax
	push eax
	call mat4_scalarMul
	call mat4_print
	add esp, 12
	
	;det test
	lea eax, [ebp-128]
	sub esp, 4
	push eax
	call mat4_det
	fstp qword[esp]
	push death_message
	call printf
	add esp, 12
	
	
	;inverse test
	push inverse_message
	call printf
	add esp, 4
	
	sub esp, 9	;to test movaps
	lea eax, [ebp-128]
	push eax
	push eax
	call mat4_inverse
	call mat4_print
	add esp, 8
	add esp, 9
	
	;scale test
	push scale_message
	call printf
	add esp, 4
	
	push scale_values
	lea eax, [ebp-128]
	push eax
	call mat4_scale
	call mat4_print
	add esp, 8
	
	
	;translation test
	push translate_message
	call printf
	add esp, 4
	
	push scale_values
	lea eax, [ebp-64]
	push eax
	call mat4_translate
	call mat4_print
	add esp, 8
	
	;rotation test
	push rotate_message
	call printf
	add esp, 4
	
	push dword[ rotational_angle ]
	push scale_values
	lea eax, [ebp-64]
	push eax
	call mat4_rotate
	call mat4_print
	add esp, 12
	
	;view test
	push view_message 
	call printf
	add esp, 4
	
	lea eax, [ebp-64]
	push worldUp_values
	push direction_values
	push position_values
	push eax
	call mat4_view
	call mat4_print
	add esp, 16
	
	;perspective test
	push perspective_message
	call printf
	add esp, 4
	
	lea eax, [ebp-64]
	
	push dword[far_clip]
	push dword[near_clip]
	push dword[aspectXY]
	push dword[fov]
	push eax
	call mat4_perspective
	call mat4_print
	add esp, 20
	
	;ortho test
	push ortho_message
	call printf
	add esp, 4
	
	lea eax, [ebp-64]
	push dword[ortho_far]
	push dword[ortho_near]
	push dword[ortho_top]
	push dword[ortho_bottom]
	push dword[ortho_right]
	push dword[ortho_left]
	push eax
	call mat4_ortho
	call mat4_print
	add esp, 28
	
	;mulWithMat test
	push mulWithMat_message
	call printf
	add esp, 4
	
	sub esp, 16		;vector
	mov eax, scale_values
	mov ecx, esp
	push 16
	push eax
	push ecx
	call memcpy
	add esp, 12
	
	lea eax, [ebp-128]
	push eax
	call mat4_print
	lea ecx, [esp+4]
	push ecx
	call vec4_mulWithMat
	call vec4_print
	add esp, 24
	
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
