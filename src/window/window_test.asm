section .rodata
	print_mouse_coordinates db "mouse coords: %d %d",10,0
	goodbye_message db "bye bozo",10,0

section .text
	extern window_create
	extern window_pendingEvent
	extern window_consumeEvent
	extern printf
	
	extern WindowCloseEvent
	extern MouseMotionEvent
	extern NoEvent
	
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
	cmp eax, dword[WindowCloseEvent]
	jne _start_endless_loop_continue
	
	push goodbye_message
	call printf
	add esp, 4
	jmp _start_endless_loop_end
	
_start_endless_loop_continue:
	jmp _start_endless_loop
_start_endless_loop_end:
	
	push goodbye_message
	call printf
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
	
