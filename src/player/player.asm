;layout
;struct player{
;	Camera* cum;
;}

section .rodata
	init_error_message db "Player couldn't be created lol",10,0
	
	HORIZONTAL_LOOK_SENSITIVITY dd 360.0
	VERTICAL_LOOK_SENSITIVITY dd 90.0
	MOVEMENT_SPEED dd 5.0
	

section .text
	extern printf
	extern malloc
	extern free
	extern input_isKeyHeld
	extern camera_forward
	extern camera_right
	
	extern KEY_W
	extern KEY_A
	extern KEY_S
	extern KEY_D
	extern KEY_LEFT
	extern KEY_RIGHT
	extern KEY_UP
	extern KEY_DOWN
	
	global player_init		;player* player_init(Camera* cum)
	global player_destroy		;void player_destroy()
	
	global player_update		;void player_update(player* player, float deltaTimeInSex)
	
player_init:
	push ebp
	mov ebp, esp
	
	push 4
	call malloc
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
	mov ecx, dword[ebp+8]
	mov dword[eax], ecx		;save cum
	
	mov esp, ebp
	pop ebp
	ret
	
	
	
player_destroy:
	push ebp
	mov ebp, esp
	
	push dword[ebp+8]
	call free
	
	mov esp, ebp
	pop ebp
	ret
	

player_update:
	push ebp
	push ebx
	mov ebp, esp
	
	sub esp, 12			;forward
	sub esp, 12			;right
	
	mov ebx, dword[ebp+12]
	mov ebx, dword[eax]			;cum in eax
	
	lea eax, [ebp-12]
	push eax
	push ebx
	call camera_forward
	sub dword[esp+4], 12
	call camera_right
	add esp, 8
	
	movss xmm0, dword[ebp+16]
	mulss xmm0, dword[MOVEMENT_SPEED]
	mov eax, -24
_update_scale_vectors_loop_start:
	movss xmm1, dword[ebp+eax]
	mulss xmm1, xmm0
	movss dword[ebp+eax], xmm1
	
	add eax, 4
	cmp eax, 0
	jne _update_scale_vectors_loop_start
	
	push dword[KEY_W]
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _update_no_forward
	
	movss xmm0, dword[ebp-12]
	movss xmm1, dword[ebx]
	addss xmm1, xmm0
	movss dword[ebx], xmm1
	
	movss xmm0, dword[ebp-8]
	movss xmm1, dword[ebx+4]
	addss xmm1, xmm0
	movss dword[ebx+4], xmm1
	
	movss xmm0, dword[ebp-4]
	movss xmm1, dword[ebx+8]
	addss xmm1, xmm0
	movss dword[ebx+8], xmm1
_update_no_forward:

	push dword[KEY_S]
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _update_no_backward
	
	xor dword[ebp-12], 0x80000000
	xor dword[ebp-8], 0x80000000
	xor dword[ebp-4], 0x80000000
	
	movss xmm0, dword[ebp-12]
	movss xmm1, dword[ebx]
	addss xmm1, xmm0
	movss dword[ebx], xmm1
	
	movss xmm0, dword[ebp-8]
	movss xmm1, dword[ebx+4]
	addss xmm1, xmm0
	movss dword[ebx+4], xmm1
	
	movss xmm0, dword[ebp-4]
	movss xmm1, dword[ebx+8]
	addss xmm1, xmm0
	movss dword[ebx+8], xmm1
_update_no_backward:

	push dword[KEY_D]
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _update_no_right
	
	movss xmm0, dword[ebp-24]
	movss xmm1, dword[ebx]
	addss xmm1, xmm0
	movss dword[ebx], xmm1
	
	movss xmm0, dword[ebp-20]
	movss xmm1, dword[ebx+4]
	addss xmm1, xmm0
	movss dword[ebx+4], xmm1
	
	movss xmm0, dword[ebp-16]
	movss xmm1, dword[ebx+8]
	addss xmm1, xmm0
	movss dword[ebx+8], xmm1
_update_no_right:

	push dword[KEY_A]
	call input_isKeyHeld
	add esp, 4
	cmp eax, 0
	je _update_no_left
	
	xor dword[ebp-24], 0x80000000
	xor dword[ebp-20], 0x80000000
	xor dword[ebp-16], 0x80000000
	
	movss xmm0, dword[ebp-24]
	movss xmm1, dword[ebx]
	addss xmm1, xmm0
	movss dword[ebx], xmm1
	
	movss xmm0, dword[ebp-20]
	movss xmm1, dword[ebx+4]
	addss xmm1, xmm0
	movss dword[ebx+4], xmm1
	
	movss xmm0, dword[ebp-16]
	movss xmm1, dword[ebx+8]
	addss xmm1, xmm0
	movss dword[ebx+8], xmm1
_update_no_left:
	
	
	mov esp, ebp
	pop ebx
	pop ebp
	ret
