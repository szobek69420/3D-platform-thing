section .rodata
	
section .bss
	window resb 60
	event_buffer resb 16
	camera resb 36
	kuba resb 84
	pplayer resb 4	
	pv_matrix resb 64
	
section .text
	extern window_create
	extern window_pendingEvent
	extern window_consumeEvent
	extern WindowResizeEvent

	extern player_init
	extern player_update
	
	extern camera_init
	
	extern input_init
	extern input_update
	extern input_processEvent
	
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
	
	;init camera
	push camera
	call camera_init
	add esp, 4
	
	;create player
	push camera
	call player_init
	mov dword[pplayer], eax
	add esp, 4
	
_game_loop:
	call input_update
	call processEvents
	
	push 0
	push dword[pplayer]
	call player_update
	add esp, 4
	
	
	jmp _game_loop
	
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
	cmp eax, dword[WindowResizeEvent]
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
	
	
	mov esp, ebp
	pop ebp
	ret
