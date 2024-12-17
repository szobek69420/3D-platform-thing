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
	
	print_int_format db "%d",10,0
	
	CHOMK_WIDTH_FLOAT dd 16.0
	CHOMK_HEIGHT_FLOAT dd 50.0
	
	BLOCK_COLLIDER_BOUND_CALC_HELPER dd 0.5, 0.5, 0.5, 0.0
	
	ONE dd 1.0
	
	TREE_STRUCTURE:
	dd 54			;block count
	dd 0,1,0,BLOCK_CHERRY_LOG
	dd 0,2,0,BLOCK_CHERRY_LOG
	dd 0,3,0,BLOCK_CHERRY_LOG
	dd 0,4,0,BLOCK_CHERRY_LOG
	dd 0,5,0,BLOCK_CHERRY_LOG
	dd -1,4,-2,BLOCK_CHERRY_LEAVES
	dd 0,4,-2,BLOCK_CHERRY_LEAVES
	dd 1,4,-2,BLOCK_CHERRY_LEAVES
	dd -2,4,-1,BLOCK_CHERRY_LEAVES
	dd -1,4,-1,BLOCK_CHERRY_LEAVES
	dd 0,4,-1,BLOCK_CHERRY_LEAVES
	dd 1,4,-1,BLOCK_CHERRY_LEAVES
	dd 2,4,-1,BLOCK_CHERRY_LEAVES
	dd -2,4,0,BLOCK_CHERRY_LEAVES
	dd -1,4,0,BLOCK_CHERRY_LEAVES
	dd 1,4,0,BLOCK_CHERRY_LEAVES
	dd 2,4,0,BLOCK_CHERRY_LEAVES
	dd -2,4,1,BLOCK_CHERRY_LEAVES
	dd -1,4,1,BLOCK_CHERRY_LEAVES
	dd 0,4,1,BLOCK_CHERRY_LEAVES
	dd 1,4,1,BLOCK_CHERRY_LEAVES
	dd 2,4,1,BLOCK_CHERRY_LEAVES
	dd -1,4,2,BLOCK_CHERRY_LEAVES
	dd 0,4,2,BLOCK_CHERRY_LEAVES
	dd 1,4,2,BLOCK_CHERRY_LEAVES
	dd -1,5,-2,BLOCK_CHERRY_LEAVES
	dd 0,5,-2,BLOCK_CHERRY_LEAVES
	dd 1,5,-2,BLOCK_CHERRY_LEAVES
	dd -2,5,-1,BLOCK_CHERRY_LEAVES
	dd -1,5,-1,BLOCK_CHERRY_LEAVES
	dd 0,5,-1,BLOCK_CHERRY_LEAVES
	dd 1,5,-1,BLOCK_CHERRY_LEAVES
	dd 2,5,-1,BLOCK_CHERRY_LEAVES
	dd -2,5,0,BLOCK_CHERRY_LEAVES
	dd -1,5,0,BLOCK_CHERRY_LEAVES
	dd 1,5,0,BLOCK_CHERRY_LEAVES
	dd 2,5,0,BLOCK_CHERRY_LEAVES
	dd -2,5,1,BLOCK_CHERRY_LEAVES
	dd -1,5,1,BLOCK_CHERRY_LEAVES
	dd 0,5,1,BLOCK_CHERRY_LEAVES
	dd 1,5,1,BLOCK_CHERRY_LEAVES
	dd 2,5,1,BLOCK_CHERRY_LEAVES
	dd -1,5,2,BLOCK_CHERRY_LEAVES
	dd 0,5,2,BLOCK_CHERRY_LEAVES
	dd 1,5,2,BLOCK_CHERRY_LEAVES
	dd -1,6,-1,BLOCK_CHERRY_LEAVES
	dd 0,6,-1,BLOCK_CHERRY_LEAVES
	dd 1,6,-1,BLOCK_CHERRY_LEAVES
	dd -1,6,0,BLOCK_CHERRY_LEAVES
	dd 0,6,0,BLOCK_CHERRY_LEAVES
	dd 1,6,0,BLOCK_CHERRY_LEAVES
	dd -1,6,1,BLOCK_CHERRY_LEAVES
	dd 0,6,1,BLOCK_CHERRY_LEAVES
	dd 1,6,1,BLOCK_CHERRY_LEAVES


section .data
	chomkCount dd 0
	
section .text
	extern printf
	extern malloc
	extern free
	extern memset
	extern memcpy
	extern rand
	extern srand
	
	extern vector_init
	extern vector_push_back
	extern vector_destroy
	
	extern vec3_add
	extern vec3_print
	
	extern renderable_create
	extern renderable_destroy
	extern renderable_print
	extern renderable_renderWithFog
	
	extern collider_createCollider
	extern colliderGroup_createColliderGroup
	extern colliderGroup_destroyColliderGroup
	extern colliderGroup_addCollider
	extern colliderGroup_printInfo
	
	extern BLOCK_AIR
	extern BLOCK_DIRT
	extern BLOCK_GRASS
	extern BLOCK_STONE
	extern BLOCK_CHERRY_LOG
	extern BLOCK_CHERRY_LEAVES
	extern BLOCK_COLLIDER
	
	extern BLOCK_COLOUR_INDEX
	extern BLOCK_INDICES
	extern BLOCK_VERTICES_INDEX
	
	extern blocks_getTerrainHeight
	
	extern CHANGED_BLOCK_SIZE
	
	
	global chomk_printChomkCount			;void chomk_printChomkCount()
	
	global chomk_generateChomk			;chomk* chomk_generateChomk(int seed, int chomkX, int chomkZ, chomkManager* chomkManager)
	global chomk_destroyChomk			;void chomk_destroyChomk(chomk* chomk)
	
	global chomk_renderChomk			;void chomk_renderChomk(chomk* chomk, ScreenInfo* display, mat4* pv, camera* cum)
	
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
	sub esp, 4		;int chunk x pos
	sub esp, 4		;int chunk z pos
	sub esp, 16		;vector<collider*> colliders
	sub esp, 4		;isBlockVisible (helper)
	
	
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
	
	lea eax, [ebp-100]
	push 4
	push eax
	call vector_init
	add esp, 8
	
	;set chunk info
	mov eax, dword[ebp-4]
	mov ecx, dword[ebp+24]
	mov dword[eax], ecx
	mov ecx, dword[ebp+28]
	mov dword[eax+4], ecx
	
	;calculate chunk integer positions
	mov eax, dword[ebp+24]
	shl eax, 4
	mov dword[ebp-80], eax
	
	mov eax, dword[ebp+28]
	shl eax, 4
	mov dword[ebp-84], eax
	
	
	;generate terrain
	mov ebx, dword[ebp-4]
	mov ebx, dword[ebx+8]		;current block in ebx
	xor eax, eax
_generateChomk_terrain_generation_y_loop_start:
	xor ecx, ecx
	_generateChomk_terrain_generation_x_loop_start:
		xor edx, edx
		_generateChomk_terrain_generation_z_loop_start:
			push eax
			push ecx
			push edx
			
			add ecx, dword[ebp-80]
			add edx, dword[ebp-84]
			push edx
			push ecx
			call blocks_getTerrainHeight
			add esp, 8
			
			mov ecx, dword[esp+8]
		
			cmp ecx, eax
			je _generateChomk_terrain_grass
			jl _generateChomk_terrain_stone
			jmp _generateChomk_terrain_air
			_generateChomk_terrain_air:
				mov byte[ebx], BLOCK_AIR
				jmp _generateChomk_terrain_block_done
			_generateChomk_terrain_grass:
				mov byte[ebx], BLOCK_GRASS
				jmp _generateChomk_terrain_block_done
			_generateChomk_terrain_stone:
				mov byte[ebx], BLOCK_STONE
				jmp _generateChomk_terrain_block_done
			_generateChomk_terrain_block_done:
			
			pop edx
			pop ecx
			pop eax
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
	
	;add trees
	mov eax, dword[ebp-80]
	imul eax, dword[ebp-84]
	push eax
	call srand
	add esp, 4
	
	mov ebx, dword[ebp-4]
	mov ebx, dword[ebx+8]		;blocks in ebx
	xor esi, esi
	_generateChomk_tree_generation_x_loop_start:
		xor edi, edi
		_generateChomk_tree_generation_z_loop_start:
			call rand
			and eax, 0x0000FFFF
			cmp eax, 64800
			jl _generateChomk_tree_generation_z_loop_continue
			
			;check the x position
			mov eax, esi
			cmp eax, 4
			jl _generateChomk_tree_generation_z_loop_continue
			add eax, 4
			cmp eax, CHOMK_WIDTH_PLUS_TWO
			jg _generateChomk_tree_generation_z_loop_continue
				
			;check the z position
			mov eax, edi
			cmp eax, 4
			jl _generateChomk_tree_generation_z_loop_continue
			add eax, 4
			cmp eax, CHOMK_WIDTH_PLUS_TWO
			jg _generateChomk_tree_generation_z_loop_continue
		
		
		
			mov ecx, esi
			mov edx, edi
			add ecx, dword[ebp-80]
			add edx, dword[ebp-84]
			push edx
			push ecx
			call blocks_getTerrainHeight
			add esp, 8
			
			
			;check the y pos
			add eax, 9
			cmp eax, CHOMK_HEIGHT_PLUS_TWO
			jg _generateChomk_tree_generation_z_loop_continue
			
		
			sub eax, 9
			imul eax, CHOMK_BLOCKS_PER_LAYER
			mov ecx, esi
			imul ecx, CHOMK_WIDTH_PLUS_TWO
			add eax, ecx
			add eax, edi
			
			add eax, ebx
			push eax
			call add_tree
			add esp, 4
			
			_generateChomk_tree_generation_z_loop_continue:
			inc edi
			cmp edi, CHOMK_WIDTH_PLUS_TWO
			jl _generateChomk_tree_generation_z_loop_start
			
		inc esi
		cmp esi, CHOMK_WIDTH_PLUS_TWO
		jl _generateChomk_tree_generation_x_loop_start
	
	;set the changed blocks
	mov ebx, dword[ebp-4]
	mov ebx, dword[ebx+8]		;blocks in ebx
	mov edi, dword[ebp+32]
	mov esi, dword[edi+28]		;changed blocks in esi
	mov edi, dword[edi+16]		;changed block count in edi
	
	sub esp, 4			;blockZ in this chomk
	sub esp, 4			;blockX in this chomk
	
	cmp edi, 0
	je _generate_change_blocks_loop_end
	_generate_change_blocks_loop_start:
		;check if the changed block is in this or a neighbouring chomk
		mov eax, dword[esi]		;changedBlock.chomkX-chomkX in eax
		sub eax, dword[ebp+24]
		cmp eax, 1
		je _generate_change_block_check_chomk_z
		cmp eax, 0
		je _generate_change_block_check_chomk_z
		cmp eax, -1
		je _generate_change_block_check_chomk_z
		jmp _generate_change_block_loop_continue
		
		_generate_change_block_check_chomk_z:
		mov eax, dword[esi+4]		;changedBlock.chomkZ-chomkZ in eax
		sub eax, dword[ebp+28]
		cmp eax, 1
		je _generate_change_block_loop_calculate_index
		cmp eax, 0
		je _generate_change_block_loop_calculate_index
		cmp eax, -1
		je _generate_change_block_loop_calculate_index
		jmp _generate_change_block_loop_continue
		
		
		_generate_change_block_loop_calculate_index:
		;calculate block index in this chomk
		mov eax, dword[esi]
		imul eax, 16
		xor ecx, ecx
		mov cl, byte[esi+8]
		add eax, ecx
		mov ecx, dword[ebp+24]
		imul ecx, 16
		sub eax, ecx
		inc eax
		mov dword[esp], eax
		
		mov eax, dword[esi+4]
		imul eax, 16
		xor ecx, ecx
		mov cl, byte[esi+10]
		add eax, ecx
		mov ecx, dword[ebp+28]
		imul ecx, 16
		sub eax, ecx
		inc eax
		mov dword[esp+4], eax
		
		;check if the block is in this chomk or on the border of a neighbouring chomk
		mov eax, dword[esp]
		cmp eax, CHOMK_WIDTH_PLUS_TWO 
		jge _generate_change_block_loop_continue
		cmp eax, 0
		jl _generate_change_block_loop_continue
		
		mov eax, dword[esp+4]
		cmp eax, CHOMK_WIDTH_PLUS_TWO 
		jge _generate_change_block_loop_continue
		cmp eax, 0
		jl _generate_change_block_loop_continue
		
		;calculate block index in blocks
		xor ecx, ecx
		mov cl, byte[esi+9]
		inc ecx
		imul ecx, CHOMK_BLOCKS_PER_LAYER
		mov eax, ecx
		
		mov ecx, dword[esp]
		imul ecx, CHOMK_WIDTH_PLUS_TWO
		add eax, ecx
		
		mov ecx, dword[esp+4]
		add eax, ecx
		
		;change block
		mov dl, byte[esi+11]
		mov byte[ebx+eax], dl
		
		_generate_change_block_loop_continue:
		add esi, CHANGED_BLOCK_SIZE
		dec edi
		cmp edi, 0
		jg _generate_change_blocks_loop_start
	_generate_change_blocks_loop_end:
	add esp, 8
	
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
			mov dword[ebp-104], 0		;isBlockVisible == 0
		
			xor edx, edx
			mov dl, byte[ebx]
			cmp edx, BLOCK_AIR
			je _generateChomk_air
			
			;neg z
			xor edx, edx
			mov dl, byte[ebx-1]
			cmp edx, BLOCK_AIR
			jne _generateChomk_neg_z_not_visible
			
				lea eax, [ebp-52]
				push eax
				lea eax, [ebp-36]
				push eax
				lea eax, [ebp-20]
				push eax
				lea eax, [ebp-76]
				push eax
				push 0
				xor eax, eax
				mov al, byte[ebx]
				push eax
				call _generateChomk_helper
				add esp, 24
				
				mov dword[ebp-104], 69		;isBlockVisible == true
			_generateChomk_neg_z_not_visible:
			
			;neg x
			xor edx, edx
			mov dl, byte[ebx-CHOMK_WIDTH_PLUS_TWO]
			cmp edx, BLOCK_AIR
			jne _generateChomk_neg_x_not_visible
			
				lea eax, [ebp-52]
				push eax
				lea eax, [ebp-36]
				push eax
				lea eax, [ebp-20]
				push eax
				lea eax, [ebp-76]
				push eax
				push 1
				xor eax, eax
				mov al, byte[ebx]
				push eax
				call _generateChomk_helper
				add esp, 24
				
				mov dword[ebp-104], 69		;isBlockVisible == true
			_generateChomk_neg_x_not_visible:
			
			;pos z
			xor edx, edx
			mov dl, byte[ebx+1]
			cmp edx, BLOCK_AIR
			jne _generateChomk_pos_z_not_visible
			
				lea eax, [ebp-52]
				push eax
				lea eax, [ebp-36]
				push eax
				lea eax, [ebp-20]
				push eax
				lea eax, [ebp-76]
				push eax
				push 2
				xor eax, eax
				mov al, byte[ebx]
				push eax
				call _generateChomk_helper
				add esp, 24
				
				mov dword[ebp-104], 69		;isBlockVisible == true
			_generateChomk_pos_z_not_visible:
			
			;pos x
			xor edx, edx
			mov dl, byte[ebx+CHOMK_WIDTH_PLUS_TWO]
			cmp edx, BLOCK_AIR
			jne _generateChomk_pos_x_not_visible
			
				lea eax, [ebp-52]
				push eax
				lea eax, [ebp-36]
				push eax
				lea eax, [ebp-20]
				push eax
				lea eax, [ebp-76]
				push eax
				push 3
				xor eax, eax
				mov al, byte[ebx]
				push eax
				call _generateChomk_helper
				add esp, 24
				
				mov dword[ebp-104], 69		;isBlockVisible == true
			_generateChomk_pos_x_not_visible:
		
			;pos y
			xor edx, edx
			mov dl, byte[ebx+CHOMK_BLOCKS_PER_LAYER]
			cmp edx, BLOCK_AIR
			jne _generateChomk_pos_y_not_visible
			
				lea eax, [ebp-52]
				push eax
				lea eax, [ebp-36]
				push eax
				lea eax, [ebp-20]
				push eax
				lea eax, [ebp-76]
				push eax
				push 4
				xor eax, eax
				mov al, byte[ebx]
				push eax
				call _generateChomk_helper
				add esp, 24
				
				mov dword[ebp-104], 69		;isBlockVisible == true
			_generateChomk_pos_y_not_visible:
			
			;neg y
			xor edx, edx
			mov dl, byte[ebx-CHOMK_BLOCKS_PER_LAYER]
			cmp edx, BLOCK_AIR
			jne _generateChomk_neg_y_not_visible
			
				lea eax, [ebp-52]
				push eax
				lea eax, [ebp-36]
				push eax
				lea eax, [ebp-20]
				push eax
				lea eax, [ebp-76]
				push eax
				push 5
				xor eax, eax
				mov al, byte[ebx]
				push eax
				call _generateChomk_helper
				add esp, 24
				
				mov dword[ebp-104], 69		;isBlockVisible == true
			_generateChomk_neg_y_not_visible:
			
			mov edx, dword[ebp-104]
			cmp edx, 0
			je _generateChomk_no_collider
				sub esp, 32		;place for two vec4s (because of sse)
				movups xmm1, [BLOCK_COLLIDER_BOUND_CALC_HELPER]
				
				;calc lower bound
				movups xmm0, [ebp-76]
				subps xmm0, xmm1
				movups [esp], xmm0
				
				;calc upper bound
				movups xmm0, [ebp-76]
				addps xmm0, xmm1
				movups [esp+16], xmm0
				
				lea eax, [esp+16]
				mov edx, esp
				push eax
				push edx
				call collider_createCollider
				add esp, 40
				
				mov dword[eax+52], BLOCK_COLLIDER
				
				lea edx, [ebp-100]
				push eax
				push edx
				call vector_push_back
				add esp, 8
				
			_generateChomk_no_collider:
			
			_generateChomk_air:
			movss xmm0, dword[ONE]
			movss xmm1, dword[ebp-68]
			addss xmm1, xmm0
			movss dword[ebp-68], xmm1
		
			inc ebx
			inc edi
			cmp edi, CHOMK_WIDTH
			jle _generateChomk_mesh_z_loop_start
		
		pop edi				;restore x loop index
		inc ebx
		
		movss xmm0, dword[ONE]
		movss xmm1, dword[ebp-76]
		addss xmm1, xmm0
		movss dword[ebp-76], xmm1
		
		
		inc edi
		cmp edi, CHOMK_WIDTH
		jle _generateChomk_mesh_x_loop_start
	
	
	pop edi				;restore y loop index
	add ebx, CHOMK_WIDTH_PLUS_TWO
	
	movss xmm0, dword[ONE]
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
	add esp, 24

	;make collider group and fill it up
	call colliderGroup_createColliderGroup
	mov edx, dword[ebp-4]
	mov dword[edx+16], eax
	mov ebx, eax			;cg in ebx
	mov esi, dword[ebp-100]		;index in esi
	mov edi, dword[ebp-88]		;colliders in edi
	cmp esi, 0
	je _generateChomk_cg_loop_end
	_generateChomk_cg_loop_start:
		push dword[edi]
		push ebx
		call colliderGroup_addCollider
		add esp, 8
		
		add edi, 4
		dec esi
		cmp esi, 0
		jg _generateChomk_cg_loop_start
	_generateChomk_cg_loop_end:
	
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
	
	lea eax, [ebp-100]
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
	

;adds a side of the block
_generateChomk_helper:		;void _generatechomk_helper(int block, int side, vec3* blockPos, vector<vec3>* vertices, vector<int>* indices, vector<int>* colours)
	push ebp
	mov ebp, esp	
	
	sub esp, 4		;vertex data location
	sub esp, 4		;colour
	sub esp, 4		;current vertex count
	
	;retrieving vertex data
	mov eax, dword[ebp+12]
	mov ecx, dword[4*eax+BLOCK_VERTICES_INDEX]
	mov dword[ebp-4], ecx
	
	;getting colour
	mov ecx, dword[ebp+8]
	mov edx, dword[4*ecx+BLOCK_COLOUR_INDEX]
	mov edx, dword[edx+4*eax]
	mov dword[ebp-8], edx
	
	;getting vertex count
	mov eax, dword[ebp+20]
	mov eax, dword[eax]
	mov dword[ebp-12], eax
	
	
	;add vertices
	sub esp, 12		;alloc space for temp vector
			
	mov edx, esp
	push dword[ebp-4]	;vertex data location
	push dword[ebp+16]	;block position
	push edx
	call vec3_add
	add esp, 12
	push dword[ebp+20]
	call vector_push_back
	add esp, 4
	
	mov eax, dword[ebp-4]	;vertex data location in eax
	add eax, 12
	mov edx, esp
	push eax
	push dword[ebp+16]	;block position
	push edx
	call vec3_add
	add esp, 12
	push dword[ebp+20]
	call vector_push_back
	add esp, 4
	
	mov eax, dword[ebp-4]	;vertex data location in eax
	add eax, 24
	mov edx, esp
	push eax
	push dword[ebp+16]	;block position
	push edx
	call vec3_add
	add esp, 12
	push dword[ebp+20]
	call vector_push_back
	add esp, 4
	
	mov eax, dword[ebp-4]	;vertex data location in eax
	add eax, 36
	mov edx, esp
	push eax
	push dword[ebp+16]	;block position
	push edx
	call vec3_add
	add esp, 12
	push dword[ebp+20]
	call vector_push_back
	add esp, 4
	
	add esp, 12
			
			
	;add indices
	mov eax, dword[BLOCK_INDICES]
	add eax, dword[ebp-12]
	push eax
	push dword[ebp+24]
	call vector_push_back
	
	mov eax, BLOCK_INDICES
	mov eax, dword[eax+4]
	add eax, dword[ebp-12]
	mov dword[esp+4], eax
	call vector_push_back
			
	mov eax, BLOCK_INDICES
	mov eax, dword[eax+8]
	add eax, dword[ebp-12]
	mov dword[esp+4], eax
	call vector_push_back
			
	mov eax, BLOCK_INDICES
	mov eax, dword[eax+12]
	add eax, dword[ebp-12]
	mov dword[esp+4], eax
	call vector_push_back
			
	mov eax, BLOCK_INDICES
	mov eax, dword[eax+16]
	add eax, dword[ebp-12]
	mov dword[esp+4], eax
	call vector_push_back
			
	mov eax, BLOCK_INDICES
	mov eax, dword[eax+20]
	add eax, dword[ebp-12]
	mov dword[esp+4], eax
	call vector_push_back
	add esp, 8
	
			
	;add colour
	push dword[ebp-8]
	push dword[ebp+28]
	call vector_push_back
	call vector_push_back
	add esp, 8

	
	mov esp, ebp
	pop ebp
	ret
	
add_tree:			;void add_tree(char* treeBaseBlockInBlocks)
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	
	mov esi, dword[ebp+20]
	mov edi, TREE_STRUCTURE
	add edi, 4
	mov ebx, dword[TREE_STRUCTURE]
	_add_tree_loop_start:
		mov eax, dword[edi+4]
		imul eax, CHOMK_BLOCKS_PER_LAYER
		mov ecx, dword[edi]
		imul ecx, CHOMK_WIDTH_PLUS_TWO
		add eax, ecx
		add eax, dword[edi+8]
		
		mov cl, byte[edi+12]
		mov byte[esi+eax], cl
		
		add edi, 16
		dec ebx
		cmp ebx, 0
		jg _add_tree_loop_start
		
	
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
	
	;destroy renderable
	mov eax, dword[ebp+8]
	push dword[eax+12]
	call renderable_destroy
	call free
	add esp, 4
	
	;destroy collider group
	mov eax, dword[ebp+8]
	push 69
	push dword[eax+16]
	call colliderGroup_destroyColliderGroup
	add esp, 8
	
	push dword[ebp+8]
	call free
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret
	
	
	
chomk_renderChomk:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;chomk in eax
	
	push dword[ebp+20]
	push dword[ebp+16]
	push dword[ebp+12]
	push dword[eax+12]
	call renderable_renderWithFog
	
	mov esp, ebp
	pop ebp
	ret
