;layout
;struct chomkManager{
;	vector<chomk*> loadedChomks			;0
;	vector<blockData> changedBlocks			;16
;	vector<chomkUpdate> pendingUpdates		;32
;	int renderDistance				;48
;	int seed					;52
;} 56 bytes

section .rodata
	print_creation_error_message db "Chomk manager wasn't successful in fanum taxing memory", 10,0
	print_player_chomk db "Player is at %d,%d; which is in the chomk %d,%d",10,0
	print_loaded_chomk_count db "Loaded chomks: %d",10,0
	print_chomk_added_message db "Chomk (%d, %d) added, new count: %d, old count: %d",10,0
	print_chomk_removed_message db "Chomk (%d, %d) removed, new count: %d, old count: %d",10,0
	print_two_ints db "%d %d",10,0
	print_three_ints db "%d %d %d",10,0

section .text
	extern printf
	extern malloc
	extern free
	
	extern vector_init
	extern vector_push_back
	extern vector_remove
	extern vector_remove_at
	extern vector_destroy

	extern chomk_renderChomk
	extern chomk_generateChomk
	extern chomk_destroyChomk
	
	extern physics_registerColliderGroup
	extern physics_removeColliderGroup
	
	global chomkManager_create		;chomkManager* chomkManager_create(int renderDistance, int seed)
	global chomkManager_destroy		;void chomkManager_destroy(chomkManager* cm)
	
	global chomkManager_render		;void chomkManager_render(chomkManager* cm, ScreenInfo* window, mat4* pv, camera* cum)
	
	global chomkManager_addChomk		;void chomkManager_addChomk(chomkManager* cm, int chunkX, int chunkZ)
	global chomkManager_removeChomk 	;void chomkManager_removeChomk(chomkManager* cm, chomk* cm)
	
	global chomkManager_isChomkLoaded	;int chomkManager_isChomkLoaded(chomkManager* cm, int chunkX, int chunkZ)
	global chomkManager_generate		;void chomkManager_generate(chomkManager* cm, int playerPosX, int playerPosZ)
	
	global chomkManager_printLoadedChomks	;void chomkManager_printLoadedChomks(chomkManager* cm)
	
chomkManager_create:
	push ebp
	mov ebp, esp
	
	sub esp, 4		;chomkmanager
	
	;alloc memory
	push 56
	call malloc
	mov dword[ebp-4], eax
	add esp, 4
	
	cmp eax, 0
	jne _create_alloc_no_error
	
	push print_creation_error_message
	call printf
	add esp, 4
	
	xor eax, eax
	
	_create_alloc_no_error:
	
	;init vectors
	mov eax, dword[ebp-4]
	push 4
	push eax
	call vector_init
	add esp, 8
	
	;TODO: changed blocks and pending updates vectors
	
	;set render distance and seed
	mov eax, dword[ebp-4]
	mov ecx, dword[ebp+8]
	mov dword[eax+48], ecx
	mov ecx, dword[ebp+12]
	mov dword[eax+52], ecx
	
	
	mov eax, dword[ebp-4]
	
	_create_done:
	mov esp, ebp
	pop ebp
	ret
	
chomkManager_destroy:
	push ebp
	push esi
	push edi
	mov ebp, esp
	
	;destroy chomks
	mov esi, dword[ebp+16]
	mov edi, dword[esi]
	mov esi, dword[esi+12]
	cmp edi, 0
	je _destroy_chomk_destroy_loop_done
	_destroy_chomk_destroy_loop_start:
		push dword[esi+4*edi-4]
		push dword[ebp+16]
		call chomkManager_removeChomk
		add esp, 8
		
		dec edi
		cmp edi, 0
		jg _destroy_chomk_destroy_loop_start
	
	_destroy_chomk_destroy_loop_done:
	
	;destroy vectors
	mov esi, dword[ebp+16]
	push esi
	call vector_destroy
	add esp, 4
	
	;TODO: destroy the changed blocks and pending updates vector
	
	;free the chomk manager
	push dword[ebp+16]
	call free
	add esp, 4
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebp
	ret
	
chomkManager_render:
	push ebp
	push esi
	push edi
	mov ebp, esp
	
	mov esi, dword[ebp+16]
	mov edi, dword[esi]		;index
	mov esi, dword[esi+12]		;chomks
	cmp edi, 0
	je _render_done
_render_loop_start:
	push dword[ebp+28]
	push dword[ebp+24]
	push dword[ebp+20]
	push dword[esi+4*edi-4]
	call chomk_renderChomk
	add esp, 16
	
	dec edi
	cmp edi, 0
	jg _render_loop_start
	
	_render_done:
	mov esp, ebp
	pop edi
	pop esi
	pop ebp
	ret
	
	
chomkManager_addChomk:
	push ebp
	mov ebp, esp
		
	sub esp, 4			;chomk
		
	mov eax, dword[ebp+8]		;cm in eax
	
	push dword[ebp+16]
	push dword[ebp+12]
	push dword[eax+52]		;seed
	call chomk_generateChomk
	mov dword[ebp-4], eax
	add esp, 12
	cmp eax, 0
	jne _addChomk_no_error
	jmp _addChomk_done	
	_addChomk_no_error:
	
	mov ecx, dword[ebp+8]		;cm in ecx
	
	push eax
	push ecx
	call vector_push_back
	add esp, 8
	
	
	;add chomk colliders to physics
	mov eax, dword[ebp-4]
	push dword[eax+16]
	call physics_registerColliderGroup
	add esp, 4
	
	_addChomk_done:
	mov esp, ebp
	pop ebp
	ret
	
	
chomkManager_removeChomk:
	push ebp
	mov ebp, esp
	
	;remove chomk colliders from physics
	mov eax, dword[ebp+12]
	push dword[eax+16]
	call physics_removeColliderGroup
	add esp, 4
	
	;free chomk
	push dword[ebp+12]
	call chomk_destroyChomk
	add esp, 4
	
	;remove from loaded chomks
	push dword[ebp+12]
	push dword[ebp+8]
	call vector_remove
	add esp, 8
	
	mov esp, ebp
	pop ebp
	ret
	
	
chomkManager_isChomkLoaded:
	push ebp
	push ebx
	mov ebp, esp
	
	mov eax, dword[ebp+12]		;cm in eax
	mov ecx, dword[eax]		;index
	mov eax, dword[eax+12]		;chomks
	cmp ecx, 0
	je _isChomkLoaded_loop_done
	_isChomkLoaded_loop_start:
		mov edx, dword[eax+4*ecx-4]
		
		mov ebx, dword[ebp+16]
		cmp ebx, dword[edx]
		jne _isChomkLoaded_continue
		mov ebx, dword[ebp+20]
		cmp ebx, dword[edx+4]
		jne _isChomkLoaded_continue
		
		mov eax, 69
		jmp _isChomkLoaded_done
		
		_isChomkLoaded_continue:
		dec ecx
		cmp ecx, 0
		jg _isChomkLoaded_loop_start
		
	_isChomkLoaded_loop_done:
	
	xor eax, eax
	
	_isChomkLoaded_done:
	mov esp, ebp
	pop ebx
	pop ebp
	ret
	
	
chomkManager_generate:
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	sub esp, 4		;playerChomkX
	sub esp, 4		;playerChomkZ
	
	;calculate player chomk pos
	mov eax, dword[ebp+24]
	sar eax, 4
	mov dword[ebp-4], eax
	
	mov eax, dword[ebp+28]
	sar eax, 4
	mov dword[ebp-8], eax
	
	
	;search for loadable chunks
	mov ebx, dword[ebp+20]	;cm in ebx
	xor esi, esi		;search ring radius
	_generate_load_radius_loop_start:
		;neg z
		xor eax, eax
		sub eax, esi
		xor ecx, ecx
		sub ecx, esi
		_generate_load_neg_z_loop_start:
			push eax		;save eax
			push ecx		;save ecx
			mov edx, dword[ebp-8]
			add edx, ecx
			push edx
			mov edx, dword[ebp-4]
			add edx, eax
			push edx
			push ebx
			call chomkManager_isChomkLoaded
			cmp eax, 0
			jne _generate_load_neg_z_loaded
				call chomkManager_addChomk
				call chomkManager_printLoadedChomks
				add esp, 20
				jmp _generate_load_radius_loop_done
			_generate_load_neg_z_loaded:
			add esp, 12
			pop ecx			;restore ecx
			pop eax			;restore eax
			
			inc eax
			cmp eax, esi
			jle _generate_load_neg_z_loop_start
			
		;neg x
		xor eax, eax
		sub eax, esi
		xor ecx, ecx
		sub ecx, esi
		_generate_load_neg_x_loop_start:
			push eax		;save eax
			push ecx		;save ecx
			mov edx, dword[ebp-8]
			add edx, ecx
			push edx
			mov edx, dword[ebp-4]
			add edx, eax
			push edx
			push ebx
			call chomkManager_isChomkLoaded
			cmp eax, 0
			jne _generate_load_neg_x_loaded
				call chomkManager_addChomk
				call chomkManager_printLoadedChomks
				add esp, 20
				jmp _generate_load_radius_loop_done
			_generate_load_neg_x_loaded:
			add esp, 12
			pop ecx			;restore ecx
			pop eax			;restore eax
			
			inc ecx
			cmp ecx, esi
			jle _generate_load_neg_x_loop_start
			
		;pos z
		xor eax, eax
		sub eax, esi
		mov ecx, esi
		_generate_load_pos_z_loop_start:
			push eax		;save eax
			push ecx		;save ecx
			mov edx, dword[ebp-8]
			add edx, ecx
			push edx
			mov edx, dword[ebp-4]
			add edx, eax
			push edx
			push ebx
			call chomkManager_isChomkLoaded
			cmp eax, 0
			jne _generate_load_pos_z_loaded
				call chomkManager_addChomk
				call chomkManager_printLoadedChomks
				add esp, 20
				jmp _generate_load_radius_loop_done
			_generate_load_pos_z_loaded:
			add esp, 12
			pop ecx			;restore ecx
			pop eax			;restore eax
			
			inc eax
			cmp eax, esi
			jle _generate_load_pos_z_loop_start
			
		;pos x
		mov eax, esi
		xor ecx, ecx
		sub ecx, esi
		_generate_load_pos_x_loop_start:
			push eax		;save eax
			push ecx		;save ecx
			mov edx, dword[ebp-8]
			add edx, ecx
			push edx
			mov edx, dword[ebp-4]
			add edx, eax
			push edx
			push ebx
			call chomkManager_isChomkLoaded
			cmp eax, 0
			jne _generate_load_pos_x_loaded
				call chomkManager_addChomk
				call chomkManager_printLoadedChomks
				add esp, 20
				jmp _generate_load_radius_loop_done
			_generate_load_pos_x_loaded:
			add esp, 12
			pop ecx			;restore ecx
			pop eax			;restore eax
			
			inc ecx
			cmp ecx, esi
			jle _generate_load_pos_x_loop_start
			
		inc esi
		cmp esi, dword[ebx+48]
		jle _generate_load_radius_loop_start
	_generate_load_radius_loop_done:

		
	;search for unloadable chomks
	mov ebx, dword[ebp+20]
	mov esi, dword[ebx]		;index
	mov edi, dword[ebx+12]		;loaded chomks in edi
	cmp esi, 0
	je _generate_unload_loop_end
	_generate_unload_loop_start:
		
		mov eax, dword[edi+4*esi-4]		;current chomk
		
		;check if unloadable
		mov ecx, dword[eax]
		sub ecx, dword[ebp-4]
		cmp ecx, dword[ebx+48]
		jg _generate_unload_loop_unload_chomk
		xor ecx, 0xFFFFFFFF
		inc ecx
		cmp ecx, dword[ebx+48]
		jg _generate_unload_loop_unload_chomk
		
		mov ecx, dword[eax+4]
		sub ecx, dword[ebp-8]
		cmp ecx, dword[ebx+48]
		jg _generate_unload_loop_unload_chomk
		xor ecx, 0xFFFFFFFF
		inc ecx
		cmp ecx, dword[ebx+48]
		jg _generate_unload_loop_unload_chomk
		
		jmp _generate_unload_loop_skip_unload_chomk
		_generate_unload_loop_unload_chomk:
			push eax
			push ebx
			call chomkManager_removeChomk
			add esp, 8
		_generate_unload_loop_skip_unload_chomk:
		dec esi
		cmp esi, 0
		jg _generate_unload_loop_start
	_generate_unload_loop_end:
	

	push ebx
	;call chomkManager_printLoadedChomks
	add esp, 4

	
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
	
	
chomkManager_printLoadedChomks:
	mov eax, dword[esp+4]
	push dword[eax]
	push print_loaded_chomk_count
	call printf
	add esp, 8
	ret
	
	
chomkManager_printLoadedChomksDetailed:
	push ebp
	push esi
	push edi
	mov ebp, esp
	
	mov eax, dword[ebp+16]
	push dword[eax]
	push print_loaded_chomk_count
	call printf
	add esp, 8
	
	mov esi, dword[ebp+16]
	mov edi, dword[esi]
	mov esi, dword[esi+12]
	cmp edi, 0
	je _printLoadedChomks_print_loop_end
	_printLoadedChomks_print_loop_start:
		mov eax, dword[esi]
		push dword[eax+4]
		push dword[eax]
		push eax
		push print_three_ints
		call printf
		add esp, 16
		
		add esi, 4
		dec edi
		cmp edi, 0
		jg _printLoadedChomks_print_loop_start
	_printLoadedChomks_print_loop_end:
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebp
	ret
