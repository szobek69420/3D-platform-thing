section .rodata
	window_title db "pee diddy",0

section .text
	extern window_create
	
	global main:
main:
	push ebp
	mov ebp, esp
	
	sub esp, 4		;window
	sub esp, 4		;renderer
	
	lea eax, [ebp-4]
	lea ecx, [ebp-8]
	
	push ecx
	push eax
	push window_title
	call window_create
	add esp, 12
	
_start_endless_loop:
	jmp _start_endless_loop
	
	mov esp, ebp
	pop ebp
	
	xor ebx, ebx
	mov eax, 1
	int 0x80
	
