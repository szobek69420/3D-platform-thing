;layout:
;struct collider{
;	vec3 lowerBound			;0
;	vec3 upperBound			;12
;	vec3 position			;24
;	vec3 velocity			;36
;	int collisions			;48, stores the collision directions in the last frame
;	int colliderType		;52	//this is an optional identifier for the collider
;	collider* lastCollision		;56	//gets set only for the dynamic colliders
;}	//60 bytes

COLLISION_POS_X equ 0b1
COLLISION_NEG_X equ 0b10
COLLISION_POS_Y equ 0b100
COLLISION_NEG_Y equ 0b1000
COLLISION_POS_Z equ 0b10000
COLLISION_NEG_Z equ 0b100000

global COLLISION_POS_X
global COLLISION_NEG_X
global COLLISION_POS_Y
global COLLISION_NEG_Y
global COLLISION_POS_Z
global COLLISION_NEG_Z

section .rodata
	print_collider_count db "Number of active colliders: %d",10,0
	print_collider_creation_error db "Collider could not be created",10,0
	
	print_collider_info1 db "Collider info:",10,0
	print_collider_info2 db "position: ",0
	print_collider_info3 db "velocity: ",0
	print_collider_info4 db "lower bound: ",0
	print_collider_info5 db "upper bound: ",0
	
	VERY_LARGE_PENETRATION dd 100000.0
	VERY_LOW_NUMBER dd -10000.0

section .data
	colliderCount dd 0

section .text
	extern printf
	extern malloc
	extern free
	extern memcpy
	
	extern vec3_add
	extern vec3_print
	
	global collider_printColliderCount
	
	global collider_createCollider		;collider* collider_createCollider(vec3* lowerBound, vec3* upperBound)
	global collider_destroyCollider		;void collider_destroyCollider(collider* collider)
	
	global collider_printInfo		;void collider_printInfo(collider* collider)
	
	global collider_resolveCollision	;int collider_resolveCollision(collider* dynamic, collider* static)
	
	global collider_calculateDistance	;float collider_calculateDistance(collider* c1, collider* c2),  pushes the result onto the FPU stack
	
collider_printColliderCount:
	push dword[colliderCount]
	push print_collider_count
	call printf
	add esp, 8
	ret
	
	
	
collider_createCollider:
	push ebp
	push ebx
	mov ebp, esp
	
	;alloc collider
	push 60
	call malloc
	mov ebx, eax
	add esp, 4
	cmp ebx, 0
	jne _createCollider_no_error
	
	push print_collider_creation_error
	call printf
	mov eax, 0
	jmp _createCollider_done
	
	
_createCollider_no_error:

	;copy lower bound
	push 12
	push dword[ebp+12]
	push ebx
	call memcpy
	
	;copy upper bound
	add dword[esp], 12
	mov eax, dword[ebp+16]
	mov dword[esp+4], eax
	call memcpy
	add esp, 12
	
	;set position, velocity, collisions, type and last collision
	mov dword[ebx+24], 0
	mov dword[ebx+28], 0
	mov dword[ebx+32], 0
	mov dword[ebx+36], 0
	mov dword[ebx+40], 0
	mov dword[ebx+44], 0
	mov dword[ebx+48], 0
	mov dword[ebx+52], 0
	mov dword[ebx+56], 0
	
	mov eax, ebx
	inc dword[colliderCount]
	
_createCollider_done:
	mov esp, ebp
	pop ebx
	pop ebp
	ret
	
	
collider_destroyCollider:
	push dword[esp+4]
	call free
	add esp, 4
	dec dword[colliderCount]
	ret
	
	
collider_resolveCollision:
	push ebp
	mov ebp, esp
	
	sub esp, 12			;dynamic->upperBound+dynamic->position
	sub esp, 12			;dynamic->lowerBound+dynamic->position
	sub esp, 12			;static->upperBound+static->position
	sub esp, 12			;static->lowerBound+static->position
	
	push dword[VERY_LARGE_PENETRATION]		;minPenetration
	push 0						;minPenetrationDirection
	
	;test if they touch
	push dword[ebp+8]
	push dword[ebp+12]
	call collider_areCollidersInContact
	add esp, 8
	cmp eax, 0
	jne _resolveCollision_touch
	
	mov esp, ebp
	pop ebp
	ret
	
_resolveCollision_touch:
	;calculate new bounds
	mov eax, dword[ebp+8]		;dynamic in eax
	lea edx, [eax]
	push edx
	lea edx, [eax+24]
	push edx
	lea edx, [ebp-24]
	push edx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+8]		;dynamic in eax
	lea edx, [eax+12]
	push edx
	lea edx, [eax+24]
	push edx
	lea edx, [ebp-12]
	push edx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+12]		;static in eax
	lea edx, [eax]
	push edx
	lea edx, [eax+24]
	push edx
	lea edx, [ebp-48]
	push edx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+12]		;static in eax
	lea edx, [eax+12]
	push edx
	lea edx, [eax+24]
	push edx
	lea edx, [ebp-36]
	push edx
	call vec3_add
	add esp, 12
	
	;search for double penetration
	lea eax, [ebp-24]		;dynamic bounds in eax
	lea ecx, [ebp-48]		;static bounds in ecx
	movss xmm2, dword[esp+4]	;minPenetration
	
	movss xmm0, dword[eax]
	movss xmm1, dword[ecx+12]
	subss xmm1, xmm0
	ucomiss xmm1, xmm2
	ja _resolveCollision_not_neg_x
	movss xmm2, xmm1
	movss dword[esp+4], xmm2
	mov dword[esp], COLLISION_NEG_X
_resolveCollision_not_neg_x:

	movss xmm0, dword[eax+4]
	movss xmm1, dword[ecx+16]
	subss xmm1, xmm0
	ucomiss xmm1, xmm2
	ja _resolveCollision_not_neg_y
	movss xmm2, xmm1
	movss dword[esp+4], xmm2
	mov dword[esp], COLLISION_NEG_Y
_resolveCollision_not_neg_y:

	movss xmm0, dword[eax+8]
	movss xmm1, dword[ecx+20]
	subss xmm1, xmm0
	ucomiss xmm1, xmm2
	ja _resolveCollision_not_neg_z
	movss xmm2, xmm1
	movss dword[esp+4], xmm2
	mov dword[esp], COLLISION_NEG_Z
_resolveCollision_not_neg_z:


	mov edx, eax
	mov eax, ecx		;static in eax
	mov ecx, edx		;dynamic in ecx
	
	
	movss xmm0, dword[eax]
	movss xmm1, dword[ecx+12]
	subss xmm1, xmm0
	ucomiss xmm1, xmm2
	ja _resolveCollision_not_pos_x
	movss xmm2, xmm1
	movss dword[esp+4], xmm2
	mov dword[esp], COLLISION_POS_X
_resolveCollision_not_pos_x:

	movss xmm0, dword[eax+4]
	movss xmm1, dword[ecx+16]
	subss xmm1, xmm0
	ucomiss xmm1, xmm2
	ja _resolveCollision_not_pos_y
	movss xmm2, xmm1
	movss dword[esp+4], xmm2
	mov dword[esp], COLLISION_POS_Y
_resolveCollision_not_pos_y:

	movss xmm0, dword[eax+8]
	movss xmm1, dword[ecx+20]
	subss xmm1, xmm0
	ucomiss xmm1, xmm2
	ja _resolveCollision_not_pos_z
	movss xmm2, xmm1
	movss dword[esp+4], xmm2
	mov dword[esp], COLLISION_POS_Z
_resolveCollision_not_pos_z:


	mov eax, dword[ebp+8]		;dynamic in eax
	mov ecx, dword[ebp+12]		;static in ecx
	movss xmm0, dword[esp+4]	;penetration in xmm0
	
	mov edx, dword[esp]
	or dword[eax+48], edx		;apply collision mask
	
	cmp edx, COLLISION_NEG_X
	je _resolveCollision_neg_x
	cmp edx, COLLISION_POS_X
	je _resolveCollision_pos_x
	cmp edx, COLLISION_NEG_Y
	je _resolveCollision_neg_y
	cmp edx, COLLISION_POS_Y
	je _resolveCollision_pos_y
	cmp edx, COLLISION_NEG_Z
	je _resolveCollision_neg_z
	cmp edx, COLLISION_POS_Z
	je _resolveCollision_pos_z
	jmp _resolveCollision_done
	
_resolveCollision_pos_x:
	movss xmm1, dword[eax+24]
	subss xmm1, xmm0
	movss dword[eax+24], xmm1
	mov dword[eax+36], 0
	jmp _resolveCollision_done
	
_resolveCollision_pos_y:
	movss xmm1, dword[eax+28]
	subss xmm1, xmm0
	movss dword[eax+28], xmm1
	mov dword[eax+40], 0
	jmp _resolveCollision_done
	
_resolveCollision_pos_z:
	movss xmm1, dword[eax+32]
	subss xmm1, xmm0
	movss dword[eax+32], xmm1
	mov dword[eax+44], 0
	jmp _resolveCollision_done
	
_resolveCollision_neg_x:
	movss xmm1, dword[eax+24]
	addss xmm1, xmm0
	movss dword[eax+24], xmm1
	mov dword[eax+36], 0
	jmp _resolveCollision_done
	
_resolveCollision_neg_y:
	movss xmm1, dword[eax+28]
	addss xmm1, xmm0
	movss dword[eax+28], xmm1
	mov dword[eax+40], 0
	jmp _resolveCollision_done
	
_resolveCollision_neg_z:
	movss xmm1, dword[eax+32]
	addss xmm1, xmm0
	movss dword[eax+32], xmm1
	mov dword[eax+44], 0
	jmp _resolveCollision_done

	
_resolveCollision_done:
	mov ecx, dword[ebp+8]
	mov edx, dword[ebp+12]
	mov dword[ecx+56], edx
	mov eax, 69
	mov esp, ebp
	pop ebp
	ret
	
	
collider_areCollidersInContact:		;int collider_areCollidersInContact(collider* c1, collider* c2)
	push ebp
	mov ebp, esp
	
	sub esp, 12			;c1->upperBound+c1->position
	sub esp, 12			;c1->lowerBound+c1->position
	sub esp, 12			;c2->upperBound+c2->position
	sub esp, 12			;c2->lowerBound+c2->position
	
	push 0				;return value
	
	;calculate new bounds	
	mov eax, dword[ebp+8]		;c1 in eax
	lea edx, [eax]
	push edx
	lea edx, [eax+24]
	push edx
	lea edx, [ebp-24]
	push edx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+8]		;c1 in eax
	lea edx, [eax+12]
	push edx
	lea edx, [eax+24]
	push edx
	lea edx, [ebp-12]
	push edx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+12]		;c2 in eax
	lea edx, [eax]
	push edx
	lea edx, [eax+24]
	push edx
	lea edx, [ebp-48]
	push edx
	call vec3_add
	add esp, 12
	
	mov eax, dword[ebp+12]		;c2 in eax
	lea edx, [eax+12]
	push edx
	lea edx, [eax+24]
	push edx
	lea edx, [ebp-36]
	push edx
	call vec3_add
	add esp, 12
	
	;check touching
	lea eax, [ebp-48]		;c2 bounds in eax
	lea ecx, [ebp-24]		;c1 bounds in ecx
	
	movss xmm0, dword[eax+12]
	movss xmm1, dword[ecx]
	ucomiss xmm0, xmm1
	jb _areColliders_inContact_no_collision
	
	movss xmm0, dword[eax+16]
	movss xmm1, dword[ecx+4]
	ucomiss xmm0, xmm1
	jb _areColliders_inContact_no_collision
	
	movss xmm0, dword[eax+20]
	movss xmm1, dword[ecx+8]
	ucomiss xmm0, xmm1
	jb _areColliders_inContact_no_collision
	
	mov edx, eax
	mov eax, ecx		;c1 bounds in eax
	mov ecx, edx		;c2 bounds in ecx
	
	movss xmm0, dword[eax+12]
	movss xmm1, dword[ecx]
	ucomiss xmm0, xmm1
	jb _areColliders_inContact_no_collision
	
	movss xmm0, dword[eax+16]
	movss xmm1, dword[ecx+4]
	ucomiss xmm0, xmm1
	jb _areColliders_inContact_no_collision
	
	movss xmm0, dword[eax+20]
	movss xmm1, dword[ecx+8]
	ucomiss xmm0, xmm1
	jb _areColliders_inContact_no_collision
	
	mov dword[esp], 1
	
_areColliders_inContact_no_collision:
	pop eax
	add esp, 48
	pop ebp
	ret
	
	
	
collider_printInfo:
	push ebp
	push ebx
	mov ebp, esp
	
	push print_collider_info1
	call printf
	add esp, 4
	
	mov ebx, dword[ebp+12]
	
	lea eax, [ebx+24]
	push eax
	push print_collider_info2
	call printf
	add esp, 4
	call vec3_print
	add esp, 4
	
	lea eax, [ebx+36]
	push eax
	push print_collider_info3
	call printf
	add esp, 4
	call vec3_print
	add esp, 4
	
	push ebx
	push print_collider_info4
	call printf
	add esp, 4
	call vec3_print
	add esp, 4
	
	lea eax, [ebx+12]
	push eax
	push print_collider_info5
	call printf
	add esp, 4
	call vec3_print
	add esp, 4
	
	mov esp, ebp
	pop ebx
	pop ebp
	ret
	
	
collider_calculateDistance:
	push ebp
	mov ebp, esp
	
	movss xmm5, dword[VERY_LOW_NUMBER]
	sub esp, 16		;temp
	
	;c1 upper and c2 lower
	mov eax, dword[ebp+8]
	movups xmm0, [eax+24]
	movups xmm1, [eax+12]
	addps xmm0, xmm1
	
	mov ecx, dword[ebp+12]
	movups xmm1, [ecx+24]
	movups xmm2, [ecx]
	addps xmm1, xmm2
	
	subps xmm1, xmm0
	movups [ebp-16], xmm1
	
	ucomiss xmm5, dword[ebp-16]
	ja _not_greater_1
		movss xmm5, dword[ebp-16]
	_not_greater_1:
	
	ucomiss xmm5, dword[ebp-12]
	ja _not_greater_2
		movss xmm5, dword[ebp-12]
	_not_greater_2:
	
	ucomiss xmm5, dword[ebp-8]
	ja _not_greater_3
		movss xmm5, dword[ebp-8]
	_not_greater_3:
	
	;c1 lower and c2 upper
	mov eax, dword[ebp+12]
	movups xmm0, [eax+24]
	movups xmm1, [eax+12]
	addps xmm0, xmm1
	
	mov ecx, dword[ebp+8]
	movups xmm1, [ecx+24]
	movups xmm2, [ecx]
	addps xmm1, xmm2
	
	subps xmm1, xmm0
	movups [ebp-16], xmm1
	
	ucomiss xmm5, dword[ebp-16]
	ja _not_greater_4
		movss xmm5, dword[ebp-16]
	_not_greater_4:
	
	ucomiss xmm5, dword[ebp-12]
	ja _not_greater_5
		movss xmm5, dword[ebp-12]
	_not_greater_5:
	
	ucomiss xmm5, dword[ebp-8]
	ja _not_greater_6
		movss xmm5, dword[ebp-8]
	_not_greater_6:
	
	movss dword[ebp-16], xmm5
	fld dword[ebp-16]
	
	mov esp, ebp
	pop ebp
	ret
