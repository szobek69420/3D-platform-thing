;layout
;struct player{
;	Camera* cum;
;	Collider* collider;
;}

section .rodata
	init_error_message db "Player couldn't be created lol",10,0
	
	raycast_hit_message db "raycast hit",10,0
	
	HORIZONTAL_LOOK_SENSITIVITY dd 120.0
	VERTICAL_LOOK_SENSITIVITY dd 120.0
	MOVEMENT_SPEED dd 15.0
	
	WORLD_UP dd 0.0, 1.0, 0.0
	WORLD_DOWN dd 0.0, -1.0, 0.0
	
	DEFAULT_POSITION dd 0.0, 35.0, 10.0
	
	COLLIDER_LOWER_BOUND dd -0.15, -1.5, -0.15
	COLLIDER_UPPER_BOUND dd 0.15, 1.5, 0.15
	
	ZERO dd 0.0
	ONE dd 1.0
	
	REACH dd 4.0
	
	NORMAL_FOV dd 60.0
	ZOOMED_FOV dd 10.0
	ZOOM_SPEED dd 0.1
	
	GRAVITY dd -30.0
	JUMP_STRENGTH dd 20.0
	
	RAYCAST_KNOB_UNUSED_POSITION dd 0.0, 1000000.0, 0.0

section .text
	extern printf
	extern malloc
	extern free
	extern memcpy
	extern input_isKeyHeld
	extern camera_forward
	extern camera_right
	extern vec3_print
	extern vec3_scale
	extern vec3_add
	extern vec3_normalize
	
	extern math_basedLerp

	extern collider_createCollider
	extern collider_destroyCollider
	
	extern physics_staticRaycast
	
	extern KEY_W
	extern KEY_A
	extern KEY_S
	extern KEY_D
	extern KEY_C
	extern KEY_SPACE
	extern KEY_SHIFT
	extern KEY_LEFT
	extern KEY_RIGHT
	extern KEY_UP
	extern KEY_DOWN
	
	extern COLLISION_NEG_Y
	
	extern raycast_knob
	
	global player_init		;player* player_init(Camera* cum)
	global player_destroy		;void player_destroy()
	
	global player_update		;void player_update(player* player, float deltaTimeInSex)
	
player_init:
	push ebp
	mov ebp, esp
	
	sub esp, 4		;player
	
	push 8
	call malloc
	mov dword[ebp-4], eax
	add esp, 4
	cmp eax, 0
	jne _init_no_error
	
	push init_error_message
	call printf
	mov eax, 0
	mov esp, ebp
	pop ebp
	ret
	
_init_no_error:
	;save camera
	mov eax, dword[ebp-4]
	mov ecx, dword[ebp+8]
	mov dword[eax], ecx		;save cum
	
	;make collider
	push COLLIDER_UPPER_BOUND
	push COLLIDER_LOWER_BOUND
	call collider_createCollider
	add esp, 8
	mov ecx, eax
	
	mov eax, dword[ebp-4]
	mov dword[eax+4], ecx		;save collider
	
	;set position
	mov eax, dword[ebp-4]
	mov eax, dword[eax+4]
	lea eax, [eax+24]
	push 12
	push DEFAULT_POSITION
	push eax
	call memcpy
	add esp, 12
	
	
	mov eax, dword[ebp-4]
	
	mov esp, ebp
	pop ebp
	ret
	
	
	
player_destroy:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	push dword[eax+4]
	call collider_destroyCollider
	add esp, 4
	
	push dword[ebp+8]
	call free
	
	mov esp, ebp
	pop ebp
	ret
	

player_update:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	mov ecx, dword[eax]		;camera in ecx
	mov edx, dword[eax+4]
	add edx, 24			;&(collider->position) in edx
	push 12
	push edx
	push ecx
	call memcpy
	add esp, 12
	
	
	push dword[ebp+12]
	push dword[ebp+8]
	call movePlayer
	add esp, 8
	
	push dword[ebp+12]
	push dword[ebp+8]
	call rotatePlayer
	add esp, 8
	
	
	push dword[ebp+12]
	push dword[ebp+8]
	call zoomCamera
	add esp, 8	
	
	push dword[ebp+8]
	call gaycast
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret
	
	
movePlayer:			;void movePlayer(player* player, float deltaTimeInSec)
	push ebp
	push ebx
	mov ebp, esp
	
	sub esp, 12			;forward
	sub esp, 12			;right
	
	mov ebx, dword[ebp+12]
	mov ebx, dword[ebx]			;cum in eax
	
	;set (horizontal) velocity to zero
	mov eax, dword[ebp+12]
	mov eax, dword[eax+4]
	mov dword[eax+36], 0
	;mov dword[eax+40], 0
	mov dword[eax+44], 0
	
	;apply gravity
	movss xmm0, dword[ebp+16]
	mulss xmm0, dword[GRAVITY]
	movss xmm1, dword[eax+40]
	addss xmm1, xmm0
	movss dword[eax+40], xmm1
	
	;calculate forward and right
	lea eax, [ebp-12]
	push eax
	push ebx
	call camera_forward
	sub dword[esp+4], 12
	call camera_right
	add esp, 8
	
	mov dword[ebp-8], 0		;make the forward vector flat
	lea eax, [ebp-12]
	push eax
	call vec3_normalize
	add esp, 4
	
	
	
	push KEY_W
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _movePlayer_no_forward
	lea eax, [ebp-12]
	push dword[MOVEMENT_SPEED]
	push eax
	push dword[ebp+12]
	call movePlayerHelper
	add esp, 12
_movePlayer_no_forward:

	push KEY_S
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _movePlayer_no_backward
	
	xor dword[ebp-12], 0x80000000
	xor dword[ebp-8], 0x80000000
	xor dword[ebp-4], 0x80000000
	
	lea eax, [ebp-12]
	push dword[MOVEMENT_SPEED]
	push eax
	push dword[ebp+12]
	call movePlayerHelper
	add esp, 12
_movePlayer_no_backward:

	push KEY_D
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _movePlayer_no_right
	
	lea eax, [ebp-24]
	push dword[MOVEMENT_SPEED]
	push eax
	push dword[ebp+12]
	call movePlayerHelper
	add esp, 12
_movePlayer_no_right:

	push KEY_A
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _movePlayer_no_left
	
	xor dword[ebp-24], 0x80000000
	xor dword[ebp-20], 0x80000000
	xor dword[ebp-16], 0x80000000
	
	lea eax, [ebp-24]
	push dword[MOVEMENT_SPEED]
	push eax
	push dword[ebp+12]
	call movePlayerHelper
	add esp, 12
_movePlayer_no_left:

	;jump
	push KEY_SPACE
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _movePlayer_no_up
	
	mov eax, dword[ebp+12]
	mov eax, dword[eax+4]
	mov edx, dword[eax+48]
	and edx, COLLISION_NEG_Y
	cmp edx, 0
	je _movePlayer_no_up
	
	mov edx, dword[JUMP_STRENGTH]
	mov dword[eax+40], edx
_movePlayer_no_up:

	
	mov esp, ebp
	pop ebx
	pop ebp
	ret
	
	
	

movePlayerHelper:		;void movePlayerHelper(player* player, vec3* direction, float velocity)
	push ebp
	mov ebp, esp
	
	sub esp, 12		;scaled velocity
	
	
	push dword[ebp+16]
	push dword[ebp+12]
	lea eax, [ebp-12]
	push eax
	call vec3_scale
	add esp, 12
	
	mov eax, dword[ebp+8]
	mov eax, dword[eax+4]
	add eax, 36		;&(player->collider->velocity) in eax
	mov ecx, esp
	push ecx
	push eax
	push eax
	call vec3_add
	
	mov esp, ebp
	pop ebp
	ret
	
	
rotatePlayer:			;void rotatePlayer(player* player, float deltaTimeInSec)
	push ebp
	mov ebp, esp
	
	;horizontal look
	movss xmm0, dword[ebp+12]
	movss xmm1, dword[HORIZONTAL_LOOK_SENSITIVITY]
	mulss xmm0, xmm1		;hrotation strength in xmm0
	
	movss xmm1, dword[ZERO]
	movss xmm2, dword[ONE]
	
	push KEY_LEFT
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _rotatePlayer_no_left
	subss xmm1, xmm2
_rotatePlayer_no_left:

	push KEY_RIGHT
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _rotatePlayer_no_right
	addss xmm1, xmm2
_rotatePlayer_no_right:
	
	mov eax, dword[ebp+8]
	mov eax, dword[eax]		;&camera in eax
	mulss xmm0, xmm1
	movss xmm1, dword[eax+16]
	addss xmm1, xmm0
	movss dword[eax+16], xmm1
	
	
	;vertical look
	movss xmm0, dword[ebp+12]
	movss xmm1, dword[VERTICAL_LOOK_SENSITIVITY]
	mulss xmm0, xmm1		;vrotation strength in xmm0
	
	movss xmm1, dword[ZERO]
	movss xmm2, dword[ONE]
	
	push KEY_UP
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _rotatePlayer_no_up
	addss xmm1, xmm2
_rotatePlayer_no_up:

	push KEY_DOWN
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _rotatePlayer_no_down
	subss xmm1, xmm2
_rotatePlayer_no_down:
	
	mov eax, dword[ebp+8]
	mov eax, dword[eax]		;&camera in eax
	mulss xmm0, xmm1
	movss xmm1, dword[eax+12]
	addss xmm1, xmm0
	movss dword[eax+12], xmm1
	
	
	mov esp, ebp
	pop ebp
	ret
	
	
zoomCamera:			;void zoomCamera(player* player, float deltaTimeInSec)
	push ebp
	mov ebp, esp
	
	push dword[ebp+12]
	push dword[ZOOM_SPEED]
	
	push KEY_C
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _zoom_not_in_zoom
	jmp _zoom_in_zoom
		_zoom_not_in_zoom:
		push dword[NORMAL_FOV]
		mov eax, dword[ebp+8]
		mov eax, dword[eax]
		push dword[eax+28]		;current fov
		jmp _zoom_switch_done
		
		_zoom_in_zoom:
		push dword[ZOOMED_FOV]
		mov eax, dword[ebp+8]
		mov eax, dword[eax]
		push dword[eax+28]		;current fov
		jmp _zoom_switch_done
	_zoom_switch_done:
	
	call math_basedLerp
	add esp, 16
	
	mov eax, dword[ebp+8]
	mov eax, dword[eax]
	fstp dword[eax+28]
	
	mov esp, ebp
	pop ebp
	ret
	
	
gaycast:	;void gaycast(player* player)
	push ebp
	mov ebp, esp
	
	sub esp, 12		;look direction
	sub esp, 4		;raycast result
	
	mov eax, dword[ebp+8]
	lea ecx, [ebp-12]
	push ecx
	push dword[eax]
	call camera_forward
	add esp, 8
	
	mov eax, dword[ebp+8]
	lea ecx, [ebp-12]
	push dword[REACH]
	push ecx
	push dword[eax]
	call physics_staticRaycast
	mov dword[ebp-16], eax
	add esp, 12
	
	cmp eax, 0
	je _gaycast_no_hit
	
	_gaycast_hit:
		;move raycast knob
		mov eax, raycast_knob
		add eax, 48
		mov ecx, dword[ebp-16]
		add ecx, 24
		push 12
		push ecx
		push eax
		call memcpy
		add esp, 12
		
		;destroy the returned collider
		push dword[ebp-16]
		call collider_destroyCollider
		add esp, 4
		
		jmp _gaycast_done
		
	_gaycast_no_hit:
		;move raycast knob
		mov eax, raycast_knob
		add eax, 48
		push 12
		push RAYCAST_KNOB_UNUSED_POSITION
		push eax
		call memcpy
		add esp, 12
	
	_gaycast_done:
	mov esp, ebp
	pop ebp
	ret
