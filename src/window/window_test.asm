section .rodata
	print_mouse_coordinates db "mouse coords: %d %d",10,0

section .text
	extern window_create
	extern window_pendingEvent
	extern window_consumeEvent
	extern printf
	
	extern MouseMotionEvent
	extern NoEvent
	
	global _start:
_start:
	push ebp
	mov ebp, esp
	
	sub esp, 8		;buffer for screeninfo
	sub esp, 12		;buffer for event
	
	lea eax, [ebp-8]
	push eax
	call window_create
	add esp, 8
	
_start_endless_loop:
	lea eax, [ebp-8]
	push eax
	call window_pendingEvent
	add esp, 4
	cmp eax, 0
	je _start_endless_loop_continue
	
	lea eax, [ebp-8]	;screeninfo in eax
	lea ecx, [ebp-20]	;event in ecx
	push ecx
	push eax
	call window_consumeEvent
	add esp, 8
	
	mov eax, dword[ebp-20]
	cmp eax, dword[MouseMotionEvent]
	jne _start_endless_loop_continue
	
	push dword[ebp-12]
	push dword[ebp-16]
	push print_mouse_coordinates
	call printf
	add esp, 12
	
_start_endless_loop_continue:
	jmp _start_endless_loop
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
	
