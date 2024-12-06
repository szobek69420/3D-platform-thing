;layout:
;struct colliderGroup{
;	vector<collider*> colliders	;0
;	vec3 lowerBound			;16
;	vec3 upperBound			;28
;} 	//40 bytes

section .rodata
	print_collider_group_count db "Active collider group count: %d",10,0
	print_collider_group_creation_error db "Could not create collider group", 10,0

section .data
	colliderGroupCount dd 0

section .text
	extern printf
	extern malloc
	extern free
	
	extern vector_init
	extern vector_destroy
	extern vector_push_back
	extern vector_remove
	
	extern collider_destroyCollider
	
	global colliderGroup_printColliderGroupCoung
	
	global colliderGroup_createColliderGroup		;colliderGroup* colliderGroup_createColliderGroup()
	global colliderGroup_destroyColliderGroup		;void colliderGroup_destroyColliderGroup(colliderGroup* cg, int destroyColliders)
	
	global colliderGroup_addCollider			;void colliderGroup_addCollider(colliderGroup* cg, collider* collider)
	global colliderGroup_removeCollider			;void colliderGroup_removeCollider(colliderGroup* cg, collider* collider)
	
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
	jge _destroyColliderGropu_collider_destroy_loop_start
	
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
	
	mov eax, dword[ebp+8]
	mov ecx, dword[ebp+12]
	push ecx
	push eax
	call vector_push_back
	
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
	
	mov esp, ebp
	pop ebp
	ret
