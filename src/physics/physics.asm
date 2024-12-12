section .rodata
	GAYCAST_COLLIDER_LOWER_BOUND dd -0.1, -0.1, -0.1
	GAYCAST_COLLIDER_UPPER_BOUND dd 0.1, 0.1, 0.1
	
	;this is the size of the raycast collider when checking if it is in a collidergroup
	GAYCAST_COLLIDER_SEARCH_LOWER_BOUND dd 0.0, 0.0, 0.0
	GAYCAST_COLLIDER_SEARCH_UPPER_BOUND dd 0.0, 0.0, 0.0
	
	GAYCAST_INITIAL_PRECISION dd 0.5
	
	HALF dd 0.5

section .bss
	REGISTERED_DYNAMIC_COLLIDERS resb 16
	REGISTERED_COLLIDER_GROUPS resb 16
	
section .text
	extern printf
	extern malloc
	extern free
	extern memcpy
	extern memset
	
	extern vector_init
	extern vector_destroy
	extern vector_push_back
	extern vector_remove
	
	extern vec3_scale
	extern vec3_add
	extern vec3_normalize
	extern vec3_print
	
	extern collider_createCollider
	extern collider_destroyCollider
	extern colliderGroup_collide
	extern colliderGroup_raycastHelper
	extern colliderGroup_isColliderInBounds
	extern colliderGroup_physicsRaycastHelper
	
	global physics_init			;void physics_init()
	global physics_deinit			;void physics_deinit()
	global physics_step			;void physics_step(float deltaTimeInSex)
	
	global physics_registerDynamicCollider	;void physics_registerDynamicCollider(collider* collider)
	global physics_removeDynamicCollider	;void physics_removeDynamicCollider(collider* collider)
	global physics_registerColliderGroup	;void physics_registerColliderGroup(colliderGroup* cg)
	global physics_removeColliderGroup	;void physics_removeColliderGroup(colliderGroup* cg)
	
	;returns NULL, if no raycast hit, a collider with the collision informations otherwise.
	;the returned collider shall be released by the caller
	global physics_staticRaycast		;collider* physics_staticRaycast(vec3* position, vec3* direction, float distance)
	
physics_init:
	push ebp
	mov ebp, esp
	
	push 4
	push REGISTERED_DYNAMIC_COLLIDERS
	call vector_init
	add esp, 8
	
	push 4
	push REGISTERED_COLLIDER_GROUPS
	call vector_init
	add esp, 8
	
	mov esp, ebp
	pop ebp
	ret
	
	
physics_deinit:
	push ebp
	mov ebp, esp
	
	push REGISTERED_DYNAMIC_COLLIDERS
	call vector_destroy
	add esp, 4
	
	push REGISTERED_COLLIDER_GROUPS
	call vector_destroy
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret
	
	
physics_step:
	push ebp
	push esi
	push edi
	push ebx
	mov ebp, esp
	
	sub esp, 12		;temp vector
	
	mov eax, dword[REGISTERED_DYNAMIC_COLLIDERS]
	cmp eax, 0
	je _step_done
	
	;clear the collision infos of dynamic colliders
	mov esi, REGISTERED_DYNAMIC_COLLIDERS
	mov esi, dword[esi+12]
	mov edi, dword[REGISTERED_DYNAMIC_COLLIDERS]
	_step_clear_info_start:
		mov eax, dword[esi]
		mov dword[eax+48], 0
		mov dword[eax+56], 0
		
		add esi, 4
		dec edi
		cmp edi, 0
		jg _step_clear_info_start
	
	
	;apply velocity
	mov esi, REGISTERED_DYNAMIC_COLLIDERS
	mov esi, dword[esi+12]		;dynamic colliders in esi
	mov edi, dword[REGISTERED_DYNAMIC_COLLIDERS]	;dynamic collider count in edi
_step_velocity_loop_start:
	mov ebx, dword[esi]
	
	push dword[ebp+20]
	lea eax, [ebx+36]
	push eax
	lea eax, [ebp-12]
	push eax
	call vec3_scale
	lea eax, [ebx+24]
	push eax
	push eax
	call vec3_add
	add esp, 20
	
	add esi, 4
	dec edi
	cmp edi, 0
	jg _step_velocity_loop_start
	
	;detect collisions
	mov eax, dword[REGISTERED_COLLIDER_GROUPS]
	cmp eax, 0
	je _step_done
	
	mov esi, REGISTERED_DYNAMIC_COLLIDERS
	mov esi, dword[esi+12]				;dynamic colliders in esi
	mov edi, dword[REGISTERED_DYNAMIC_COLLIDERS]	;dynamic collider count in edi
_step_collision_outer_loop_start:
		push esi		;save esi
		push edi		;save edi
		push dword[esi]		;push collider* for colliderGroup_collide
		
		mov esi, REGISTERED_COLLIDER_GROUPS
		mov esi, dword[esi+12]				;collider groups in esi
		mov edi, dword[REGISTERED_COLLIDER_GROUPS]	;collider group count in edi
		_step_collision_inner_loop_start:
			
			push dword[esi]
			call colliderGroup_collide
			add esp, 4
			
			add esi, 4
			dec edi
			cmp edi, 0
			jg _step_collision_inner_loop_start
		
		add esp, 4
		pop edi
		pop esi
		
		add esi, 4
		dec edi
		cmp edi, 0
		jg _step_collision_outer_loop_start

_step_done:
	mov esp, ebp
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret
	
	
physics_registerDynamicCollider:
	mov eax, dword[esp+4]
	push eax
	push REGISTERED_DYNAMIC_COLLIDERS
	call vector_push_back
	add esp, 8
	ret
	
physics_removeDynamicCollider:
	mov eax, dword[esp+4]
	push eax
	push REGISTERED_DYNAMIC_COLLIDERS
	call vector_remove
	add esp, 8
	ret
	
	
physics_registerColliderGroup:
	mov eax, dword[esp+4]
	push eax
	push REGISTERED_COLLIDER_GROUPS
	call vector_push_back
	add esp, 8
	ret
	
physics_removeColliderGroup:
	mov eax, dword[esp+4]
	push eax
	push REGISTERED_COLLIDER_GROUPS
	call vector_remove
	add esp, 8
	ret
	
	
physics_staticRaycast:
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	
	sub esp, 4		;the collider
	sub esp, 4		;current step size float
	sub esp, 4		;max step count int
	sub esp, 12		;last position with no collision
	sub esp, 12		;current position
	sub esp, 12		;current step vector
	sub esp, 4		;currently examined cg
	
	mov dword[ebp-52], 0		;set the current cg to NULL
	
	;calculate current step size (adjust the initial precision so that the distance is divisible by it)
	fld dword[ebp+28]
	fld st0
	fld dword[GAYCAST_INITIAL_PRECISION]
	fdivp
	frndint
	fist dword[ebp-12]		;save max step count
	fdivp
	fstp dword[ebp-8]		;save step size
	
	;create collider
	push GAYCAST_COLLIDER_UPPER_BOUND
	push GAYCAST_COLLIDER_LOWER_BOUND
	call collider_createCollider
	mov dword[ebp-4], eax
	add esp, 8
	
	;set collider position and collision data
	mov eax, dword[ebp-4]
	mov ecx, dword[ebp+20]
	mov edx, dword[ecx]
	mov dword[eax+24], edx
	mov edx, dword[ecx+4]
	mov dword[eax+28], edx
	mov edx, dword[ecx+8]
	mov dword[eax+32], edx
	
	mov dword[eax+48], 0
	mov dword[eax+56], 0
	
	;set last no hit and current position
	push 12
	push dword[ebp+20]
	lea eax, [ebp-24]
	push eax
	call memcpy
	lea eax, [ebp-36]
	mov dword[esp], eax
	call memcpy
	add esp, 12
	
	;calculate step vector
	push 12
	push dword[ebp+24]
	lea eax, [ebp-48]
	push eax
	call memcpy
	call vec3_normalize
	add esp, 12
	
	lea eax, [ebp-48]
	push dword[ebp-8]
	push eax
	push eax
	call vec3_scale
	add esp, 12
	
	mov eax, dword[REGISTERED_COLLIDER_GROUPS]
	cmp eax, 0
	je _staticRaycast_no_hit
	
	mov ebx, dword[ebp-12]		;index in ebx
	_staticRaycast_step_loop_start:
		;set last no hit position to current position
		sub esp, 12
		mov dword[esp+8], 12
		lea eax, [ebp-36]
		mov dword[esp+4], eax
		lea eax, [ebp-24]
		mov dword[esp], eax
		call memcpy
		
		;update current position
		lea eax, [ebp-48]
		mov dword[esp+8], eax
		lea eax, [ebp-36]
		mov dword[esp+4], eax
		mov dword[esp], eax
		call vec3_add
		add esp, 12
		
		;move collider and clear collision info
		mov eax, dword[ebp-4]
		mov dword[eax+48], 0
		mov dword[eax+56], 0
		add eax, 24
		lea ecx, [ebp-36]
		sub esp, 12
		mov dword[esp+8], 12
		mov dword[esp+4], ecx
		mov dword[esp], eax
		call memcpy
		add esp, 12
		
		;set the collider to the search size
		mov eax, dword[ebp-4]
		push 24
		push 0
		push eax
		call memset
		add esp, 12
		
		;check if it is still in the current collider
		mov eax, dword[ebp-52]
		cmp eax, 0
		je _staticRaycast_cg_search_is_needed
		
		push dword[ebp-4]
		push dword[ebp-52]
		call colliderGroup_isColliderInBounds
		add esp, 8
		cmp eax, 0
		jne _staticRaycast_no_cg_search_is_needed
		_staticRaycast_cg_search_is_needed:
			mov dword[ebp-52], 0
			mov esi, dword[REGISTERED_COLLIDER_GROUPS]		;index in esi
			mov eax, REGISTERED_COLLIDER_GROUPS
			mov edi, dword[eax+12]					;cgs in edi
			push dword[ebp-4]
			_staticRaycast_cg_search_loop_start:
				push dword[edi]
				call colliderGroup_isColliderInBounds
				add esp, 4
				cmp eax, 0
				je _staticRaycast_cg_search_continue
				
				mov eax, dword[edi]
				mov dword[ebp-52], eax
				jmp _staticRaycast_cg_search_loop_end
				
				_staticRaycast_cg_search_continue:
				add edi, 4
				dec esi
				cmp esi, 0
				jg _staticRaycast_cg_search_loop_start
			_staticRaycast_cg_search_loop_end:
			add esp, 4
		_staticRaycast_no_cg_search_is_needed:
		
		mov eax, dword[ebp-52]
		cmp eax, 0
		je _staticRaycast_step_loop_continue
		
		;set the collider to the collision size
		mov eax, dword[ebp-4]
		push 24
		push GAYCAST_COLLIDER_LOWER_BOUND
		push eax
		call memcpy
		add esp, 12
		
		push dword[ebp+28]
		push dword[ebp+24]
		push dword[ebp+20]
		push dword[ebp-4]
		push dword[ebp-52]
		call colliderGroup_physicsRaycastHelper
		add esp, 20
		
		;was there a hit?
		cmp eax, 0
		jne _staticRaycast_step_loop_end

		
		_staticRaycast_step_loop_continue:
		dec ebx
		cmp ebx, 0
		jg _staticRaycast_step_loop_start
	_staticRaycast_step_loop_end:
	
	;check for raycast hit
	mov eax, dword[ebp-4]
	mov eax, dword[eax+48]
	cmp eax, 0
	je _staticRaycast_no_hit
	
	mov eax, dword[ebp-4]
	jmp _staticRaycast_done
	
	_staticRaycast_no_hit:
		push dword[ebp-4]
		call collider_destroyCollider
		add esp, 4
		xor eax, eax
	
	_staticRaycast_done:
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
