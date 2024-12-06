;layout:
;struct colliderGroup{
;	vector<collider*> colliders	;0
;	vec3 lowerBound			;16
;	vec3 upperBound			;28
;} 	//40 bytes

section .rodata
	print_collider_group_count db "Active collider group count: %d",10,0
	print_collider_group_creation_error db "Could not create collider group", 10,0
	print_collider_group_info_1 db "Collider group info:",10,0
	print_collider_group_info_2 db "Lower bound: ",0
	print_collider_group_info_3 db "Upper bound: ",0
	print_collider_group_info_4 db "Collider count: %d",10,0

section .data
	colliderGroupCount dd 0

section .text
	extern printf
	extern malloc
	extern free
	extern memcpy
	
	extern vector_init
	extern vector_destroy
	extern vector_push_back
	extern vector_remove
	
	extern vec3_add
	extern vec3_print
	
	extern collider_resolveCollision
	extern collider_destroyCollider
	
	global colliderGroup_printColliderGroupCount
	
	global colliderGroup_createColliderGroup		;colliderGroup* colliderGroup_createColliderGroup()
	global colliderGroup_destroyColliderGroup		;void colliderGroup_destroyColliderGroup(colliderGroup* cg, int destroyColliders)
	
	global colliderGroup_addCollider			;void colliderGroup_addCollider(colliderGroup* cg, collider* collider)
	global colliderGroup_removeCollider			;void colliderGroup_removeCollider(colliderGroup* cg, collider* collider)
	
	global colliderGroup_collide				;void colliderGroup_collide(colliderGroup* cg, collider* dynamicCollider)
	global colliderGroup_isColliderInBounds			;int colliderGroup_isColliderInBounds(colliderGroup* cg, collider* collider)
	
	global colliderGroup_printInfo				;void colliderGroup_printInfo(colliderGroup* cg)
	
colliderGroup_printColliderGroupCount:
	push dword[colliderGroupCount]
	push print_collider_group_count
	call printf
	add esp, 8
	ret
	
	
colliderGroup_createColliderGroup:
	push ebp
	push ebx
	mov ebp, esp
	
	push 40
	call malloc
	mov ebx, eax
	add esp, 4
	cmp eax, 0
	jne _createColliderGroup_no_error
	
	push print_collider_group_creation_error
	call malloc
	mov eax, 0
	jmp _createColliderGroup_done

_createColliderGroup_no_error:
	
	push 4
	push ebx
	call vector_init
	add esp, 8
	
	mov dword[ebx+16], 0
	mov dword[ebx+20], 0
	mov dword[ebx+24], 0
	mov dword[ebx+28], 0
	mov dword[ebx+32], 0
	mov dword[ebx+36], 0
	
	mov eax, ebx
	inc dword[colliderGroupCount]

_createColliderGroup_done:
	mov esp, ebp
	pop ebx
	pop ebp
	ret
	
	
	
colliderGroup_destroyColliderGroup:
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	
	mov ebx, dword[ebp+20]		;colliderGroup in ebx
	
	;destroy the colliders in the collider group
	mov eax, dword[ebp+24]
	cmp eax, 0
	je _destroyColliderGroup_skip_collider_destroy
	mov eax, dword[ebx]
	cmp eax, 0			;there are no colliders in the collider group
	je _destroyColliderGroup_skip_collider_destroy
	
	mov esi, dword[ebx]
	dec esi
	mov edi, dword[ebx+12]
_destroyColliderGroup_collider_destroy_loop_start:
	push dword[edi+4*esi]
	call collider_destroyCollider
	add esp, 4
	
	dec esi
	cmp esi, 0
	jge _destroyColliderGroup_collider_destroy_loop_start
	
_destroyColliderGroup_skip_collider_destroy:

	;destroy the collider vector
	push ebx
	call vector_destroy
	add esp, 4
	
	;free
	push ebx
	call free
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
	
	
	
colliderGroup_addCollider:
	push ebp
	mov ebp, esp
	
	push dword[ebp+12]
	push dword[ebp+8]
	call vector_push_back
	call adjustBounds
	
	mov esp, ebp
	pop ebp
	ret
	
	
colliderGroup_removeCollider:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	mov ecx, dword[ebp+12]
	push ecx
	push eax
	call vector_remove
	call recalculateBounds
	
	mov esp, ebp
	pop ebp
	ret
	
	
colliderGroup_collide:
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	sub esp, 4		;temp collider array
	
	mov ebx, dword[ebp+20]		;cg in ebx
	
	;check if the dynamic collider is in bounds
	push dword[ebp+24]
	push dword[ebp+20]
	call colliderGroup_isColliderInBounds
	add esp, 8
	cmp eax, 0
	je _collide_done
	
	
	;make a copy of the static colliders and sort them according to distace from the dynamic collider
	mov eax, dword[ebx]
	imul eax, 4
	push eax
	call malloc
	mov dword[ebp-4], eax
	push dword[ebx+12]
	push eax
	call memcpy
	add esp, 12
	
	
	;resolve collisions
	mov edi, dword[ebp-4]		;colliders in edi
	mov esi, dword[ebx]		;collider count in esi
	cmp esi, 0
	je _collide_resolve_collision_end
	sub esp, 4			;prealloc function parameters
	push dword[ebp+24]
_collide_resolve_collision_start:
	mov eax, dword[edi]
	mov dword[esp+4], eax
	call collider_resolveCollision
	add edi, 4
	dec esi
	cmp esi, 0
	jg _collide_resolve_collision_start
_collide_resolve_collision_end:
	

	;free copied array
	push dword[ebp-4]
	call free
	
_collide_done:
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
	
	
colliderGroup_isColliderInBounds:
	push ebp
	mov ebp, esp
	
	sub esp, 12		;collider->lowerBound+collider->position
	sub esp, 12		;collider->upperBound+collider->position


	;calculate collider bounds
	mov eax, dword[ebp+12]		;collider in eax
	lea ecx,[ebp-12]
	lea edx, [eax]
	push edx
	lea edx, [eax+24]
	push edx
	push ecx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+12]		;collider in eax
	lea ecx,[ebp-24]
	lea edx, [eax+12]
	push edx
	lea edx, [eax+24]
	push edx
	push ecx
	call vec3_add
	add esp, 12
	
	;check for thing
	mov eax, 0		;return value
	mov ecx, dword[ebp+8]	;cg in ecx
	
	movss xmm0, dword[ecx+16]
	movss xmm1, dword[ebp-24]
	ucomiss xmm1, xmm0
	jb _isColliderInBounds_done
	
	movss xmm0, dword[ecx+20]
	movss xmm1, dword[ebp-20]
	ucomiss xmm1, xmm0
	jb _isColliderInBounds_done
	
	movss xmm0, dword[ecx+24]
	movss xmm1, dword[ebp-16]
	ucomiss xmm1, xmm0
	jb _isColliderInBounds_done
	
	movss xmm0, dword[ecx+28]
	movss xmm1, dword[ebp-12]
	ucomiss xmm1, xmm0
	ja _isColliderInBounds_done
	
	movss xmm0, dword[ecx+32]
	movss xmm1, dword[ebp-8]
	ucomiss xmm1, xmm0
	ja _isColliderInBounds_done
	
	movss xmm0, dword[ecx+36]
	movss xmm1, dword[ebp-4]
	ucomiss xmm1, xmm0
	ja _isColliderInBounds_done
	
	mov eax, 69

_isColliderInBounds_done:
	mov esp, ebp
	pop ebp
	ret
	
	
colliderGroup_printInfo:
	push ebp
	mov ebp, esp
	
	push print_collider_group_info_1
	call printf
	add esp, 4
	
	mov eax, dword[ebp+8]
	add eax, 16
	push eax
	push print_collider_group_info_2
	call printf
	add esp, 4
	call vec3_print
	add esp, 4
	
	mov eax, dword[ebp+8]
	add eax, 28
	push eax
	push print_collider_group_info_3
	call printf
	add esp, 4
	call vec3_print
	add esp, 4
	
	mov eax, dword[ebp+8]
	push dword[eax]
	push print_collider_group_info_4
	call printf
	add esp, 8
	
	mov esp, ebp
	pop ebp 
	ret
	
	
adjustBounds:		;void adjustBounds(colliderGroup* cg, collider* c, int notFirst)
	push ebp
	mov ebp, esp
	
	sub esp, 12		;collider->lowerBound+collider->position
	sub esp, 12		;collider->upperBound+collider->position


	;calculate collider bounds
	mov eax, dword[ebp+12]		;collider in eax
	lea ecx,[ebp-12]
	lea edx, [eax]
	push edx
	lea edx, [eax+24]
	push edx
	push ecx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+12]		;collider in eax
	lea ecx,[ebp-24]
	lea edx, [eax+12]
	push edx
	lea edx, [eax+24]
	push edx
	push ecx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+16]
	cmp eax, 0
	jne _adjustBounds_not_first
	
	mov eax, dword[ebp+8]
	lea ecx, [eax+16]
	lea edx, [ebp-12]
	push 12
	push edx
	push ecx
	call memcpy
	add esp, 12
	
	mov eax, dword[ebp+8]
	lea ecx, [eax+28]
	lea edx, [ebp-24]
	push 12
	push edx
	push ecx
	call memcpy
	add esp, 12
	
	jmp _adjustBounds_done

_adjustBounds_not_first:
	
	;check if the collider group's bound has changed
	mov eax, dword[ebp+8]		;cg in eax
	
	movss xmm0, dword[eax+16]
	movss xmm1, dword[ebp-12]
	ucomiss xmm1, xmm0
	ja _adjustBounds_skip1
	movss dword[eax+16], xmm1
_adjustBounds_skip1:

	movss xmm0, dword[eax+20]
	movss xmm1, dword[ebp-8]
	ucomiss xmm1, xmm0
	ja _adjustBounds_skip2
	movss dword[eax+20], xmm1
_adjustBounds_skip2:

	movss xmm0, dword[eax+24]
	movss xmm1, dword[ebp-4]
	ucomiss xmm1, xmm0
	ja _adjustBounds_skip3
	movss dword[eax+24], xmm1
_adjustBounds_skip3:

	movss xmm0, dword[eax+28]
	movss xmm1, dword[ebp-24]
	ucomiss xmm1, xmm0
	jb _adjustBounds_skip4
	movss dword[eax+28], xmm1
_adjustBounds_skip4:

	movss xmm0, dword[eax+32]
	movss xmm1, dword[ebp-20]
	ucomiss xmm1, xmm0
	jb _adjustBounds_skip5
	movss dword[eax+32], xmm1
_adjustBounds_skip5:

	movss xmm0, dword[eax+36]
	movss xmm1, dword[ebp-16]
	ucomiss xmm1, xmm0
	jb _adjustBounds_skip6
	movss dword[eax+36], xmm1
_adjustBounds_skip6:
	
	
_adjustBounds_done:
	mov esp, ebp
	pop ebp
	ret
	
	
recalculateBounds:		;void recalculateBounds(colliderGroup* cg)
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	mov ebx, dword[ebp+20]	;collider group in ebx
	mov esi, dword[ebx]	;collider count in esi
	mov edi, dword[ebx+12]	;colliders in edi
	mov eax, 0		;index
	cmp esi, 0
	je _recalculateBounds_done
_recalculateBounds_loop_start:
	push eax
	push edi
	push ebx
	call adjustBounds
	add esp, 8
	pop eax
	
	inc eax
	add edi, 4
	cmp eax, esi
	jl _recalculateBounds_loop_start
	
_recalculateBounds_done:
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
