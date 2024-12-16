section .rodata
	F0p1 dd 0.1
	ONE dd 1.0
	
	ONE_PER_CLOCKS_PER_SECOND dd 0.000001
	TENTH dd 0.1
	
	print_float_format db "%.3f",10,0
	print_frame_count db "FPS: %d",10,0
	
	
	RAYCAST_KNOB_SCALE dd 0.1, 0.1, 0.1
	
	test_text db "TEST TEXT",0
	test_text2 db "NIGGA",0
	
	status_text_1_format db "PLAYER POS: %.1f, %.1f, %.1f",0 
	status_text_2_format db "VIEW DIR: %.1f, %.1f",0
	status_text_3_format db "LOADED CHOMKS: %d",0
	status_text_4_format db "FPS: %d",0
	
section .bss
	window resb 60
	event_buffer resb 16
	camera resb 48
	pplayer resb 4	
	pv_matrix resb 64
	pchomk_manager resb 4
	
	lastFrame resb 4		;clock_t
	frameHelper resb 4		;clock_t
	deltaTime resb 4		;float
	
	raycast_knob resb 84		;renderable
	
	
section .data
	frameCount dd 0
	lastSecond dd 0.0
	fps dd 0
	
section .text
	extern clock
	extern memcpy
	extern printf
	extern sprintf

	extern window_create
	extern window_pendingEvent
	extern window_consumeEvent
	extern window_clearDrawBuffer
	extern window_showFrame
	extern window_scaleBuffer
	extern window_onResize
	extern WindowResizeEvent

	extern player_init
	extern player_update
	extern player_printUI
	
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
	
	extern textRenderer_renderText
	extern textRenderer_setColour
	extern TEXT_ALIGN_TOP_LEFT
	extern TEXT_ALIGN_TOP_CENTER
	extern TEXT_ALIGN_TOP_RIGHT
	extern TEXT_ALIGN_CENTER_LEFT
	extern TEXT_ALIGN_CENTER_CENTER
	extern TEXT_ALIGN_CENTER_RIGHT
	extern TEXT_ALIGN_BOTTOM_LEFT
	extern TEXT_ALIGN_BOTTOM_CENTER
	extern TEXT_ALIGN_BOTTOM_RIGHT
	
	
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
	
	;create chomk manager
	push 2
	call chomkManager_create
	mov dword[pchomk_manager], eax
	add esp, 4
	
	;create player
	push dword[pchomk_manager]
	push camera
	call player_init
	mov dword[pplayer], eax
	add esp, 4
	
	;add player to physics
	mov eax, dword[pplayer]
	mov eax, dword[eax+4]
	push eax
	call physics_registerDynamicCollider
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
			mov eax, dword[frameCount]
			mov dword[fps], eax
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
		mov eax, dword[pplayer]
		push dword[eax]
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
		
		;scale the draw buffer to screen size
		push window
		call window_scaleBuffer
		add esp, 4
		
		;render text
		call renderText
		
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
	
	
renderText:		;void renderText(void)
	push ebp
	mov ebp, esp
	
	sub esp, 200		;char array
	mov eax, esp
	push eax		;address of the array
	
	push 0xFFFFFFFF
	call textRenderer_setColour
	add esp, 4
	
	push TEXT_ALIGN_TOP_RIGHT
	push 15
	push 15
	push window
	push test_text
	call textRenderer_renderText
	add esp, 20
	
	push 0xFF000000
	call textRenderer_setColour
	add esp, 4
	
	push TEXT_ALIGN_TOP_RIGHT
	push 40
	push 15
	push window
	push test_text2
	call textRenderer_renderText
	add esp, 20
	
	push 0xFFFFFA00
	call textRenderer_setColour
	add esp, 4
	
	;print fps
	push dword[fps]
	push status_text_4_format
	push dword[ebp-204]
	call sprintf
	add esp, 12
	
	push TEXT_ALIGN_TOP_LEFT
	push 15
	push 15
	push window
	push dword[ebp-204]
	call textRenderer_renderText
	add esp, 20
	
	;show player position
	mov eax, dword[pplayer]
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
	push window
	push dword[ebp-204]
	call textRenderer_renderText
	add esp, 20
	
	;show player view direction
	mov eax, dword[pplayer]
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
	push window
	push dword[ebp-204]
	call textRenderer_renderText
	add esp, 20
	
	;show loaded chomks
	mov eax, dword[pchomk_manager]
	mov eax, dword[eax]		;chomk count
	push eax
	push status_text_3_format
	push dword[ebp-204]
	call sprintf
	add esp, 12
	
	push TEXT_ALIGN_TOP_LEFT
	push 90
	push 15
	push window
	push dword[ebp-204]
	call textRenderer_renderText
	add esp, 20
	
	;draw player ui
	push window
	push dword[pplayer]
	call player_printUI
	add esp, 8
	
	mov esp, ebp
	pop ebp
	ret
	

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
