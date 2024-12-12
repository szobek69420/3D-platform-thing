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
	
	print_int_format db "%d",10,0
	print_float_format db "%.3f",10,0
	
	VERY_LARGE_PENETRATION dd 100000.0
	VERY_LOW_NUMBER dd -10000.0
	
	ONE dd 1.0
	MINUS_ONE dd -1.0
	
	COLLIDER_NEG_X_NORMAL dd -1.0, 0.0, 0.0
	COLLIDER_POS_X_NORMAL dd 1.0, 0.0, 0.0
	COLLIDER_NEG_Y_NORMAL dd 0.0, -1.0, 0.0
	COLLIDER_POS_Y_NORMAL dd 0.0, 1.0, 0.0
	COLLIDER_NEG_Z_NORMAL dd 0.0, 0.0, -1.0
	COLLIDER_POS_Z_NORMAL dd 0.0, 0.0, 1.0

section .data
	colliderCount dd 0

section .text
	extern printf
	extern malloc
	extern free
	extern memcpy
	
	extern vec3_add
	extern vec3_sub
	extern vec3_print
	extern vec3_normalize
	extern vec3_dot
	extern vec3_scale
	
	global collider_printColliderCount
	
	global collider_createCollider		;collider* collider_createCollider(vec3* lowerBound, vec3* upperBound)
	global collider_destroyCollider		;void collider_destroyCollider(collider* collider)
	
	global collider_printInfo		;void collider_printInfo(collider* collider)
	
	global collider_resolveCollision	;int collider_resolveCollision(collider* dynamic, collider* static)
	
	global collider_calculateDistance	;float collider_calculateDistance(collider* c1, collider* c2),  pushes the result onto the FPU stack
	global collider_calculateDistanceFromPoint	;float collider_calculateDistanceFromPoint(collider* collider, vec3* point),  pushes the result onto the FPU stack
	global collider_raycast			;void collider_raycast(collider* target, vec3* position, vec3* direction, float distance, collider* resultBuffer)		;writes the raycast result into the result buffer's collision info
	
	
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
	
	
collider_distanceFromPoint:
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
	ja _point_not_greater_1
		movss xmm5, dword[ebp-16]
	_point_not_greater_1:
	
	ucomiss xmm5, dword[ebp-12]
	ja _point_not_greater_2
		movss xmm5, dword[ebp-12]
	_point_not_greater_2:
	
	ucomiss xmm5, dword[ebp-8]
	ja _point_not_greater_3
		movss xmm5, dword[ebp-8]
	_point_not_greater_3:
	
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
	ja _point_not_greater_4
		movss xmm5, dword[ebp-16]
	_point_not_greater_4:
	
	ucomiss xmm5, dword[ebp-12]
	ja _point_not_greater_5
		movss xmm5, dword[ebp-12]
	_point_not_greater_5:
	
	ucomiss xmm5, dword[ebp-8]
	ja _point_not_greater_6
		movss xmm5, dword[ebp-8]
	_point_not_greater_6:
	
	movss dword[ebp-16], xmm5
	fld dword[ebp-16]
	
	mov esp, ebp
	pop ebp
	ret
	
	
collider_raycast:			;void collider_raycast(collider* target, vec3* position, vec3* direction, float distance, collider* resultBuffer)
	push ebp
	mov ebp, esp
	
	sub esp, 16		;16 lower bound
	sub esp, 16		;32 upper bound
	
	sub esp, 12		;44 normalized direction
	sub esp, 12		;56 point on plane
	sub esp, 12		;68 intersection point
	
	;calculate lower and upper bound
	mov eax, dword[ebp+8]
	movups xmm0, [eax+24]
	
	lea ecx, [ebp-16]
	movups xmm1, [eax]
	addps xmm1, xmm0
	movups [ecx], xmm1
	
	lea ecx, [ebp-32]
	movups xmm1, [eax+12]
	addps xmm1, xmm0
	movups [ecx], xmm1
	
	
	;calculate normalized direction
	mov eax, dword[ebp+16]
	mov ecx, dword[eax]
	mov dword[ebp-44], ecx
	mov ecx, dword[eax+4]
	mov dword[ebp-40], ecx
	mov ecx, dword[eax+8]
	mov dword[ebp-36], ecx
	lea eax, [ebp-44]
	push eax
	call vec3_normalize
	add esp, 4
	
	
	;neg x
		;point on plane
		mov eax, dword[ebp-16]
		mov dword[ebp-56], eax
		mov eax, dword[ebp-12]
		mov dword[ebp-52], eax
		mov eax, dword[ebp-8]
		mov dword[ebp-48], eax
		
		lea eax, [ebp-16]
		lea ecx, [ebp-32]
		lea edx, [ebp-56]
		push dword[ebp+20]
		push dword[ebp+24]
		push 0
		push edx
		push ecx
		push eax
		lea edx, [ebp-44]
		push edx
		push COLLIDER_NEG_X_NORMAL
		push dword[ebp+12]
		call raycastHelper
		add esp, 36
		cmp eax, 0
		je _raycast_not_neg_x
		
		;save the raycast hit
		mov eax, dword[ebp+24]
		mov dword[eax+48], COLLISION_POS_X
		mov ecx, dword[ebp+8]
		mov dword[eax+56], ecx
		
		jmp _raycast_done
	_raycast_not_neg_x:
	
	;pos x
		;point on plane
		mov eax, dword[ebp-32]
		mov dword[ebp-56], eax
		mov eax, dword[ebp-12]
		mov dword[ebp-52], eax
		mov eax, dword[ebp-8]
		mov dword[ebp-48], eax
		
		lea eax, [ebp-16]
		lea ecx, [ebp-32]
		lea edx, [ebp-56]
		push dword[ebp+20]
		push dword[ebp+24]
		push 0
		push edx
		push ecx
		push eax
		lea edx, [ebp-44]
		push edx
		push COLLIDER_POS_X_NORMAL
		push dword[ebp+12]
		call raycastHelper
		add esp, 36
		cmp eax, 0
		je _raycast_not_pos_x
		
		;save the raycast hit
		mov eax, dword[ebp+24]
		mov dword[eax+48], COLLISION_NEG_X
		mov ecx, dword[ebp+8]
		mov dword[eax+56], ecx
		
		jmp _raycast_done
	_raycast_not_pos_x:
	
	;neg y
		;point on plane
		mov eax, dword[ebp-16]
		mov dword[ebp-56], eax
		mov eax, dword[ebp-12]
		mov dword[ebp-52], eax
		mov eax, dword[ebp-8]
		mov dword[ebp-48], eax
		
		lea eax, [ebp-16]
		lea ecx, [ebp-32]
		lea edx, [ebp-56]
		push dword[ebp+20]
		push dword[ebp+24]
		push 0
		push edx
		push ecx
		push eax
		lea edx, [ebp-44]
		push edx
		push COLLIDER_NEG_Y_NORMAL
		push dword[ebp+12]
		call raycastHelper
		add esp, 36
		cmp eax, 0
		je _raycast_not_neg_y
		
		;save the raycast hit
		mov eax, dword[ebp+24]
		mov dword[eax+48], COLLISION_POS_Y
		mov ecx, dword[ebp+8]
		mov dword[eax+56], ecx
		
		jmp _raycast_done
	_raycast_not_neg_y:
	
	;pos y
		;point on plane
		mov eax, dword[ebp-16]
		mov dword[ebp-56], eax
		mov eax, dword[ebp-28]
		mov dword[ebp-52], eax
		mov eax, dword[ebp-8]
		mov dword[ebp-48], eax
		
		lea eax, [ebp-16]
		lea ecx, [ebp-32]
		lea edx, [ebp-56]
		push dword[ebp+20]
		push dword[ebp+24]
		push 0
		push edx
		push ecx
		push eax
		lea edx, [ebp-44]
		push edx
		push COLLIDER_POS_Y_NORMAL
		push dword[ebp+12]
		call raycastHelper
		add esp, 36
		cmp eax, 0
		je _raycast_not_pos_y
		
		;save the raycast hit
		mov eax, dword[ebp+24]
		mov dword[eax+48], COLLISION_NEG_Y
		mov ecx, dword[ebp+8]
		mov dword[eax+56], ecx
		
		jmp _raycast_done
	_raycast_not_pos_y:
	
	;neg z
		;point on plane
		mov eax, dword[ebp-16]
		mov dword[ebp-56], eax
		mov eax, dword[ebp-12]
		mov dword[ebp-52], eax
		mov eax, dword[ebp-8]
		mov dword[ebp-48], eax
		
		lea eax, [ebp-16]
		lea ecx, [ebp-32]
		lea edx, [ebp-56]
		push dword[ebp+20]
		push dword[ebp+24]
		push 0
		push edx
		push ecx
		push eax
		lea edx, [ebp-44]
		push edx
		push COLLIDER_NEG_Z_NORMAL
		push dword[ebp+12]
		call raycastHelper
		add esp, 36
		cmp eax, 0
		je _raycast_not_neg_z
		
		;save the raycast hit
		mov eax, dword[ebp+24]
		mov dword[eax+48], COLLISION_POS_Z
		mov ecx, dword[ebp+8]
		mov dword[eax+56], ecx
		
		jmp _raycast_done
	_raycast_not_neg_z:
	
	;pos z
		;point on plane
		mov eax, dword[ebp-16]
		mov dword[ebp-56], eax
		mov eax, dword[ebp-12]
		mov dword[ebp-52], eax
		mov eax, dword[ebp-24]
		mov dword[ebp-48], eax
		
		lea eax, [ebp-16]
		lea ecx, [ebp-32]
		lea edx, [ebp-56]
		push dword[ebp+20]
		push dword[ebp+24]
		push 0
		push edx
		push ecx
		push eax
		lea edx, [ebp-44]
		push edx
		push COLLIDER_POS_Z_NORMAL
		push dword[ebp+12]
		call raycastHelper
		add esp, 36
		cmp eax, 0
		je _raycast_not_pos_z
		
		;save the raycast hit
		mov eax, dword[ebp+24]
		mov dword[eax+48], COLLISION_NEG_Z
		mov ecx, dword[ebp+8]
		mov dword[eax+56], ecx
		
		jmp _raycast_done
	_raycast_not_pos_z:
	
	_raycast_no_hit:
	;set the result buffer's values
	mov eax, dword[ebp+24]
	mov dword[eax+48], 0
	mov dword[eax+56], 0
	
	_raycast_done:
	mov esp, ebp
	pop ebp
	ret
	
;int raycastHelper(
;	vec3* position,	
;	vec3* normalVector,
;	vec3* normalizedDirection,
;	vec3* lowerbound,
;	vec3* upperBound,
;	vec3* pointOnPlane
;	int fixAxis	//0: x, 1: y, 2: z
;	collider* resultBuffer		//only sets the position in the result buffer
;	float distance
;	)
;returns 0 if no hit
raycastHelper:	
	push ebp
	mov ebp, esp
	
	sub esp, 4		;<dir;normal>
	sub esp, 4		;<PoP-pos;normal>
	sub esp, 4		;t=<PoP-pos;normal>/<dir;normal>
	sub esp, 12		;intersection point
	
	;check if the ray gives backshots to the plane (and calculate <dir;normal> )
	push dword[ebp+16]
	push dword[ebp+12]
	call vec3_dot
	fstp dword[ebp-4]
	mov eax, dword[ebp-4]
	add esp, 8
	and eax, 0x80000000
	cmp eax, 0
	je _raycastHelper_no_hit
	
	;calculate <PoP-pos; normal>
	sub esp, 12
	mov eax, esp
	push dword[ebp+8]
	push dword[ebp+28]
	push eax
	call vec3_sub
	mov eax, dword[ebp+12]
	mov dword[esp+4], eax
	call vec3_dot
	fstp dword[ebp-8]
	add esp, 24
	
	;calculate t and check if it is in [0, distance]
	movss xmm0, dword[ebp-8]
	movss xmm1, dword[ebp-4]
	divss xmm0, xmm1
	movss dword[ebp-12], xmm0
	mov eax, dword[ebp-12]
	and eax, 0x80000000		;is t negative
	cmp eax, 0
	jne _raycastHelper_no_hit
	movss xmm0, dword[ebp-12]
	ucomiss xmm0, dword[ebp+40]
	ja _raycastHelper_no_hit

	
	;calculate intersection point
	lea eax,[ebp-24]
	push dword[ebp-12]
	push dword[ebp+16]
	push eax
	call vec3_scale
	mov eax, dword[ebp+8]
	mov dword[esp+8], eax
	lea eax, [ebp-24]
	mov dword[esp+4], eax
	call vec3_add
	add esp, 12
	
	
	;check if legit
	mov eax, dword[ebp+20]		;lower bound in eax
	mov ecx, dword[ebp+24]		;upper bound in ecx
	mov edx, dword[ebp+32]		;fix axis in edx
	
	cmp edx, 0
	je _raycastHelper_skip_x_axis_check
		movss xmm0, dword[ebp-24]
		ucomiss xmm0, dword[eax]
		jb _raycastHelper_no_hit
		ucomiss xmm0, dword[ecx]
		ja _raycastHelper_no_hit
	_raycastHelper_skip_x_axis_check:
	
	cmp edx, 1
	je _raycastHelper_skip_y_axis_check
		movss xmm0, dword[ebp-20]
		ucomiss xmm0, dword[eax+4]
		jb _raycastHelper_no_hit
		ucomiss xmm0, dword[ecx+4]
		ja _raycastHelper_no_hit
	_raycastHelper_skip_y_axis_check:
	
	cmp edx, 2
	je _raycastHelper_skip_z_axis_check
		movss xmm0, dword[ebp-16]
		ucomiss xmm0, dword[eax+8]
		jb _raycastHelper_no_hit
		ucomiss xmm0, dword[ecx+8]
		ja _raycastHelper_no_hit
	_raycastHelper_skip_z_axis_check:
	
	
	;copy the hit point into the result buffer
	mov eax, dword[ebp+36]		;result buffer in eax
	mov ecx, dword[ebp-24]
	mov dword[eax+24], ecx
	mov ecx, dword[ebp-20]
	mov dword[eax+28], ecx
	mov ecx, dword[ebp-16]
	mov dword[eax+32], ecx
	
	mov eax, 69
	
	jmp _raycastHelper_done
	_raycastHelper_no_hit:
		xor eax, eax
	_raycastHelper_done:
	mov esp, ebp
	pop ebp
	ret
