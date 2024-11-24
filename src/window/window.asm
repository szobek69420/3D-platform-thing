;my sources:
;Nir Lichtman @ yt
;Future Tech Labs @ yt
;croakingkero.com
;https://gist.github.com/nikAizuddin/6fbbc703f1213ab61a8a

;struct ScreenInfo{
;	Display* display;
;	Window window;
;	int deleteAtom;
;}

;struct Event{
;	int type;
;	union{
;	MouseMotionEvent;
;	WindowCloseEvent;
;	}
;}

;struct MouseMotionEvent{
;	int x, y;
;}

;struct WindowCloseEvent{}

section .rodata
	create_error_message db "Couldn't open window sry :(",10,0
	window_title db "pee diddy",0
	atom_type db "WM_DELETE_WINDOW",0
	
	;x11 masks and event types
	PointerMotionMask dd 0x40
	MotionNotify dd 0x6
	
	StructureNotifyMask dd 0x20000
	DestroyNotify dd 0x11
	ClientMessage dd 0x21
	
	;my event types
	NoEvent dd 0
	MouseMotionEvent dd 1
	WindowCloseEvent dd 2
	
	global NoEvent
	global MouseMotionEvent
	global WindowCloseEvent

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
	extern XInternAtom
	extern XSetWMProtocols
	extern XFlush
	
	extern XUnmapWindow
	extern XDestroyWindow
	extern XCloseDisplay
	
	extern XSelectInput
	extern XPending
	extern XNextEvent
	
	global window_create		;void window_create(ScreenInfo* buffer)
	global window_destroy		;void window_destroy(ScreenInfo* window)
	
	global window_pendingEvent	;int window_pendingEvent(ScreenInfo* window);		//returns the number of pending events
	global window_consumeEvent	;void window_pendingEvent(ScreenInfo* window, Event* buffer)
	
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
	
	;set wm protocol to detect window close
	push 0
	push atom_type
	push dword[ebx]
	call XInternAtom
	add esp, 12
	mov dword[ebx+8],eax
	
	lea eax, [ebx+8]
	push 1
	push eax
	push dword[ebx+4]
	push dword[ebx]
	call XSetWMProtocols
	add esp, 16
	
	;set event mask
	mov eax, dword[PointerMotionMask]
	or eax, dword[StructureNotifyMask]
	
	push eax
	push dword[ebx+4]
	push dword[ebx]
	call XSelectInput
	add esp, 12
	
	
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
	
	
window_destroy:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]	;window in eax
	
	push dword[eax+8]
	push dword[eax]
	call XUnmapWindow
	call XDestroyWindow
	call XCloseDisplay
	
	mov esp, ebp
	pop ebp
	ret
	
	
window_pendingEvent:
	mov eax, dword[esp+4]
	push dword[eax]
	call XPending
	add esp, 4
	ret
	
	
window_consumeEvent:
	push ebp
	mov ebp, esp
	
	;check if there are pending events
	mov eax, dword[ebp+8]
	push dword[eax]
	call XPending
	add esp, 4
	cmp eax, 0
	jg _consumeEvent_eventfulness
	
	mov eax, dword[NoEvent]
	mov ecx, dword[ebp+12]
	mov dword[ecx], eax		;set the event type to noevent
	
	mov esp, ebp
	pop ebp
	ret
	
_consumeEvent_eventfulness:
	
	sub esp, 96		;allocate XEvent
	
	;call XNextEvent
	mov eax, dword[ebp+8]
	mov ecx, esp
	
	push ecx
	push dword[eax]
	call XNextEvent
	add esp, 8
	
	;check for type
	mov eax, dword[ebp-96]		;event.type in eax
	mov ecx, dword[ebp+12]		;buffer in ecx
	
	
	cmp eax, dword[DestroyNotify]
	jne _consumeEvent_not_window_close_event
	
	mov edx, dword[WindowCloseEvent]
	mov dword[ecx], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_window_close_event:
	
	cmp eax, dword[MotionNotify]
	jne _consumeEvent_not_mouse_motion_event
	
	mov edx, dword[MouseMotionEvent]
	mov dword[ecx], edx
	
	mov edx, dword[ebp-64]		;.xmotion.x
	mov dword[ecx+4], edx
	
	mov edx, dword[ebp-60]		;.xmotion.y
	mov dword[ecx+8], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_mouse_motion_event:
	
	
_consumeEvent_event_check_done:
	mov esp, ebp
	pop ebp
	ret
