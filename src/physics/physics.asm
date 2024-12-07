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
	
	extern colliderGroup_collide
	
	global physics_init			;void physics_init()
	global physics_deinit			;void physics_deinit()
	global physics_step			;void physics_step(float deltaTimeInSex)
	
	global physics_registerDynamicCollider	;void physics_registerDynamicCollider(collider* collider)
	global physics_removeDynamicCollider	;void physics_removeDynamicCollider(collider* collider)
	global physics_registerColliderGroup	;void physics_registerColliderGroup(colliderGroup* cg)
	global physics_removeColliderGroup	;void physics_removeColliderGroup(colliderGroup* cg)
	
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
