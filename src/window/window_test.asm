section .rodata
	print_mouse_coordinates db "mouse coords: %d %d",10,0
	print_window_size db "window size: %d %d",10,0
	print_key db "%s",10,0
	print_button db "%d",10,0

section .text
	extern window_create
	extern window_pendingEvent
	extern window_consumeEvent
	extern printf
	
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
	
	sub esp, 12		;buffer for screeninfo
	sub esp, 12		;buffer for event
	
	lea eax, [ebp-12]
	push eax
	call window_create
	add esp, 4
	
_start_endless_loop:
	lea eax, [ebp-12]
	push eax
	call window_pendingEvent
	add esp, 4
	cmp eax, 0
	je _start_endless_loop_continue
	
	lea eax, [ebp-12]	;screeninfo in eax
	lea ecx, [ebp-24]	;event in ecx
	push ecx
	push eax
	call window_consumeEvent
	add esp, 8
	
	mov eax, dword[ebp-24]
	cmp eax, dword[MouseReleaseEvent]
	jne _start_endless_loop_continue
	
	lea ecx, [ebp-24]
	push dword[ecx+4]
	push print_button
	call printf
	add esp, 8
	
_start_endless_loop_continue:
	jmp _start_endless_loop
_start_endless_loop_end:
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
	
