;layout
;struct chomk{
;	int chomkX, chomkZ;			;0
;	char* blocks; //y,x,z			;8
;	renderable* mesh;			;12
;	colliderGroup* cg;			;16
;} //20 bytes

CHOMK_WIDTH equ 16
CHOMK_HEIGHT equ 50
CHOMK_WIDTH_PLUS_TWO equ 18
CHOMK_HEIGHT_PLUS_TWO equ 52
CHOMK_BLOCKS_PER_LAYER equ 324		;18*18 = CHOMK_WIDTH_PLUS_TWO*CHOMK_WIDTH_PLUS_TWO

section .rodata
	print_chomk_count db "Active chomk count: %d",10,0
	print_chomk_generation_error db "Couldn't create chomk x=%d z=%d lol",10,0
	
	print_chomk_info db "Vertex count: %d, index count: %d, face count: %d",10,0
	
	CHOMK_WIDTH_FLOAT dd 16.0
	CHOMK_HEIGHT_FLOAT dd 50.0
	
	ONE dd 1.0

section .data
	chomkCount dd 0
	
section .text
	extern printf
	extern malloc
	extern free
	extern memset
	extern memcpy
	
	extern vector_init
	extern vector_push_back
	extern vector_destroy
	
	extern vec3_add
	
	extern renderable_create
	extern renderable_destroy
	extern renderable_print
	
	extern BLOCK_AIR
	extern BLOCK_DIRT
	
	extern BLOCK_INDICES
	extern BLOCK_VERTICES_POS_Y
	
	
	global chomk_printChomkCount			;void chomk_printChomkCount()
	
	global chomk_generateChomk			;chomk* chomk_generateChomk(int seed, int chomkX, int chomkZ)
	global chomk_destroyChomk			;void chomk_destroyChomk(chomk* chomk)
	
chomk_printChomkCount:
	push dword[chomkCount]
	push print_chomk_count
	call printf
	add esp, 8
	ret
	
	

chomk_generateChomk:
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	sub esp, 4		;chomk*
	sub esp, 16		;vector<vec3> vertices
	sub esp, 16		;vector<int> indices
	sub esp, 16		;vector<int> colours
	sub esp, 12		;chomk base position
	sub esp, 12		;current position for the mesh generation
	
	
	;alloc chomk
	push 20
	call malloc
	add esp, 4
	mov dword[ebp-4], eax	;save chomk
	cmp eax, 0
	jne _generateChomk_chomk_malloc_no_error
	
	push dword[ebp+28]
	push dword[ebp+24]
	push print_chomk_generation_error
	call printf
	add esp, 12
	xor eax, eax
	jmp _generateChomk_done
	
_generateChomk_chomk_malloc_no_error:
	
	;alloc chomk renderable
	push 84
	call malloc
	add esp, 4
	mov ecx, dword[ebp-4]
	mov dword[ecx+12],eax	;save renderable
	
	cmp eax, 0
	jne _generateChomk_chomk_renderable_malloc_no_error
	
	push dword[ebp-4]
	call free
	add esp, 4
	
	push dword[ebp+28]
	push dword[ebp+24]
	push print_chomk_generation_error
	call printf
	add esp, 12
	xor eax, eax
	jmp _generateChomk_done
	
_generateChomk_chomk_renderable_malloc_no_error:

	;alloc chomk blocks
	mov eax, CHOMK_WIDTH_PLUS_TWO
	imul eax, CHOMK_WIDTH_PLUS_TWO
	imul eax, CHOMK_HEIGHT_PLUS_TWO
	
	push eax
	call malloc
	add esp, 4
	mov ecx, dword[ebp-4]
	mov dword[ecx+8], eax
	
	cmp eax, 0
	jne _generateChomk_chomk_blocks_malloc_no_error
	
	mov eax, dword[ebp-4]
	push dword[eax+12]
	call free
	add esp, 4
	
	push dword[ebp-4]
	call free
	add esp, 4
	
	push dword[ebp+28]
	push dword[ebp+24]
	push print_chomk_generation_error
	call printf
	add esp, 12
	xor eax, eax
	jmp _generateChomk_done
	
_generateChomk_chomk_blocks_malloc_no_error:

	;init temp vectors
	lea eax, [ebp-20]
	push 12
	push eax
	call vector_init
	add esp, 8
	
	lea eax, [ebp-36]
	push 4
	push eax
	call vector_init
	add esp, 8
	
	lea eax, [ebp-52]
	push 4
	push eax
	call vector_init
	add esp, 8
	
	
	
	;generate terrain
	mov ebx, dword[ebp-4]
	mov ebx, dword[ebx+8]		;current block in ebx
	xor eax, eax
_generateChomk_terrain_generation_y_loop_start:
	xor ecx, ecx
_generateChomk_terrain_generation_x_loop_start:
	xor edx, edx
_generateChomk_terrain_generation_z_loop_start:
	cmp edx, eax
	jle _generateChomk_terrain_dirt
	jmp _generateChomk_terrain_air
	_generateChomk_terrain_air:
		mov dword[ebx], BLOCK_AIR
		jmp _generateChomk_terrain_block_done
	_generateChomk_terrain_dirt:
		mov dword[ebx], BLOCK_DIRT
		jmp _generateChomk_terrain_block_done
	_generateChomk_terrain_block_done:
	
	inc ebx
	inc edx
	cmp edx, CHOMK_WIDTH_PLUS_TWO
	jl _generateChomk_terrain_generation_z_loop_start
	
	inc ecx
	cmp ecx, CHOMK_WIDTH_PLUS_TWO
	jl _generateChomk_terrain_generation_x_loop_start
	
	inc eax
	cmp eax, CHOMK_HEIGHT_PLUS_TWO
	jl _generateChomk_terrain_generation_y_loop_start
	
	
	
	;calculate chomk base position
	lea eax, [ebp-64]
	fild dword[ebp+24]
	fld dword[CHOMK_WIDTH_FLOAT]
	fmulp
	fstp dword[eax]
	
	mov dword[eax+4], 0
	
	fild dword[ebp+28]
	fld dword[CHOMK_WIDTH_FLOAT]
	fmulp
	fstp dword[eax+8]
	
	;copy the base position into the current position vector
	lea ecx, [ebp-76]
	mov edx, dword[eax]
	mov dword[ecx], edx
	mov edx, dword[eax+4]
	mov dword[ecx+4], edx
	mov edx, dword[eax+8]
	mov dword[ecx+8], ecx
	
	
	;construct visible mesh
	mov ebx, dword[ebp-4]
	mov ebx, dword[ebx+8]
	add ebx, CHOMK_BLOCKS_PER_LAYER	;current block in ebx
	xor esi, esi			;current vertex count
	mov edi, 1			;index variable
	movss xmm0, dword[ONE]		;one in xmm0
_generateChomk_mesh_y_loop_start:
	
	mov edx, dword[ebp-64]
	mov dword[ebp-76], edx		;x is reset
	add ebx, CHOMK_WIDTH_PLUS_TWO
	
	push edi			;save y loop index
	mov edi, 1
	
	_generateChomk_mesh_x_loop_start:
		
		mov edx, dword[ebp-56]
		mov dword[ebp-68], edx		;z is reset
		inc ebx
		
		push edi			;save x loop index
		mov edi, 1
		
		_generateChomk_mesh_z_loop_start:
		
			;pos y
			mov edx, dword[ebx+CHOMK_BLOCKS_PER_LAYER]
			cmp edx, BLOCK_AIR
			jne _generateChomk_pos_y_not_visible
			
			;add vertices
			sub esp, 12		;alloc space for temp vector
			
			mov eax, BLOCK_VERTICES_POS_Y
			lea ecx, [ebp-76]
			mov edx, esp
			push eax
			push ecx
			push edx
			call vec3_add
			add esp, 12
			lea eax, [ebp-20]
			push eax
			call vector_push_back
			add esp, 4
			
			mov eax, BLOCK_VERTICES_POS_Y
			add eax, 12
			lea ecx, [ebp-76]
			mov edx, esp
			push eax
			push ecx
			push edx
			call vec3_add
			add esp, 12
			lea eax, [ebp-20]
			push eax
			call vector_push_back
			add esp, 4
			
			mov eax, BLOCK_VERTICES_POS_Y
			add eax, 24
			lea ecx, [ebp-76]
			mov edx, esp
			push eax
			push ecx
			push edx
			call vec3_add
			add esp, 12
			lea eax, [ebp-20]
			push eax
			call vector_push_back
			add esp, 4
			
			mov eax, BLOCK_VERTICES_POS_Y
			add eax, 36
			lea ecx, [ebp-76]
			mov edx, esp
			push eax
			push ecx
			push edx
			call vec3_add
			add esp, 12
			lea eax, [ebp-20]
			push eax
			call vector_push_back
			add esp, 4
			
			add esp, 12
			
			
			;add indices
			mov eax, dword[BLOCK_INDICES]
			add eax, esi
			push eax
			lea eax, [ebp-36]
			push eax
			call vector_push_back
			
			mov eax, BLOCK_INDICES
			add eax, 4
			mov eax, dword[eax]
			add eax, esi
			mov dword[esp+4], eax
			call vector_push_back
			
			mov eax, BLOCK_INDICES
			add eax, 8
			mov eax, dword[eax]
			add eax, esi
			mov dword[esp+4], eax
			call vector_push_back
			
			mov eax, BLOCK_INDICES
			add eax, 12
			mov eax, dword[eax]
			add eax, esi
			mov dword[esp+4], eax
			call vector_push_back
			
			mov eax, BLOCK_INDICES
			add eax, 16
			mov eax, dword[eax]
			add eax, esi
			mov dword[esp+4], eax
			call vector_push_back
			
			mov eax, BLOCK_INDICES
			add eax, 20
			mov eax, dword[eax]
			add eax, esi
			mov dword[esp+4], eax
			call vector_push_back
			add esp, 8
			
			
			;add colour
			push 0xFFFF0000
			lea eax, [ebp-52]
			push eax
			call vector_push_back
			add esp, 8
			
			
			add esi, 4
			
			_generateChomk_pos_y_not_visible:
		
		
			movss xmm1, dword[ebp-68]
			addss xmm1, xmm0
			movss dword[ebp-68], xmm1
		
			inc ebx
			inc edi
			cmp edi, CHOMK_WIDTH
			jle _generateChomk_mesh_z_loop_start
		
		pop edi				;restore x loop index
		inc ebx
		
		movss xmm1, dword[ebp-76]
		addss xmm1, xmm0
		movss dword[ebp-76], xmm1
		
		inc edi
		cmp edi, CHOMK_WIDTH
		jle _generateChomk_mesh_x_loop_start
	
	
	pop edi				;restore y loop index
	add ebx, CHOMK_WIDTH_PLUS_TWO
	
	movss xmm1, dword[ebp-72]
	addss xmm1, xmm0
	movss dword[ebp-72], xmm1
	
	inc edi
	cmp edi, CHOMK_HEIGHT
	jle _generateChomk_mesh_y_loop_start
	
	
	
	;load renderable
	mov eax, dword[ebp-4]
	mov eax, dword[eax+12]
	
	push dword[ebp-52]		;face count
	push dword[ebp-20]		;vertex count
	push dword[ebp-40]		;colours
	push dword[ebp-24]		;indices
	push dword[ebp-8]		;vertices
	push eax
	call renderable_create
	call renderable_print
	add esp, 24
	
	;free resources
	lea eax, [ebp-20]
	push eax
	call vector_destroy
	add esp, 4
	
	lea eax, [ebp-36]
	push eax
	call vector_destroy
	add esp, 4
	
	lea eax, [ebp-52]
	push eax
	call vector_destroy
	add esp, 4
	
	
	;set return value
	mov eax, dword[ebp-4]
	
_generateChomk_done:
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
	
	
	
chomk_destroyChomk:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	push dword[eax+8]
	call free
	add esp, 4
	
	mov eax, dword[ebp+8]
	push dword[eax+12]
	call renderable_destroy
	call free
	add esp, 4
	
	push dword[ebp+8]
	call free
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret
