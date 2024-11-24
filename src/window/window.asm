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
;		MouseMotionEvent;
;		WindowCloseEvent;
;		KeyPressEvent;
;		KeyReleaseEvent;
;		WindowResizeEvent;
;		MousePressEvent;
;		MouseReleaseEvent;
;	}
;}

;struct MouseMotionEvent{
;	int x, y;
;}

;struct WindowCloseEvent{}

;struct KeyPressEvent and KeyReleaseEvent{
;	char* keyString;
;}

;struct WindowResizeEvent{
;	int width;
;	int height;
;}

;struct MousePressEvent and MouseReleaseEvent{
;	int button;
;}

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
	
	KeyPressMask dd 0x1
	KeyPress dd 0x2
	
	KeyReleaseMask dd 0x2
	KeyRelease dd 0x3
	
	ButtonPressMask dd 0x4
	ButtonPress dd 0x4
	ButtonReleaseMask dd 0x8
	ButtonRelease dd 0x5
	
	ConfigureNotify dd 0x16
	
	;my event types
	NoEvent dd 0
	MouseMotionEvent dd 1
	WindowCloseEvent dd 2
	KeyPressEvent dd 3
	KeyReleaseEvent dd 4
	WindowResizeEvent dd 5		;window resize event is also generated when the window is moved
	MousePressEvent dd 6
	MouseReleaseEvent dd 7		;mouseevents detect scrolls too
	
	global NoEvent
	global MouseMotionEvent
	global WindowCloseEvent
	global KeyPressEvent
	global KeyReleaseEvent
	global WindowResizeEvent
	global MousePressEvent
	global MouseReleaseEvent

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
	extern XKeycodeToKeysym
	extern XKeysymToString
	
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
	jmp _create_skip_wm_protocol
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
_create_skip_wm_protocol:
	
	;set event mask
	mov eax, dword[PointerMotionMask]
	or eax, dword[StructureNotifyMask]
	or eax, dword[KeyPressMask]
	or eax, dword[KeyReleaseMask]
	or eax, dword[ButtonPressMask]
	or eax, dword[ButtonReleaseMask]
	
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

	cmp eax, dword[ConfigureNotify]
	jne _consumeEvent_not_window_resize_event
	
	mov edx, dword[WindowResizeEvent]
	mov dword[ecx], edx
	
	mov edx, dword[ebp-64]		;.xconfigure.width
	mov dword[ecx+4], edx
	
	mov edx, dword[ebp-60]		;.xconfigure.height
	mov dword[ecx+8], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_window_resize_event:
	
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

	cmp eax, dword[KeyPress]
	jne _consumeEvent_not_key_press_event
	
	mov edx, dword[KeyPressEvent]
	mov dword[ecx], edx
	
	;convert keycode to ascii
	push eax
	push ecx
	
	mov eax, dword[ebp+8]		;screeninfo
	mov edx, dword[ebp-44]		;.xkey.keycode
	push 0
	push edx
	push dword[eax]
	call XKeycodeToKeysym
	add esp, 12
	
	push eax
	call XKeysymToString
	mov edx, eax
	add esp, 4
	
	pop ecx
	pop eax
	
	mov dword[ecx+4], edx		;save character
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_key_press_event:

	cmp eax, dword[KeyRelease]
	jne _consumeEvent_not_key_release_event
	
	mov edx, dword[KeyReleaseEvent]
	mov dword[ecx], edx
	
	;convert keycode to ascii
	push eax
	push ecx
	
	mov eax, dword[ebp+8]		;screeninfo
	mov edx, dword[ebp-44]		;.xkey.keycode
	push 0
	push edx
	push dword[eax]
	call XKeycodeToKeysym
	add esp, 12
	
	push eax
	call XKeysymToString
	mov edx, eax
	add esp, 4
	
	pop ecx
	pop eax
	
	mov dword[ecx+4], edx		;save character
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_key_release_event:

	cmp eax, dword[ButtonPress]
	jne _consumeEvent_not_mouse_press_event
	
	mov edx, dword[MousePressEvent]
	mov dword[ecx], edx
	
	mov edx, dword[ebp-44]		;.xbutton.button
	mov dword[ecx+4], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_mouse_press_event:

	cmp eax, dword[ButtonRelease]
	jne _consumeEvent_not_mouse_release_event
	
	mov edx, dword[MouseReleaseEvent]
	mov dword[ecx], edx
	
	mov edx, dword[ebp-44]		;.xbutton.button
	mov dword[ecx+4], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_mouse_release_event:
	
_consumeEvent_event_check_done:
	mov esp, ebp
	pop ebp
	ret
