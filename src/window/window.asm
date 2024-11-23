;my sources:
;Nir Lichtman @ yt
;croakingkero.com
;https://gist.github.com/nikAizuddin/6fbbc703f1213ab61a8a

;struct ScreenInfo{
;	Display* display;
;	Window window;
;	int screenNumber;
;}

section .rodata
	create_error_message db "Couldn't open window sry :(",10,0
	window_title db "pee diddy",0

section .text
	extern printf

	extern XOpenDisplay
	extern XCreateSimpleWindow
	extern XDefaultScreen
	extern XRootWindow
	extern XBlackPixel
	extern XWhitePixel
	extern XMapWindow
	extern XStoreName
	extern XFlush
	
	global window_create		;void window_create(ScreenInfo* buffer)
	
window_create:
	push ebp
	push esi
	push edi
	push ebx
	mov ebp, esp
	
	mov ebx, dword[ebp+20]		;buffer in ebx
	
	
	;connect to XServer
	push 0	;set window title
	call XOpenDisplay
	mov dword[ebx], eax	;save Display*
	add esp, 4
	cmp eax, 0
	je _window_create_error
	
	;create window
	push dword[ebx]
	call XDefaultScreen	;retrieve default screen number for XRootWindow call
	add esp, 4
	
	push eax
	push dword[ebx]
	call XRootWindow
	mov esi, eax		;root window in esi
	add esp, 8
	
	push 69			;placeholder for bg colour
	push 69			;placeholder for border colour
	push 0
	push dword[ebx]
	call XBlackPixel
	mov dword[esp+12], eax
	call XWhitePixel
	mov dword[esp+8], eax
	add esp, 8
	
	push 1		;border width
	push 400	;window height
	push 400	;window width
	push 50		;y pos
	push 50		;x pos
	push esi	;root window
	push dword[ebx]	;display*
	call XCreateSimpleWindow
	mov dword[ebx+4], eax	;save window
	add esp, 36
	
	;map window
	push dword[ebx+4]
	push dword[ebx]
	call XMapWindow
	add esp, 8
	
	;set window title
	push window_title
	push dword[ebx+4]
	push dword[ebx]
	call XStoreName
	add esp, 12
	
	;flush things (probably unnecessary)
	push dword[ebx]
	call XFlush
	add esp, 4
	
	jmp _window_create_end
_window_create_error:
	push create_error_message
	call printf
	
_window_create_end:
	mov esp, ebp
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret
