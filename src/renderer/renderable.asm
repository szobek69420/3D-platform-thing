;layout:
;struct renderable{
;	vector<Vec3> vertices;
;	vector<int> indices;
;	vector<int> colours;		//colour per face
;	Vec3 position;			;48
;	Vec3 rotation;			;60, rotation in degrees
;	Vec3 scale;			;72
;} //84 bytes

section .rodata
	HALF dd 0.5
	ONE dd 1.0
	F30 dd 30.0
	F40 dd 40.0
	X_AXIS dd 1.0, 0.0, 0.0
	Y_AXIS dd 0.0, 1.0, 0.0
	Z_AXIS dd 0.0, 0.0, 1.0
	print_int_format db "%d",10,0
	print_renderable_data_format db "vertex count: %d, face count %d",10,0
	print_space_format db " ",0
	print_float_no_linebreak_format db "%.2f ",0
	print_int_no_linebreak_format db "%d ",0
	print_int_hex_no_linebreak_format db "0x%x ",0
	print_vertices_label_format db "vertices: ",10,0
	print_indices_label_format db "indices: ",10,0
	print_colours_label_format db "colours: ",10,0
	
cube_vertices:
	dd -0.5, 0.5, 0.5
	dd -0.5, 0.5, -0.5
	dd 0.5, 0.5, -0.5
	dd 0.5, 0.5, 0.5
	dd -0.5, -0.5, 0.5
	dd -0.5, -0.5, -0.5
	dd 0.5, -0.5, -0.5
	dd 0.5, -0.5, 0.5
	
cube_indices:
	dd 0,1,2, 0,2,3
	dd 4,6,5, 4,7,6
	dd 0,3,4, 3,7,4
	dd 1,0,5, 0,4,5
	dd 2,1,6, 1,5,6
	dd 3,2,7, 2,6,7
	
cube_colours:
	dd 0xFFFF0000, 0xFFFF0000
	dd 0xFFFF0000, 0xFFFF0000
	dd 0xFF00FF00, 0xFF00FF00
	dd 0xFF00FFFF, 0xFF00FFFF
	dd 0xFF00FF00, 0xFF00FF00
	dd 0xFF00FFFF, 0xFF00FFFF

section .text
	extern printf
	extern memset
	extern memcpy
	extern malloc
	extern free

	extern vector_init
	extern vector_destroy
	extern vector_push_back
	
	extern mat4_init
	extern mat4_mul
	extern mat4_scale
	extern mat4_rotate
	extern mat4_translate
	extern mat4_print
	extern vec4_mulWithMat
	extern vec3_print
	
	extern renderer_renderTriangle
	
	
	global renderable_create		;void renderable_create(renderable* buffer, Vec3* vertices, int* indices, int* colours, int vertexCount, int faceCount)
	global renderable_createKuba		;void renderable_createKuba(renderable* buffer)
	
	global renderable_destroy		;void renderable_destroy(renderable* renderable)
	
	global renderable_render		;void renderable_render(renderable* renderable, ScreenInfo* display, mat4* pv)
	
	global renderable_modelMatrix		;void renderable_modelMatrix(renderable* renderable, mat4* buffer)
	global renderable_print			;void renderable_print(renderable* renderable)
	
	
renderable_create:
	push ebp
	push esi
	push edi
	push ebx
	mov ebp, esp
	
	mov eax, dword[ebp+20]			;buffer in eax
	
	;init vertices vector
	push 12
	push eax
	call vector_init
	pop eax
	add esp, 4
	
	;init indices vector
	add eax, 16
	push 4
	push eax
	call vector_init
	pop eax
	add esp, 4
	
	;init colours vector
	add eax, 16
	push 4
	push eax
	call vector_init
	add esp, 8
	
	;copy vertices
	mov eax, dword[ebp+20]		;pointer to the vertex vector in eax
	mov esi, dword[ebp+24]		;vertices in esi
	mov edi, dword[ebp+36]		;vertexCount in edi
	sub esp, 12			;place for the parameter
	push eax
	cmp edi, 0
	jle _create_copy_vertices_loop_end
_create_copy_vertices_loop_start:
	mov eax, dword[esi]
	mov dword[esp+4], eax
	mov eax, dword[esi+4]
	mov dword[esp+8], eax
	mov eax, dword[esi+8]
	mov dword[esp+12],eax
	call vector_push_back
	
	add esi, 12
	dec edi
	cmp edi, 0
	jg _create_copy_vertices_loop_start
_create_copy_vertices_loop_end:
	add esp, 16
	
	
	
	;copy indices
	mov eax, dword[ebp+20]
	add eax, 16			;pointer to the index vector in eax
	mov esi, dword[ebp+28]		;indices in esi
	mov edi, dword[ebp+40]
	imul edi, 3			;indexCount in edi
	sub esp, 4			;place for the parameter
	push eax
	cmp edi, 0
	jle _create_copy_indices_loop_end
_create_copy_indices_loop_start:
	mov eax, dword[esi]
	mov dword[esp+4], eax
	call vector_push_back
	
	add esi, 4
	dec edi
	cmp edi, 0
	jg _create_copy_indices_loop_start
_create_copy_indices_loop_end:
	add esp, 8
	
	
	
	;copy colours
	mov eax, dword[ebp+20]
	add eax, 32			;pointer to the colour vector in eax
	mov esi, dword[ebp+32]		;colours in esi
	mov edi, dword[ebp+40]		;colourCount in edi
	sub esp, 4			;place for the parameter
	push eax
	cmp edi, 0
	jle _create_copy_colours_loop_end
_create_copy_colours_loop_start:
	mov eax, dword[esi]
	mov dword[esp+4], eax
	call vector_push_back
	
	add esi, 4
	dec edi
	cmp edi, 0
	jg _create_copy_colours_loop_start
_create_copy_colours_loop_end:
	add esp, 8
	
	
	;set the other things
	mov eax, dword[ebp+20]
	mov dword[eax+48], 0
	mov dword[eax+52], 0
	mov dword[eax+56], 0
	
	mov dword[eax+60], 0
	mov dword[eax+64], 0
	mov dword[eax+68], 0
	
	mov ecx, dword[ONE]
	mov dword[eax+72], ecx
	mov dword[eax+76], ecx
	mov dword[eax+80], ecx
	
	
	
	mov esp, ebp
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret
	

renderable_createKuba:
	mov eax, dword[esp+4]
	
	push 12		;facecount!!!
	push 8
	push cube_colours
	push cube_indices
	push cube_vertices
	push eax
	call renderable_create
	add esp, 24
	
	ret
	
	
renderable_destroy:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	push eax
	call vector_destroy
	add dword[esp], 16
	call vector_destroy
	add dword[esp], 16
	call vector_destroy
	
	mov esp, ebp
	pop ebp
	ret
	
renderable_render:
	push ebp
	push esi
	push edi
	push ebx
	mov ebp, esp
	
	sub esp, 64		;mvp
	sub esp, 4		;temp vertex buffer
	
	
	;calculate mvp
	lea eax, [ebp-64]
	mov ecx, dword[ebp+20]	;renderable in ecx
	push eax
	push ecx
	call renderable_modelMatrix
	add esp, 8
	
	
	lea eax, [ebp-64]	;model matrix in eax
	mov ecx, dword[ebp+28]	;pv in ecx
	push eax
	push ecx
	push eax
	call mat4_mul
	add esp, 12
	
	;allocate the temporary vertexbuffer for the clip space vertices
	mov ebx, dword[ebp+20]		;renderable in ebx
	mov eax, dword[ebx]
	shl eax, 4			;the size of the vec4 buffer in eax
	push eax
	call malloc
	mov dword[ebp-68], eax
	add esp, 4
	
	;calculate clip space vertices
	mov ebx, dword[ebp+20]
	mov esi, dword[ebx+12]		;renderable's vertex data in esi
	mov edi, dword[ebp-68]		;temp vertex buffer in edi
	mov ebx, dword[ebx]		;vertexcount in ebx
_render_calculate_clip_loop_start:
	;copy
	mov eax, dword[esi]
	mov dword[edi], eax
	mov eax, dword[esi+4]
	mov dword[edi+4], eax
	mov eax, dword[esi+8]
	mov dword[edi+8], eax
	mov eax, dword[ONE]
	mov dword[edi+12], eax
	
	;multiply
	lea eax, [ebp-64]
	push eax
	push edi
	call vec4_mulWithMat
	add esp, 8
	
	;perspective division
	and dword[edi+12], 0x7FFFFFFF		;abs(w)
	movss xmm0, dword[ONE]
	divss xmm0, dword[edi+12]
	
	movss xmm1, dword[edi]
	mulss xmm1, xmm0
	movss dword[edi], xmm1
	
	movss xmm1, dword[edi+4]
	mulss xmm1, xmm0
	movss dword[edi+4], xmm1
	
	movss xmm1, dword[edi+8]
	mulss xmm1, xmm0
	movss dword[edi+8], xmm1
	
	add esi, 12
	add edi, 16
	dec ebx
	cmp ebx, 0
	jg _render_calculate_clip_loop_start
	
	
	;render
	mov ebx, dword[ebp+20]
	mov esi, dword[ebx+28]		;index buffer in esi
	mov edi, dword[ebx+44]		;colour buffer in edi
	mov ebx, dword[ebx+32]		;face count in ebx

	sub esp, 20			;space for the function params
	mov eax, dword[ebp+24]
	mov dword[esp], eax
_render_render_loop_start:
	mov eax, dword[ebp-68]		;temp vertex buffer in eax
	
	mov ecx, dword[esi]
	shl ecx, 4
	add ecx, eax
	mov dword[esp+8], ecx
	
	mov ecx, dword[esi+4]
	shl ecx, 4
	add ecx, eax
	mov dword[esp+12], ecx
	
	mov ecx, dword[esi+8]
	shl ecx, 4
	add ecx, eax
	mov dword[esp+16], ecx
	
	mov ecx, dword[edi]
	mov dword[esp+4], ecx
	
	call renderer_renderTriangle
	
	add esi, 12
	add edi, 4
	dec ebx
	cmp ebx, 0
	jg _render_render_loop_start
	add esp, 20
	
	;free temp vertex buffer
	mov eax, dword[ebp-68]
	push eax
	call free
	add esp, 4
	
	mov esp, ebp
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret


renderable_modelMatrix:
	push ebp
	push esi
	push edi
	mov ebp, esp
	
	mov esi, dword[ebp+16]		;renderable in esi
	mov edi, dword[ebp+20]		;buffer in edi
	
	;init
	push dword[ONE]
	push edi
	call mat4_init
	add esp, 8
	
	;translate
	lea eax, dword[esi+48]
	push eax
	push edi
	call mat4_translate
	add esp, 8
	
	;rotate around z
	push dword[esi+68]
	push Z_AXIS
	push edi
	call mat4_rotate
	add esp, 12
	
	;rotate around y
	push dword[esi+64]
	push Y_AXIS
	push edi
	call mat4_rotate
	add esp, 12
	
	;rotate around x
	push dword[esi+60]
	push X_AXIS
	push edi
	call mat4_rotate
	add esp, 12
	
	;scale
	push dword[ONE]
	push dword[esi+80]
	push dword[esi+76]
	push dword[esi+72]
	mov eax, esp
	push esp
	push edi
	call mat4_scale
	add esp, 24
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebp
	ret
	
	
renderable_print:
	push ebp
	push esi
	push edi
	mov ebp, esp
	
	;print overall data
	mov eax, dword[ebp+16]
	push dword[eax+32]
	push dword[eax]
	push print_renderable_data_format
	call printf
	add esp, 12
	
	;print vertices
	push print_vertices_label_format
	call printf
	add esp, 4
	mov eax, dword[ebp+16]
	mov esi, dword[eax+12]
	mov edi, dword[eax]
_print_vertices_loop_start:
	sub esp, 8
	push print_float_no_linebreak_format
	
	fld dword[esi]
	fstp qword[esp+4]
	call printf
	
	fld dword[esi+4]
	fstp qword[esp+4]
	call printf
	
	fld dword[esi+8]
	fstp qword[esp+4]
	call printf
	add esp, 12
	
	push print_space_format
	call printf
	add esp, 4
	
	add esi, 12
	dec edi
	cmp edi, 0
	jg _print_vertices_loop_start
	
	push 0
	push 10
	mov eax, esp
	push esp
	call printf
	add esp, 12
	
	;print indices
	push print_indices_label_format
	call printf
	add esp, 4
	mov eax, dword[ebp+16]
	mov esi, dword[eax+28]
	mov edi, dword[eax+16]
_print_indices_loop_start:
	push dword[esi]
	push print_int_no_linebreak_format
	call printf
	add esp, 8
	
	add esi, 4
	dec edi
	cmp edi, 0
	jg _print_indices_loop_start
	
	push 0
	push 10
	mov eax, esp
	push esp
	call printf
	add esp, 12
	
	
	;print colours
	push print_colours_label_format
	call printf
	add esp, 4
	mov eax, dword[ebp+16]
	mov esi, dword[eax+44]
	mov edi, dword[eax+32]
_print_colours_loop_start:
	push dword[esi]
	push print_int_hex_no_linebreak_format
	call printf
	add esp, 8
	
	add esi, 4
	dec edi
	cmp edi, 0
	jg _print_colours_loop_start
	
	push 0
	push 10
	mov eax, esp
	push esp
	call printf
	add esp, 12
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebp
	ret
