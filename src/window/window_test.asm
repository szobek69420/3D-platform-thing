section .rodata
	print_mouse_coordinates db "mouse coords: %d %d",10,0
	print_window_size db "window size: %d %d",10,0
	print_key db "%s",10,0
	print_button db "%d",10,0
	
	test_triangle dd -0.5, 0.0, 0.1,  -0.1, 0.5, 1.0,  0.7, -0.3, 0.2
	test_triangle2 dd -0.4, -0.6, 0.5,  0.5, 0.2, 0.1,  0.6, 0.1, 0.2

section .text
	extern window_create
	extern window_pendingEvent
	extern window_consumeEvent
	extern window_showFrame
	extern window_onResize
	extern window_clearDrawBuffer
	extern printf
	
	extern renderer_renderTriangle
	extern renderable_createKuba
	extern renderable_destroy
	
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
	
	mov eax, esp
	push esp
	call renderable_createKuba
	call renderable_destroy
	add esp, 4
	
	lea eax, [ebp-60]
	push eax
	call window_create
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

	mov eax, test_triangle
	add eax, 24
	push eax
	sub eax, 12
	push eax
	sub eax, 12
	push eax
	push 0xFFFF0000
	lea ecx, [ebp-60]
	push ecx
	call renderer_renderTriangle
	add esp, 20
	
	mov eax, test_triangle2
	add eax, 24
	push eax
	sub eax, 12
	push eax
	sub eax, 12
	push eax
	push 0xFF00FF00
	lea ecx, [ebp-60]
	push ecx
	call renderer_renderTriangle
	add esp, 20

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
	
