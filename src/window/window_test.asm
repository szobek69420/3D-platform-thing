section .rodata
	print_mouse_coordinates db "mouse coords: %d %d",10,0
	print_window_size db "window size: %d %d",10,0
	print_key db "%s",10,0
	print_button db "%d",10,0
	
	test_triangle dd -0.5, 0.0, 0.1,  -0.1, 0.5, 1.0,  0.7, -0.3, 0.2
	test_triangle2 dd -0.4, -0.6, 0.5,  0.5, 0.2, 0.1,  0.6, 0.1, 0.2
	
	ONE dd 1.0
	DELTA_ROT_X dd 0.1
	DELTA_ROT_Y dd 0.13
	
section .bss
	mouseX resb 4
	mouseY resb 4

section .text
	extern window_create
	extern window_pendingEvent
	extern window_consumeEvent
	extern window_showFrame
	extern window_onResize
	extern window_clearDrawBuffer
	extern window_getCursorPosition
	extern window_setCursorPosition
	extern window_hideCursor
	
	extern printf
	
	extern renderer_renderTriangle
	extern renderable_createKuba
	extern renderable_destroy
	extern renderable_render
	extern renderable_print
	
	extern mat4_init
	
	extern NoEvent
	extern WindowCloseEvent
	extern MouseMotionEvent
	extern KeyPressEvent
	extern KeyReleaseEvent
	extern WindowResizeEvent
	extern MousePressEvent
	extern MouseReleaseEvent
	
	global _start:
_start:
	push ebp
	mov ebp, esp
	
	finit
	
	sub esp, 60		;buffer for screeninfo
	sub esp, 12		;buffer for event
	sub esp, 4		;frame counter
	sub esp, 84		;renderable
	sub esp, 64		;pv matrix
	
	lea eax, [ebp-160]
	push eax
	call renderable_createKuba
	add esp, 4
	
	lea eax, [ebp-224]
	push dword[ONE]
	push eax
	call mat4_init
	add esp, 8
	
	
	lea eax, [ebp-60]
	push eax
	call window_create
	add esp, 4
	
	lea eax, [ebp-60]
	push eax
	call window_hideCursor
	add esp, 4

_start_endless_loop:
	lea eax, [ebp-60]
	push eax
	call window_pendingEvent
	add esp, 4
	cmp eax, 0
	je _start_endless_loop_no_event
	
	lea eax, [ebp-60]	;screeninfo in eax
	lea ecx, [ebp-72]	;event in ecx
	push ecx
	push eax
	call window_consumeEvent
	add esp, 8
	
	mov eax, dword[ebp-72]
	cmp eax, dword[MouseReleaseEvent]
	jne _start_endless_loop_no_mouse_event
	
	push dword[ebp-76]
	push print_button
	call printf
	add esp, 8
	
	mov dword[ebp-76],0
	jmp _start_endless_loop_no_event
	
_start_endless_loop_no_mouse_event:
	cmp eax, dword[WindowResizeEvent]
	jne _start_endless_loop_no_event
	
	lea eax, [ebp-60]
	mov ecx, dword[ebp-68]
	mov dword[eax+40], ecx
	mov ecx, dword[ebp-64]
	mov dword[eax+44], ecx
	
	push eax
	call window_onResize
	add esp, 4
	
_start_endless_loop_no_event:
	lea ecx, [ebp-60]
	push 0xFF0000FF
	push ecx
	call window_clearDrawBuffer
	add esp, 8
	
	push 69
	push 69
	lea eax, [ebp-60]
	push eax
	call window_setCursorPosition
	add esp, 12
	
	lea eax, [ebp-60]
	push mouseY
	push mouseX
	push eax
	call window_getCursorPosition
	add esp, 12
	
	push dword[mouseY]
	push dword[mouseX]
	push print_mouse_coordinates
	call printf
	add esp, 12

	lea eax, [ebp-160]
	lea ecx, [ebp-60]
	lea edx, [ebp-224]
	movss xmm0, dword[DELTA_ROT_X]
	movss xmm1, dword[eax+60]
	addss xmm1, xmm0
	movss dword[eax+60], xmm1
	movss xmm0, dword[DELTA_ROT_Y]
	movss xmm1, dword[eax+64]
	addss xmm1, xmm0
	movss dword[eax+64], xmm1
	
	push edx
	push ecx
	push eax
	call renderable_render
	add esp, 12

	lea ecx, [ebp-60]
	push ecx
	call window_showFrame
	add esp, 4
	inc dword[ebp-76]
	
	jmp _start_endless_loop
_start_endless_loop_end:
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
	
