;layout
;struct player{
;	Camera* cum;
;	Collider* collider;
;	chomkManager* cm;
;	int selectedInventorySlot;
;	Renderable* heldBlock;
;	Renderable* raycastKnob;
;}

INVENTORY_SLOT_COUNT equ 5
INVENTORY_SLOT_SIZE equ 60

section .rodata
	init_error_message db "Player couldn't be created lol",10,0
	
	raycast_hit_message db "raycast hit",10,0
	
	print_block_info db "chomkX: %d, chomkZ: %d, blockX: %d, blockY: %d, blockZ: %d",10,0
	print_four_ints_format db "%d %d %d %d",10,0
	
	status_text_1_format db "PLAYER POS: %.1f, %.1f, %.1f",0 
	status_text_2_format db "VIEW DIR: %.1f, %.1f",0
	status_text_3_format db "LOADED CHOMKS: %d",0
	
	status_text_5_format db "HELD BLOCK:",10
	
	
	HORIZONTAL_LOOK_SENSITIVITY dd 120.0
	VERTICAL_LOOK_SENSITIVITY dd 120.0
	MOVEMENT_SPEED dd 15.0
	
	WORLD_UP dd 0.0, 1.0, 0.0
	WORLD_DOWN dd 0.0, -1.0, 0.0
	
	DEFAULT_POSITION dd 0.0, 35.0, 10.0
	
	COLLIDER_LOWER_BOUND dd -0.3, -1.7, -0.3
	COLLIDER_UPPER_BOUND dd 0.3, 0.1, 0.3
	
	ZERO dd 0.0
	ONE dd 1.0
	HALF dd 0.5
	MINUS_HALF dd -0.5
	FIFTY dd 50.0
	
	MAX_PITCH dd 89.5
	MIN_PITCH dd -89.5
	
	REACH dd 4.0
	
	NORMAL_FOV dd 60.0
	ZOOMED_FOV dd 10.0
	ZOOM_SPEED dd 0.1
	
	GRAVITY dd -30.0
	JUMP_STRENGTH dd 20.0
	
	RAYCAST_KNOB_UNUSED_POSITION dd 0.0, 1000000.0, 0.0
	
	INVENTORY dd BLOCK_CHERRY_LOG, BLOCK_CHERRY_LEAVES, BLOCK_STONE, BLOCK_SUS, BLOCK_SUS2
	
	HELD_BLOCK_POS dd 0.2, -0.2, -0.2
	HELD_BLOCK_SCALE dd 0.1
	HELD_BLOCK_Y_ROT dd 15.0
	
	RAYCAST_KNOB_SCALE dd 0.1

section .text
	extern printf
	extern malloc
	extern free
	extern memcpy
	extern sprintf
	
	extern input_isKeyHeld
	extern input_isKeyPressed
	extern camera_forward
	extern camera_right
	extern camera_projection
	extern vec3_print
	extern vec3_scale
	extern vec3_add
	extern vec3_normalize
	
	extern math_basedLerp

	extern collider_createCollider
	extern collider_destroyCollider
	
	extern physics_staticRaycast
	
	extern vector_push_back
	
	extern renderable_createKuba
	extern renderable_destroy
	extern renderable_render
	
	extern KEY_1
	extern KEY_2
	extern KEY_3
	extern KEY_4
	extern KEY_5
	extern KEY_W
	extern KEY_A
	extern KEY_S
	extern KEY_D
	extern KEY_C
	extern KEY_Q
	extern KEY_E
	extern KEY_R
	extern KEY_SPACE
	extern KEY_SHIFT
	extern KEY_LEFT
	extern KEY_RIGHT
	extern KEY_UP
	extern KEY_DOWN
	
	extern textRenderer_renderText
	extern textRenderer_setColour
	extern textRenderer_getTextWidth
	extern TEXT_ALIGN_TOP_LEFT
	extern TEXT_ALIGN_TOP_CENTER
	extern TEXT_ALIGN_TOP_RIGHT
	extern TEXT_ALIGN_CENTER_LEFT
	extern TEXT_ALIGN_CENTER_CENTER
	extern TEXT_ALIGN_CENTER_RIGHT
	extern TEXT_ALIGN_BOTTOM_LEFT
	extern TEXT_ALIGN_BOTTOM_CENTER
	extern TEXT_ALIGN_BOTTOM_RIGHT
	
	extern COLLISION_POS_X
	extern COLLISION_NEG_X
	extern COLLISION_POS_Y
	extern COLLISION_NEG_Y
	extern COLLISION_POS_Z
	extern COLLISION_NEG_Z
	
	extern BLOCK_COLLIDER
	extern BLOCK_COLOUR_INDEX
	extern BLOCK_NAME_INDEX
	extern BLOCK_AIR
	extern BLOCK_GRASS
	extern BLOCK_DIRT
	extern BLOCK_STONE
	extern BLOCK_CHERRY_LOG
	extern BLOCK_CHERRY_LEAVES
	extern BLOCK_SUS
	extern BLOCK_SUS2
	
	global player_init		;player* player_init(Camera* cum, chomkManager* cm)
	global player_destroy		;void player_destroy(player* player)
	
	global player_update		;void player_update(player* player, float deltaTimeInSex)
	global player_render		;void player_render(player* player, ScreenInfo* window, mat4* pv, camera* cum)
	global player_printUI		;void player_printUI(player* player, ScreenInfo* window)
	
player_init:
	push ebp
	mov ebp, esp
	
	sub esp, 4		;player
	
	push 24
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
	
	;save chomk manager
	mov eax, dword[ebp-4]
	mov ecx, dword[ebp+12]
	mov dword[eax+8], ecx	
	
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
	
	;set selected inventory slot
	mov eax, dword[ebp-4]
	mov dword[eax+12], 0
	
	;alloc held block renderable and initialize it
	push 84
	call malloc
	add esp, 4
	mov ecx, dword[ebp-4]
	mov dword[ecx+16], eax
	push eax
	call renderable_createKuba
	pop eax
	
	mov ecx, dword[HELD_BLOCK_POS]
	mov dword[eax+48], ecx
	mov ecx, dword[HELD_BLOCK_POS+4]
	mov dword[eax+52], ecx
	mov ecx, dword[HELD_BLOCK_POS+8]
	mov dword[eax+56], ecx
	
	mov ecx, dword[HELD_BLOCK_Y_ROT]
	mov dword[eax+64], ecx
	
	mov ecx, dword[HELD_BLOCK_SCALE]
	mov dword[eax+72], ecx
	mov dword[eax+76], ecx
	mov dword[eax+80], ecx
	
	push dword[ebp-4]
	call recalculateHeldBlockRenderable
	add esp, 4

	
	;create raycast knob
	push 84
	call malloc
	add esp, 4
	
	mov ecx, dword[ebp-4]
	mov dword[ecx+20], eax
	push eax
	call renderable_createKuba
	pop eax
	
	mov ecx, dword[RAYCAST_KNOB_SCALE]
	mov dword[eax+72], ecx
	mov dword[eax+76], ecx
	mov dword[eax+80], ecx
	
	
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
	
	mov eax, dword[ebp+8]
	push dword[eax+16]
	call renderable_destroy
	call free
	add esp, 4
	
	mov eax, dword[ebp+8]
	push dword[eax+20]
	call renderable_destroy
	call free
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
	call changeInventorySlot
	add esp, 4
	
	push dword[ebp+8]
	call gaycast
	add esp, 4
	
	;respawn
	push KEY_R
	call input_isKeyPressed
	add esp, 4
	test eax, eax
	je _update_no_respawn
		mov eax, dword[ebp+8]
		mov eax, dword[eax+4]
		mov ecx, dword[FIFTY]
		mov dword[eax+24], 0
		mov dword[eax+28], ecx
		mov dword[eax+32], 0
		mov dword[eax+36], 0
		mov dword[eax+40], 0
		mov dword[eax+44], 0
	_update_no_respawn:
	
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
	
	ucomiss xmm1, dword[MAX_PITCH]
	jbe _rotatePlayer_not_max
		movss xmm1, dword[MAX_PITCH]
	_rotatePlayer_not_max:
	
	ucomiss xmm1, dword[MIN_PITCH]
	jae _rotatePlayer_not_min
		movss xmm1, dword[MIN_PITCH]
	_rotatePlayer_not_min:
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
	sub esp, 12		;block position
	sub esp, 8		;chomk position
	sub esp, 4		;changed block type
	push 0			;change type	(0: no change, 1: break, -1: place)
	
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
		mov eax, dword[ebp+8]
		mov eax, dword[eax+20]
		add eax, 48
		mov ecx, dword[ebp-16]
		add ecx, 24
		push 12
		push ecx
		push eax
		call memcpy
		add esp, 12
		
		;check if block is broken
		push KEY_Q
		call input_isKeyPressed
		add esp, 4
		cmp eax, 0
		je _gaycast_no_block_break
		
		mov eax, dword[ebp-16]		;raycast result in eax
		mov ecx, dword[eax+56]
		mov ecx, dword[ecx+52]
		cmp ecx, BLOCK_COLLIDER
		jne _gaycast_no_block_break
			mov dword[ebp-40], BLOCK_AIR
			mov dword[ebp-44], 1
			jmp _gaycast_no_block_place
		_gaycast_no_block_break:
		
		;check if block is placed
		push KEY_E
		call input_isKeyPressed
		add esp, 4
		cmp eax, 0
		je _gaycast_no_block_place
		
		mov eax, dword[ebp-16]		;raycast result in eax
		mov ecx, dword[eax+56]
		mov ecx, dword[ecx+52]
		cmp ecx, BLOCK_COLLIDER
		jne _gaycast_no_block_place
			mov eax, dword[ebp+8]
			mov eax, dword[eax+12]
			mov eax, dword[4*eax+INVENTORY]
			mov dword[ebp-40], eax
			mov dword[ebp-44], -1
		_gaycast_no_block_place:
		
		;check if something happened
		mov eax, dword[ebp-44]
		cmp eax, 0
		je _gaycast_nothing_changed
		
		
		;calculate block position
		mov eax, dword[ebp-16]
		mov ecx, dword[eax+24]
		mov dword[ebp-28], ecx
		mov ecx, dword[eax+28]
		mov dword[ebp-24], ecx
		mov ecx, dword[eax+32]
		mov dword[ebp-20], ecx
		
		mov eax, dword[eax+48]
		
		movss xmm1, dword[HALF]
		mov ecx, dword[ebp-44]
		cmp ecx, 1
		je _gaycast_block_break_position_calculator
			movss xmm1, dword[MINUS_HALF]
		_gaycast_block_break_position_calculator:
		
		mov ecx, eax
		and ecx, COLLISION_NEG_X
		cmp ecx, 0
		jne _gaycast_neg_x
		mov ecx, eax
		and ecx, COLLISION_POS_X
		cmp ecx, 0
		jne _gaycast_pos_x
		mov ecx, eax
		and ecx, COLLISION_NEG_Y
		cmp ecx, 0
		jne _gaycast_neg_y
		mov ecx, eax
		and ecx, COLLISION_POS_Y
		cmp ecx, 0
		jne _gaycast_pos_y
		mov ecx, eax
		and ecx, COLLISION_NEG_Z
		cmp ecx, 0
		jne _gaycast_neg_z
		mov ecx, eax
		and ecx, COLLISION_POS_Z
		cmp ecx, 0
		jne _gaycast_pos_z
		jmp _gaycast_block_pos_calc_done
		_gaycast_neg_x:
			movss xmm0, dword[ebp-28]
			subss xmm0, xmm1
			movss dword[ebp-28], xmm0
			jmp _gaycast_block_pos_calc_done
		_gaycast_pos_x:
			movss xmm0, dword[ebp-28]
			addss xmm0, xmm1
			movss dword[ebp-28], xmm0
			jmp _gaycast_block_pos_calc_done
		_gaycast_neg_y:
			movss xmm0, dword[ebp-24]
			subss xmm0, xmm1
			movss dword[ebp-24], xmm0
			jmp _gaycast_block_pos_calc_done
		_gaycast_pos_y:
			movss xmm0, dword[ebp-24]
			addss xmm0, xmm1
			movss dword[ebp-24], xmm0
			jmp _gaycast_block_pos_calc_done
		_gaycast_neg_z:
			movss xmm0, dword[ebp-20]
			subss xmm0, xmm1
			movss dword[ebp-20], xmm0
			jmp _gaycast_block_pos_calc_done
		_gaycast_pos_z:
			movss xmm0, dword[ebp-20]
			addss xmm0, xmm1
			movss dword[ebp-20], xmm0
			jmp _gaycast_block_pos_calc_done
		_gaycast_block_pos_calc_done:
		
		;convert block pos to int
		fld dword[ebp-28]
		fistp dword[ebp-28]
		fld dword[ebp-24]
		fistp dword[ebp-24]
		fld dword[ebp-20]
		fistp dword[ebp-20]
		
		;block x and chomk x
		mov eax, dword[ebp-28]
		sar eax, 4
		mov dword[ebp-36], eax
		mov eax, dword[ebp-28]
		and eax, 0x000000F
		mov dword[ebp-28], eax
		
		;block z and chomk z
		mov eax, dword[ebp-20]
		sar eax, 4
		mov dword[ebp-32], eax
		mov eax, dword[ebp-20]
		and eax, 0x000000F
		mov dword[ebp-20], eax
		
		;add changed block to the registry
		mov edx, dword[ebp+8]
		mov edx, dword[edx+8]		;cm in edx
		sub esp, 4
		mov eax, dword[ebp-40]
		mov byte[esp+3], al
		mov cl, byte[ebp-20]
		mov byte[esp+2], cl
		mov cl, byte[ebp-24]
		mov byte[esp+1], cl
		mov cl, byte[ebp-28]
		mov byte[esp], cl
		push dword[ebp-32]
		push dword[ebp-36]
		lea ecx, [edx+16]
		push ecx
		call vector_push_back
		add esp, 16
			
		;create a pendig chunk update
		mov edx, dword[ebp+8]
		mov edx, dword[edx+8]
		add edx, 32
			
		push dword[ebp-32]
		push dword[ebp-36]
		push edx
		call vector_push_back
		add esp, 12
			
		;check if neighbours also need to be reloaded
		mov edx, dword[ebp+8]
		mov edx, dword[edx+8]
		add edx, 32
		push edx
			
		mov edx, dword[esp]
		mov eax, dword[ebp-28]
		cmp eax, 0
		jne _gaycast_no_neighbour_neg_x
			push dword[ebp-32]
			push dword[ebp-36]
			dec dword[esp]
			push edx
			call vector_push_back
			add esp, 12
		_gaycast_no_neighbour_neg_x:
		
		mov edx, dword[esp]
		mov eax, dword[ebp-28]
		cmp eax, 15
		jne _gaycast_no_neighbour_pos_x
			push dword[ebp-32]
			push dword[ebp-36]
			inc dword[esp]
			push edx
			call vector_push_back
			add esp, 12
		_gaycast_no_neighbour_pos_x:
			
		mov edx, dword[esp]
		mov eax, dword[ebp-20]
		cmp eax, 0
		jne _gaycast_no_neighbour_neg_z
			push dword[ebp-32]
			dec dword[esp]
			push dword[ebp-36]
			push edx
			call vector_push_back
			add esp, 12
		_gaycast_no_neighbour_neg_z:
			
		mov edx, dword[esp]
		mov eax, dword[ebp-20]
		cmp eax, 15
		jne _gaycast_no_neighbour_pos_z
			push dword[ebp-32]
			inc dword[esp]
			push dword[ebp-36]
			push edx
			call vector_push_back
			add esp, 12
		_gaycast_no_neighbour_pos_z:
			
		add esp, 4
		
		_gaycast_nothing_changed:
		
		;destroy the returned collider
		push dword[ebp-16]
		call collider_destroyCollider
		add esp, 4
		
		jmp _gaycast_done
		
	_gaycast_no_hit:
		;move raycast knob
		mov eax, dword[ebp+8]
		mov eax, dword[eax+20]
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
	
changeInventorySlot:		;void changeInventorySlot(player* player)
	push ebp
	mov ebp, esp
	
	push KEY_1
	call input_isKeyPressed
	add esp, 4
	test eax, eax
	je _not_slot_1
		mov edx, dword[ebp+8]
		mov dword[edx+12], 0
		jmp _block_changed
	_not_slot_1:
	
	push KEY_2
	call input_isKeyPressed
	add esp, 4
	test eax, eax
	je _not_slot_2
		mov edx, dword[ebp+8]
		mov dword[edx+12], 1
		jmp _block_changed
	_not_slot_2:
	
	push KEY_3
	call input_isKeyPressed
	add esp, 4
	test eax, eax
	je _not_slot_3
		mov edx, dword[ebp+8]
		mov dword[edx+12], 2
		jmp _block_changed
	_not_slot_3:
	
	push KEY_4
	call input_isKeyPressed
	add esp, 4
	test eax, eax
	je _not_slot_4
		mov edx, dword[ebp+8]
		mov dword[edx+12], 3
		jmp _block_changed
	_not_slot_4:
	
	push KEY_5
	call input_isKeyPressed
	add esp, 4
	test eax, eax
	je _not_slot_5
		mov edx, dword[ebp+8]
		mov dword[edx+12], 4
		jmp _block_changed
	_not_slot_5:
	
	push dword[ebp+8]
	call recalculateHeldBlockRenderable
	add esp, 4
	
	_block_changed:
	mov esp, ebp
	pop ebp
	ret
	
recalculateHeldBlockRenderable:		;void recalculateHeldBlockRenderable(player* player)
	push ebp
	push ebx
	mov ebp, esp
	
	sub esp, 4		;renderable*
	sub esp, 4		;block colours
	sub esp, 4		;renderable colours
	
	mov eax, dword[ebp+12]
	mov eax, dword[eax+16]
	mov dword[ebp-4], eax
	
	mov eax, dword[ebp+12]
	mov eax, dword[eax+12]
	mov eax, dword[4*eax+INVENTORY]
	mov eax, dword[4*eax+BLOCK_COLOUR_INDEX]
	mov dword[ebp-8], eax
	
	mov eax, dword[ebp-4]
	mov eax, dword[eax+44]
	mov dword[ebp-12], eax
	
	mov eax, dword[ebp-8]
	mov ecx, dword[ebp-12]
	mov ebx, 6
	_recalculate_colours_loop_start:
		mov edx, dword[eax]
		mov dword[ecx], edx
		mov dword[ecx+4], edx
	
		add eax, 4
		add ecx, 8
		dec ebx
		test ebx, ebx
		jne _recalculate_colours_loop_start
	
	mov esp, ebp
	pop ebx
	pop ebp
	ret
	
player_render:
	push ebp
	mov ebp, esp
	
	sub esp, 64		;projection matrix
	
	lea eax, [ebp-64]
	push eax
	push dword[ebp+20]
	call camera_projection
	add esp, 8
	
	lea ecx, [ebp-64]
	mov eax, dword[ebp+8]
	push dword[ebp+20]
	push ecx
	push dword[ebp+12]
	push dword[eax+16]
	call renderable_render
	add esp, 16
	

	mov eax, dword[ebp+8]
	push dword[ebp+20]
	push dword[ebp+16]
	push dword[ebp+12]
	push dword[eax+20]
	call renderable_render
	add esp, 16
	
	mov esp, ebp
	pop ebp
	ret
	
	
player_printUI:
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	sub esp, 200		;char array
	mov eax, esp
	push eax		;address of the array
	
	
	push 0xFFFFFA00
	call textRenderer_setColour
	add esp, 4

	
	;show player position
	mov eax, dword[ebp+20]
	mov eax, dword[eax+4]		;collider
	sub esp, 24
	fld dword[eax+24]
	fstp qword[esp]
	fld dword[eax+28]
	fstp qword[esp+8]
	fld dword[eax+32]
	fstp qword[esp+16]
	push status_text_1_format
	push dword[ebp-204]
	call sprintf
	add esp, 32
	
	push TEXT_ALIGN_TOP_LEFT
	push 40
	push 15
	push dword[ebp+24]
	push dword[ebp-204]
	call textRenderer_renderText
	add esp, 20
	
	
	;show player view direction
	mov eax, dword[ebp+20]
	mov eax, dword[eax]		;camera
	sub esp, 16
	fld dword[eax+16]
	fstp qword[esp]
	fld dword[eax+12]
	fstp qword[esp+8]
	push status_text_2_format
	push dword[ebp-204]
	call sprintf
	add esp, 24
	
	push TEXT_ALIGN_TOP_LEFT
	push 65
	push 15
	push dword[ebp+24]
	push dword[ebp-204]
	call textRenderer_renderText
	add esp, 20
	
	
	;show loaded chomks
	mov eax, dword[ebp+20]
	mov eax, dword[eax+8]
	mov eax, dword[eax]		;chomk count
	push eax
	push status_text_3_format
	push dword[ebp-204]
	call sprintf
	add esp, 12
	
	push TEXT_ALIGN_TOP_LEFT
	push 90
	push 15
	push dword[ebp+24]
	push dword[ebp-204]
	call textRenderer_renderText
	add esp, 20
	
	;show held block
	push TEXT_ALIGN_BOTTOM_LEFT
	push 15
	push 15
	push dword[ebp+24]
	push status_text_5_format
	call textRenderer_renderText
	add esp, 20
	
	push status_text_5_format
	call textRenderer_getTextWidth
	mov edx, eax
	add edx, 15		;xpos in edx
	add esp, 4
	
	mov eax, dword[ebp+20]
	mov eax, dword[eax+12]
	mov eax, dword[4*eax+INVENTORY]
	mov ecx, dword[4*eax+BLOCK_COLOUR_INDEX]
	mov ecx, dword[ecx]				;block colour in ecx
	mov eax, dword[4*eax+BLOCK_NAME_INDEX]		;block name in eax
	
	push eax		;save eax
	push ecx
	call textRenderer_setColour
	add esp, 4
	pop eax			;restore eax
	
	push TEXT_ALIGN_BOTTOM_LEFT
	push 15
	push edx
	push dword[ebp+24]
	push eax
	call textRenderer_renderText
	add esp, 20
	
	push dword[ebp+24]
	push dword[ebp+20]
	call drawInventory
	add esp, 8
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
	
	
drawRectangle:		;void drawRectangle(ScreenInfo* window, int x, int y, int width, int height, int colour)
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	sub esp, 4		;corrected height
	sub esp, 4		;corrected width
	sub esp, 4		;corrected y
	sub esp, 4		;corrected x
	
	sub esp, 4		;screenbuffer
	sub esp, 4		;screen height
	sub esp, 4		;screen width
	
	;set screen data
	mov eax, dword[ebp+20]
	
	mov ecx, dword[eax+32]
	mov dword[ebp-20], ecx
	mov ecx, dword[eax+40]
	mov dword[ebp-28], ecx
	mov ecx, dword[eax+44]
	mov dword[ebp-24], ecx

	
	;correct x and width
	mov eax, dword[ebp+24]
	mov dword[ebp-16], eax
	mov ecx, dword[ebp+32]
	mov dword[ebp-8], ecx
	cmp eax, 0
	jge _x_pos_correction_done
		neg eax
		inc eax
		sub ecx, eax
		mov dword[ebp-8], ecx
		mov dword[ebp-16], 0
		cmp ecx, 0
		jl _drawRectangle_done
	_x_pos_correction_done:
	
	mov eax, dword[ebp-16]
	mov ecx, dword[ebp-8]
	add eax, ecx
	cmp eax, dword[ebp-28]
	jl _width_correction_done
		sub eax, dword[ebp-28]
		sub ecx, eax
		mov dword[ebp-8], ecx
	_width_correction_done:
	mov ecx, dword[ebp-8]
	cmp ecx, 0
	jle _drawRectangle_done
	
	;correct y and height
	mov eax, dword[ebp+28]
	mov dword[ebp-12], eax
	mov ecx, dword[ebp+36]
	mov dword[ebp-4], ecx
	cmp eax, 0
	jge _y_pos_correction_done
		neg eax
		inc eax
		sub ecx, eax
		mov dword[ebp-4], ecx
		mov dword[ebp-12], 0
		cmp ecx, 0
		jl _drawRectangle_done
	_y_pos_correction_done:
	
	mov eax, dword[ebp-12]
	mov ecx, dword[ebp-4]
	add eax, ecx
	cmp eax, dword[ebp-24]
	jl _height_correction_done
		sub eax, dword[ebp-24]
		sub ecx, eax
		mov dword[ebp-4], ecx
	_height_correction_done:
	mov ecx, dword[ebp-4]
	cmp ecx, 0
	jle _drawRectangle_done
	
	;draw rectangle
	mov ebx, dword[ebp-20]	;screen buffer in ebx
	mov edx, dword[ebp+40]	;colour in edx
	mov esi, dword[ebp-12]	;y pos in esi
	mov edi, dword[ebp-16]	;x pos in edi
	mov ecx, dword[ebp-4]
	_drawRectangle_draw_y_loop_start:
		push ecx
		mov eax, esi
		imul eax, dword[ebp-28]
		lea eax, [ebx+4*eax]
		lea eax, [eax+4*edi]		;current pixel in the buffer
		mov ecx, dword[ebp-8]
		_drawRectangle_draw_x_loop_start:
			mov dword[eax], edx
			
			add eax, 4
			dec ecx
			test ecx, ecx
			jne _drawRectangle_draw_x_loop_start
		
		pop ecx
		inc esi
		dec ecx
		test ecx, ecx
		jne _drawRectangle_draw_y_loop_start
	
	_drawRectangle_done:	
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret


drawInventory:		;void drawInventory(player* player, ScreenInfo* window)
	push ebp
	mov ebp, esp
	
	sub esp, 4		;current inventory slot pos y
	sub esp, 4		;current inventory slot pos x
	sub esp, 4		;chosen slot index
	
	mov eax, INVENTORY_SLOT_COUNT
	cmp eax, 0
	jle _drawInventory_done
	
	;obtain chosen slot
	mov eax, dword[ebp+8]
	mov eax, dword[eax+12]
	mov dword[ebp-12], eax
	
	;calc slot position
	mov eax, dword[ebp+12]
	
	mov ecx, dword[eax+40]
	shr ecx, 1
	mov edx, INVENTORY_SLOT_SIZE
	imul edx, INVENTORY_SLOT_COUNT
	shr edx, 1
	sub ecx, edx
	mov dword[ebp-8], ecx
	
	mov ecx, dword[eax+44]
	sub ecx, INVENTORY_SLOT_SIZE
	mov dword[ebp-4], ecx
	
	;draw the thing
	xor eax, eax
	_drawInventory_draw_loop_start:
		push eax		;save eax
	
		;draw slot frame
		mov edx, 0xFFAAAAAA
		cmp eax, dword[ebp-12]
		jne _drawInventory_not_this_slot
			mov edx, 0xFFFFFFFF
		_drawInventory_not_this_slot:
		push edx
		push INVENTORY_SLOT_SIZE
		push INVENTORY_SLOT_SIZE
		push dword[ebp-4]
		push dword[ebp-8]
		push dword[ebp+12]
		call drawRectangle
		add esp, 24
		
		;draw slot content
		mov edx, dword[esp]			;current slot
		mov edx, dword[INVENTORY+4*edx]
		mov edx, dword[4*edx+BLOCK_COLOUR_INDEX]
		mov edx, dword[edx]
		push edx
		
		mov ecx, INVENTORY_SLOT_SIZE
		sub ecx, 10
		push ecx
		push ecx
		
		mov ecx, dword[ebp-4]
		add ecx, 5
		push ecx
		
		mov ecx, dword[ebp-8]
		add ecx, 5
		push ecx
		
		push dword[ebp+12]
		call drawRectangle
		add esp, 24
		
		pop eax		;restore eax
		add dword[ebp-8], INVENTORY_SLOT_SIZE
		inc eax
		cmp eax, INVENTORY_SLOT_COUNT
		jl _drawInventory_draw_loop_start
	
	_drawInventory_done:
	mov esp, ebp
	pop ebp
	ret
