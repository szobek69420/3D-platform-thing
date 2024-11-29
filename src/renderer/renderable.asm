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
	ONE dd 1.0
	
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
	dd 0xFF0000FF, 0xFF0000FF
	dd 0xFF00FF00, 0xFF00FF00
	dd 0xFF0000FF, 0xFF0000FF

section .text
	extern printf
	extern memset
	extern memcpy

	extern vector_init
	extern vector_destroy
	extern vector_push_back
	
	extern mat4_init
	extern mat4_mul
	extern mat4_scale
	extern mat4_rotate
	extern mat4_translate
	extern vec4_mulWithMat
	
	
	global renderable_create		;void renderable_create(renderable* buffer, Vec3* vertices, int* indices, int* colours, int vertexCount, int faceCount)
	global renderable_createKuba		;void renderable_createKuba(renderable* buffer)
	
	global renderable_destroy		;void renderable_destroy(renderable* renderable)
	
	global renderable_render		;void renderable_render(renderable* renderable, ScreenInfo* display, mat4* pv)
	
	global renderable_modelMatrix		;void renderable_modelMatrix(renderable* renderable, mat4* buffer)
	
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
	pop eax
	add esp, 4
	
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
	mov dword[eax+72], 0
	mov dword[eax+76], 0
	mov dword[eax+80], 0
	
	
	
	mov esp, ebp
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret
	

renderable_createKuba:
	mov eax, dword[esp+4]
	
	push 36
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
	push dword[ONE]
	push 0
	push 0
	mov eax, esp
	push dword[esi+68]
	push esp
	push edi
	call mat4_rotate
	add esp, 24
	
	;rotate around y
	push 0
	push dword[ONE]
	push 0
	mov eax, esp
	push dword[esi+64]
	push esp
	push edi
	call mat4_rotate
	add esp, 24
	
	;rotate around x
	push 0
	push 0
	push dword[ONE]
	mov eax, esp
	push dword[esi+6]
	push esp
	push edi
	call mat4_rotate
	add esp, 24
	
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
