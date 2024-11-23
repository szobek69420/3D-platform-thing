section .rodata
	SDL_INIT_TIMER dd 0x00000001
	SDL_INIT_AUDIO dd 0x00000010
	SDL_INIT_VIDEO dd 0x00000020
	SDL_INIT_EVENTS dd 0x00004000
	
	SDL_WINDOWPOS_CENTERED dd 0x2FFF0000
	SDL_RENDERER_SOFTWARE dd 1
	
	SDL_EVENT_SIZE dd 56
	
	error_message db "Window wouldn't fucking open sry",10,0
	
section .text
	extern SDL_Init
	extern SDL_CreateWindow
	extern SDL_CreateRenderer
	extern SDL_RenderClear
	
	global window_create		;void window_create(const char* name, SDL_Window** pwindow, SDL_Renderer** prenderer)
	global window_waitEvent		;void window_waitEvent(Event* event) //Event will be my own transformed type of SDL_Event
	
window_create:
	push ebp
	mov ebp, esp
	
	mov eax, dword[SDL_INIT_TIMER]
	or eax, dword[SDL_INIT_VIDEO]
	or eax, dword[SDL_INIT_EVENTS]
	;or eax, dword[SDL_INIT_AUDIO]
	
	
	push eax
	call SDL_Init
	add esp, 4
	
	push 0
	push 600
	push 600
	push dword[SDL_WINDOWPOS_CENTERED]
	push dword[SDL_WINDOWPOS_CENTERED]
	mov eax, dword[ebp+8]
	push eax
	call SDL_CreateWindow
	add esp, 24
	mov ecx, dword[ebp+12]
	mov dword[ecx], eax		;save pwindow
	
	push dword[SDL_RENDERER_SOFTWARE]
	push -1
	push eax
	call SDL_CreateRenderer
	add esp, 12
	mov ecx, dword[ebp+16]
	mov dword[ecx], eax		;save prenderer
	
	push eax
	call SDL_RenderClear
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret
