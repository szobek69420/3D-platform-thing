section .rodata
	F0p1 dd 0.1
	ONE dd 1.0
	
	ONE_PER_CLOCKS_PER_SECOND dd 0.000001
	TENTH dd 0.1
	
	print_float_format db "%.3f",10,0
	print_frame_count db "FPS: %d",10,0
	
	
	kuba1_scale dd 1.0, 3.0, 1.0
	kuba2_position dd -1.0, -2.0, 0.0
	kuba3_position dd 1.0, -2.0, 0.0
	
	temp_collider_lower_bound dd -1.0, -1.0, -1.0
	temp_collider_upper_bound dd 1.0, 1.0, 1.0
	
	RAYCAST_KNOB_SCALE dd 0.1, 0.1, 0.1
	
section .bss
	window resb 60
	event_buffer resb 16
	camera resb 36
	kuba1 resb 84
	kuba2 resb 84
	kuba3 resb 84
	pplayer resb 4	
	pv_matrix resb 64
	pchomk_manager resb 4
	
	lastFrame resb 4		;clock_t
	frameHelper resb 4		;clock_t
	deltaTime resb 4		;float
	
	raycast_knob resb 84		;renderable
	
	temp_collider resb 4
	temp_collider_group resb 4
	
	temp_chomk resb 4
	
section .data
	frameCount dd 0
	lastSecond dd 0.0
	
section .text
	extern clock
	extern memcpy
	extern printf

	extern window_create
	extern window_pendingEvent
	extern window_consumeEvent
	extern window_clearDrawBuffer
	extern window_showFrame
	extern window_onResize
	extern WindowResizeEvent

	extern player_init
	extern player_update
	
	extern camera_init
	extern camera_viewProjection
	extern camera_view
	
	extern input_init
	extern input_update
	extern input_processEvent
	
	extern renderable_render
	extern renderable_createKuba
	extern renderable_destroy
	
	extern collider_createCollider
	extern collider_resolveCollision
	extern collider_printInfo
	
	extern colliderGroup_createColliderGroup
	extern colliderGroup_addCollider
	extern colliderGroup_collide
	extern colliderGroup_printInfo
	
	extern physics_init
	extern physics_deinit
	extern physics_step
	extern physics_registerDynamicCollider
	extern physics_registerColliderGroup
	
	extern chomk_generateChomk
	extern chomk_renderChomk
	
	extern chomkManager_create
	extern chomkManager_generate
	extern chomkManager_render
	
	
	global raycast_knob
	
	global _start
	
_start:
	push ebp
	mov ebp, esp
	
	finit
	
	;open window
	push window
	call window_create
	add esp, 4
	
	;init input
	call input_init
	
	;init physics
	call physics_init
	
	;init camera
	push camera
	call camera_init
	add esp, 4
	
	;create player
	push camera
	call player_init
	mov dword[pplayer], eax
	add esp, 4
	
	;create chomk manager
	push 2
	call chomkManager_create
	mov dword[pchomk_manager], eax
	add esp, 4
	
	;create raycast knob
	push raycast_knob
	call renderable_createKuba
	add esp, 4
	mov eax, raycast_knob
	add eax, 72
	push 12
	push RAYCAST_KNOB_SCALE
	push eax
	call memcpy
	add esp, 12
	
	;create kubak
	push kuba1
	call renderable_createKuba
	mov dword[esp], kuba2
	call renderable_createKuba
	mov dword[esp], kuba3
	call renderable_createKuba
	add esp, 4
	
	mov eax, kuba1
	add eax, 72
	push 12
	push kuba1_scale
	push eax
	call memcpy
	add esp, 12
	
	mov eax, kuba2
	add eax, 48
	push 12
	push kuba2_position
	push eax
	call memcpy
	add esp, 12
	
	mov eax, kuba3
	add eax, 48
	push 12
	push kuba3_position
	push eax
	call memcpy
	add esp, 12
	
	;create temp collider and cg
	push temp_collider_upper_bound
	push temp_collider_lower_bound
	call collider_createCollider
	mov dword[temp_collider], eax
	add esp, 8
	
	call colliderGroup_createColliderGroup
	mov dword[temp_collider_group], eax
	
	push dword[temp_collider]
	push dword[temp_collider_group]
	call colliderGroup_addCollider
	add esp, 8
	
	
	;add colliders and collider groups to physics
	mov eax, dword[pplayer]
	mov eax, dword[eax+4]
	push eax
	call physics_registerDynamicCollider
	add esp, 4
	
	mov eax, dword[temp_collider_group]
	push eax
	call physics_registerColliderGroup
	add esp, 4
	
	;generate temp chomk
	push 0
	push 0
	push 0
	call chomk_generateChomk
	mov dword[temp_chomk], eax
	add esp, 12
	
	call clock
	mov dword[lastFrame], eax
	
_game_loop:
	;calculate fps start
	call clock
	mov dword[frameHelper], eax
	mov ecx, eax
	sub eax, dword[lastFrame]
	mov dword[lastFrame], ecx
	mov dword[frameHelper], eax
	fild dword[frameHelper]
	fld dword[ONE_PER_CLOCKS_PER_SECOND]
	fmulp
	fstp dword[deltaTime]
	
	movss xmm0, dword[lastSecond]
	movss xmm1, dword[deltaTime]
	addss xmm0, xmm1
	movss dword[lastSecond], xmm0
	movss xmm1, dword[ONE]
	ucomiss xmm0, xmm1
	jb _skip_fps_print
	
	push dword[frameCount]
	push print_frame_count
	call printf
	add esp, 8
	mov dword[frameCount], 0
	mov dword[lastSecond], 0
_skip_fps_print:
	inc dword[frameCount]
	;calculate fps end

	call input_update
	call processEvents
	
	push dword[deltaTime]
	push dword[pplayer]
	call player_update
	add esp, 8
	
	;physics update
	push ebx		;save ebx
	movss xmm0, dword[deltaTime]
	mulss xmm0, dword[TENTH]
	sub esp, 4
	movss dword[esp], xmm0
	mov ebx, 10
	_physics_update_loop_start:	
		call physics_step
		dec ebx
		cmp ebx, 0
		jg _physics_update_loop_start
	pop ebx			;restore ebx
	add esp, 4
	
	;generate chomks
	sub esp, 8
	mov eax, dword[pplayer]
	mov eax, dword[eax]
	mov ecx, dword[eax]
	mov dword[esp], ecx
	mov ecx, dword[eax+8]
	mov dword[esp+4], ecx
	fld dword[esp]
	fistp dword[esp]
	fld dword[esp+4]
	fistp dword[esp+4]
	push dword[pchomk_manager]
	call chomkManager_generate
	add esp, 12
	
	;clear buffer
	push 0xFF00BFFF
	push window
	call window_clearDrawBuffer
	add esp, 8
	
	;calculate pv matrix
	push pv_matrix
	push camera
	call camera_viewProjection
	add esp, 8
	
	;render raycast knob
	push pv_matrix
	push window
	push raycast_knob
	call renderable_render
	add esp, 12
	
	;render chomks
	mov eax, dword[pplayer]
	push dword[eax]
	push pv_matrix
	push window
	push dword[pchomk_manager]
	call chomkManager_render
	add esp, 16
	
	
	;draw buffer
	push window
	call window_showFrame
	add esp, 4
	
	jmp _game_loop
	
	;delete raycast knob
	push raycast_knob
	call renderable_destroy
	add esp, 4
	
	;deinit physics
	call physics_deinit
	
	;call exit()
_game_exit:
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
	

processEvents:		;void processEvents(void) //processes the incoming events
	push ebp
	mov ebp, esp
	
_processEvent_loop_start:
	push window
	call window_pendingEvent
	add esp, 4
	cmp eax, 0
	je _processEvent_done
	
	push event_buffer
	push window
	call window_consumeEvent
	add esp, 8
	
	mov eax, dword[event_buffer]
	cmp eax, WindowResizeEvent
	jne _processEvent_not_window_event
	call onWindowResize
	
_processEvent_not_window_event:
	push event_buffer
	call input_processEvent
	add esp, 4
	
	jmp _processEvent_loop_start
	
_processEvent_done:
	mov esp, ebp
	pop ebp
	ret
	
onWindowResize:		;void onWindowResize(void)
	push ebp
	mov ebp, esp
	
	;calculate aspect ratio
	mov eax, event_buffer
	mov ecx, camera
	fild dword[eax+4]
	fild dword[eax+8]
	fdivp
	fstp dword[ecx+32]
	
	;update window
	mov eax, event_buffer
	mov ecx, window
	mov edx, dword[event_buffer+4]
	mov dword[ecx+40], edx
	mov edx, dword[event_buffer+8]
	mov dword[ecx+44], edx
	
	push window
	call window_onResize
	add esp, 4
	
	
	mov esp, ebp
	pop ebp
	ret
