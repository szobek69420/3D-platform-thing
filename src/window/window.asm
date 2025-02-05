;my sources:
;Nir Lichtman @ yt
;Future Tech Labs @ yt
;croakingkero.com
;https://gist.github.com/nikAizuddin/6fbbc703f1213ab61a8a

;struct ScreenInfo{
;	Display* display;		0
;	Window window;			4
;	int deleteAtom;			8
;	Window root;			12
;	int screenNumber;		16
;	GC defaultGraphicsContext;	20
;	Visual* defaultVisual		24
;	char* drawbuffer		28
;	char* scalebuffer		32
;	XImage* image			36
;	int windowWidth			40
;	int windowHeight		44
;	int defaultDepth		48
;	short* columnOffsetInFBO	52
;	short* lineOffsetInFBO		56	;tells from which line of the drawBuffer the current line of the scaleBuffer should be sampled from
;}					60

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
;}  //size: 16 bytes

;struct MouseMotionEvent{
;	int x, y;
;}

;struct WindowCloseEvent{}

;struct KeyPressEvent and KeyReleaseEvent{
;	12 chars for the key info
;}

;struct WindowResizeEvent{
;	int width;
;	int height;
;}

;struct MousePressEvent and MouseReleaseEvent{
;	int button;
;}

section .rodata
	FRAMEBUFFER_WIDTH dd 500
	FRAMEBUFFER_HEIGHT dd 300
	FRAMEBUFFER_WIDTH_FLOAT dd 500.0
	FRAMEBUFFER_HEIGHT_FLOAT dd 300.0
	FRAMEBUFFER_BYTE_COUNT dd 600000	;500*300*4
	global FRAMEBUFFER_WIDTH
	global FRAMEBUFFER_HEIGHT
	global FRAMEBUFFER_WIDTH_FLOAT
	global FRAMEBUFFER_HEIGHT_FLOAT
	global FRAMEBUFFER_BYTE_COUNT
	
	INITIAL_WINDOW_WIDTH dd 800
	INITIAL_WINDOW_HEIGHT dd 600
	INITIAL_WINDOW_BYTE_COUNT dd 1920000

	create_error_message db "Couldn't open window sry :(",10,0
	print_int db "%d ",0
	window_title db "pee diddy",0
	atom_type db "WM_DELETE_WINDOW",0
	
	ZERO dd 0.0
	
	;x11 masks and event types
	PointerMotionMask equ 0x40
	MotionNotify equ 0x6
	
	StructureNotifyMask equ 0x20000
	DestroyNotify equ 0x11
	ClientMessage equ 0x21
	
	KeyPressMask equ 0x1
	KeyPress equ 0x2
	
	KeyReleaseMask equ 0x2
	KeyRelease equ 0x3
	
	ButtonPressMask equ 0x4
	ButtonPress equ 0x4
	ButtonReleaseMask equ 0x8
	ButtonRelease equ 0x5
	
	ConfigureNotify equ 0x16
	
	;my event types
	NoEvent equ 0
	MouseMotionEvent equ 1
	WindowCloseEvent equ 2
	KeyPressEvent equ 3
	KeyReleaseEvent equ 4
	WindowResizeEvent equ 5		;window resize event is also generated when the window is moved
	MousePressEvent equ 6
	MouseReleaseEvent equ 7		;mouseevents detect scrolls too
	
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
	extern malloc
	extern free
	extern memset
	extern memcpy

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
	extern XDefaultVisual
	extern XDefaultGC
	extern XDefaultDepth
	extern XCreateImage
	extern XDestroyImage
	extern XPutImage
	
	extern XUnmapWindow
	extern XDestroyWindow
	extern XCloseDisplay
	
	extern XSelectInput
	extern XPending
	extern XNextEvent
	extern XKeycodeToKeysym
	extern XKeysymToString
	extern XAutoRepeatOff
	
	extern XQueryPointer
	extern XWarpPointer
	extern XDefineCursor
	
	
	global window_create		;void window_create(ScreenInfo* buffer)
	global window_destroy		;void window_destroy(ScreenInfo* window)
	
	global window_pendingEvent	;int window_pendingEvent(ScreenInfo* window);		//returns the number of pending events
	global window_consumeEvent	;void window_pendingEvent(ScreenInfo* window, Event* buffer)
	global window_onResize		;void window_onResize(ScreenInfo* window);
	
	global window_scaleBuffer	;void window_scaleBuffer(ScreenInfo* window);	;draws the drawbuffer into the scale buffer
	global window_showFrame		;void window_showFrame(ScreenInfo* window);	;draws the scale buffer onto the screen
		
	global window_clearDrawBuffer	;void window_clear(ScreenInfo* window, int clearColour)
	
	global window_getCursorPosition	;void window_getCursorPosition(ScreenInfo* window, int* x, int* y)
	global window_setCursorPosition	;void window_setCursorPosition(ScreenInfo* window, int x, int y)
	global window_hideCursor	;void window_hideCursor(ScreenInfo* window)
	
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
	mov dword[ebx+16], eax	;save screen number
	add esp, 4
	
	push eax
	push dword[ebx]
	call XRootWindow
	mov esi, eax		;root window in esi
	mov dword[ebx+12], eax	;save root window
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
	
	push 1					;border width
	push dword[INITIAL_WINDOW_HEIGHT]	;window height
	push dword[INITIAL_WINDOW_WIDTH]	;window width
	push 50					;y pos
	push 50					;x pos
	push esi				;root window
	push dword[ebx]				;display*
	call XCreateSimpleWindow
	mov dword[ebx+4], eax			;save window
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
	mov eax, PointerMotionMask
	or eax, StructureNotifyMask
	or eax, KeyPressMask
	or eax, KeyReleaseMask
	or eax, ButtonPressMask
	or eax, ButtonReleaseMask
	
	push eax
	push dword[ebx+4]
	push dword[ebx]
	call XSelectInput
	add esp, 12
	
	;get graphics context ,visual, default depth
	push dword[ebx+16]	;screen number
	push dword[ebx]		;display
	call XDefaultGC
	mov dword[ebx+20], eax	;save GC
	call XDefaultVisual
	mov dword[ebx+24], eax	;save Visual
	call XDefaultDepth
	mov dword[ebx+48], eax	;save default depth
	add esp, 8
	
	;alloc framebuffer and set width, height
	push dword[FRAMEBUFFER_BYTE_COUNT]
	call malloc
	mov dword[ebx+28], eax		;save framebuffer
	add esp ,4
	
	mov dword[ebx+32], 0		;zero screen buffer, so that window_onResize doesn't try to delete it
	
	mov eax, dword[INITIAL_WINDOW_WIDTH]
	mov dword[ebx+40], eax
	mov eax, dword[INITIAL_WINDOW_HEIGHT]
	mov dword[ebx+44], eax
	
	;call window_onResize
	push ebx
	call window_onResize
	add esp, 4
	
	
	;set window title
	push window_title
	push dword[ebx+4]
	push dword[ebx]
	call XStoreName
	add esp, 12
	
	;turn off repeated keystrokes
	push dword[ebx]
	call XAutoRepeatOff
	add esp, 4
	
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
	
	;free draw buffer
	mov eax, dword[ebp+8]	;window in eax
	push dword[eax+28]
	call free
	add esp, 4
	
	;free scale buffer
	mov eax, dword[ebp+8]	;window in eax
	push dword[eax+36]
	call XDestroyImage
	add esp, 4
	
	;free line and column offsets
	mov eax, dword[ebp+8]	;window in eax
	push dword[eax+52]
	push dword[eax+56]
	call free
	add esp, 4
	call free
	add esp, 4
	
	;clean up x11 things
	mov eax, dword[ebp+8]	;window in eax
	
	push dword[eax+4]
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
	
	mov eax, NoEvent
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
	
	
	cmp eax, DestroyNotify
	jne _consumeEvent_not_window_close_event
	
	mov edx, WindowCloseEvent
	mov dword[ecx], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_window_close_event:

	cmp eax, ConfigureNotify
	jne _consumeEvent_not_window_resize_event
	
	mov edx, WindowResizeEvent
	mov dword[ecx], edx
	
	mov edx, dword[ebp-64]		;.xconfigure.width
	mov dword[ecx+4], edx
	
	mov edx, dword[ebp-60]		;.xconfigure.height
	mov dword[ecx+8], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_window_resize_event:
	
	cmp eax, MotionNotify
	jne _consumeEvent_not_mouse_motion_event
	
	mov edx, MouseMotionEvent
	mov dword[ecx], edx
	
	mov edx, dword[ebp-64]		;.xmotion.x
	mov dword[ecx+4], edx
	
	mov edx, dword[ebp-60]		;.xmotion.y
	mov dword[ecx+8], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_mouse_motion_event:

	cmp eax, KeyPress
	jne _consumeEvent_not_key_press_event
	
	mov edx, KeyPressEvent
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
	
	;copy the keystring
	push esi
	push edi
	push ebx
	
	lea esi, [edx-1]		;the keystring in esi
	mov edi, 0xFFFFFFFF
	jmp _consumeEvent_key_press_copy_loop_continue
_consumeEvent_key_press_copy_loop_start:
	mov bl, byte[esi]
	mov byte[ecx+edi+4], bl
_consumeEvent_key_press_copy_loop_continue:
	inc esi
	inc edi
	cmp edi, 11
	je _consumeEvent_key_press_copy_loop_end
	mov bl, byte[esi]
	cmp bl, 0
	je _consumeEvent_key_press_copy_loop_end
	jmp _consumeEvent_key_press_copy_loop_start
_consumeEvent_key_press_copy_loop_end:
	mov byte[ecx+edi+4],0
	
	pop ebx
	pop edi
	pop esi
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_key_press_event:

	cmp eax, KeyRelease
	jne _consumeEvent_not_key_release_event
	
	mov edx, KeyReleaseEvent
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
	
	;copy the keystring
	push esi
	push edi
	push ebx
	
	lea esi, [edx-1]		;the keystring in esi
	mov edi, 0xFFFFFFFF
	jmp _consumeEvent_key_release_copy_loop_continue
_consumeEvent_key_release_copy_loop_start:
	mov bl, byte[esi]
	mov byte[ecx+edi+4], bl
_consumeEvent_key_release_copy_loop_continue:
	inc esi
	inc edi
	cmp edi, 11
	je _consumeEvent_key_release_copy_loop_end
	mov bl, byte[esi]
	cmp bl, 0
	je _consumeEvent_key_release_copy_loop_end
	jmp _consumeEvent_key_release_copy_loop_start
_consumeEvent_key_release_copy_loop_end:
	mov byte[ecx+edi+4],0
	
	pop ebx
	pop edi
	pop esi
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_key_release_event:

	cmp eax, ButtonPress
	jne _consumeEvent_not_mouse_press_event
	
	mov edx, MousePressEvent
	mov dword[ecx], edx
	
	mov edx, dword[ebp-44]		;.xbutton.button
	mov dword[ecx+4], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_mouse_press_event:

	cmp eax, ButtonRelease
	jne _consumeEvent_not_mouse_release_event
	
	mov edx, MouseReleaseEvent
	mov dword[ecx], edx
	
	mov edx, dword[ebp-44]		;.xbutton.button
	mov dword[ecx+4], edx
	
	jmp _consumeEvent_event_check_done
_consumeEvent_not_mouse_release_event:
	
_consumeEvent_event_check_done:
	mov esp, ebp
	pop ebp
	ret
	
	
window_scaleBuffer:
	push ebp
	push esi
	push edi
	push ebx
	mov ebp, esp
	
	mov ebx, dword[ebp+20]		;window in ebx
	
	;copy the draw buffer into the scalebuffer
	push dword[FRAMEBUFFER_WIDTH]
	shl dword[esp], 2		;bytecount per line in the draw buffer
	
	mov eax, dword[ebx+40]
	shl eax, 1
	add eax, dword[ebx+52]
	push eax			;the end pointer of the columnIndexBuffer
	
	mov eax, dword[ebx+44]
	shl eax, 1
	add eax, dword[ebx+56]
	push eax			;the end pointer of the lineIndexBuffer
	
	
	mov eax, dword[ebx+32]			;current pixel in the scale bufffer
	
	mov edi, dword[ebx+56]			;the index of the current line
	_scaleBuffer_copy_outer_loop_start:
		xor ecx, ecx
		mov cx, word[edi]
		imul ecx, dword[esp+8]
		add ecx, dword[ebx+28]
		
		mov esi, dword[ebx+52]			;the index of the current column
		_scaleBuffer_copy_inner_loop_start:
			
			xor edx, edx
			mov dx, word[esi]
			mov edx, dword[ecx+4*edx]
			mov dword[eax], edx
			
			add eax, 4
			add esi, 2
			cmp esi, dword[esp+4]
			jl _scaleBuffer_copy_inner_loop_start
		
		add edi, 2
		cmp edi, dword[esp]
		jl _scaleBuffer_copy_outer_loop_start
		add esp, 12
	
	mov esp, ebp
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret
	
	
window_showFrame:
	push ebp
	push esi
	push edi
	push ebx
	mov ebp, esp
	
	mov ebx, dword[ebp+20]		;window in ebx
	
	;put image
	push dword[ebx+44]
	push dword[ebx+40]
	push 0
	push 0
	push 0
	push 0
	push dword[ebx+36]
	push dword[ebx+20]
	push dword[ebx+4]
	push dword[ebx]
	call XPutImage
	add esp, 40
	
	
	mov esp, ebp
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret
	
	
window_onResize:
	push ebp
	push ebx
	mov ebp, esp
	
	mov ebx, dword[ebp+12]		;window in ebx
	
	;delete previous values
	mov eax, dword[ebx+32]
	cmp eax, 0
	je _onResize_no_dealloc
	
	push dword[ebx+36]
	call XDestroyImage
	add esp, 4
	
	;push dword[ebx+32]
	;call free		;XDestroyImage also frees ximage->data, so the scaleBuffer
	push dword[ebx+52]
	call free
	push dword[ebx+56]
	call free
	add esp, 8
	
_onResize_no_dealloc:
	
	;allocate the new scale buffer
	mov eax, dword[ebx+40]
	imul eax, dword[ebx+44]
	imul eax, 4
	push eax
	call malloc
	mov dword[ebx+32], eax	;save new data
	add esp, 4
	
	;allocate index buffers
	mov eax, dword[ebx+40]
	shl eax, 1		;width*2 in eax
	push eax
	call malloc
	mov dword[ebx+52], eax	;save columnIndexBuffer
	add esp, 4
	
	mov eax, dword[ebx+44]
	shl eax, 1		;height*2 in eax
	push eax
	call malloc
	mov dword[ebx+56], eax	;save lineIndexBuffer
	add esp, 4
	
	;create new image
	push 0
	push 32
	push dword[ebx+44]
	push dword[ebx+40]
	push dword[ebx+32]
	push 0
	push 0x2		;ZPixmap
	push dword[ebx+48]
	push dword[ebx+24]
	push dword[ebx]
	call XCreateImage
	mov dword[ebx+36], eax	;save image
	add esp, 40
	
	;calculate column index buffer
	fild dword[FRAMEBUFFER_WIDTH]
	fild dword[ebx+40]
	fdivp			;delta in ST(1)
	fild dword[ZERO]	;current index float in ST(0)
	mov eax, dword[ebx+40]
	mov ecx, dword[ebx+52]		;current elements
_onResize_calculate_column_loop_start:
	
	fld st0			;duplicate st0
	fisttp word[ecx]	;pop truncated integer (there is no such instruction without pop)
	fadd st0, st1
	
	add ecx, 2
	dec eax
	cmp eax, 0
	jg _onResize_calculate_column_loop_start
	fstp st0
	fstp st0
	
	
	;calculate line index buffer
	fild dword[FRAMEBUFFER_HEIGHT]
	fild dword[ebx+44]
	fdivp			;delta in ST(1)
	fild dword[ZERO]	;current index float in ST(0)
	mov eax, dword[ebx+44]
	mov ecx, dword[ebx+56]		;current elements
_onResize_calculate_line_loop_start:
	
	fld st0			;duplicate st0
	fisttp word[ecx]	;pop truncated integer (there is no such instruction without pop)
	fadd st0, st1
	
	add ecx, 2
	dec eax
	cmp eax, 0
	jg _onResize_calculate_line_loop_start
	fstp st0
	fstp st0
	
	mov esp, ebp
	pop ebx
	pop ebp
	ret
	
	
window_clearDrawBuffer:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	mov eax, dword[eax+28]		;drawbuffer in eax
	mov ecx, eax
	add eax, dword[FRAMEBUFFER_BYTE_COUNT]
	sub eax, 4
	
	mov edx, dword[ebp+12]		;colour in edx
_clearDrawBuffer_loop_start:
	mov dword[eax], edx
	sub eax, 4
	cmp eax, ecx
	jge _clearDrawBuffer_loop_start
	
	mov esp, ebp
	pop ebp 
	ret
	
	
	
window_getCursorPosition:
	push ebp
	mov ebp, esp
	
	sub esp, 4		;alloc space for trash
	
	mov eax, dword[ebp+8]		;window in eax
	mov ecx, esp
	
	push ecx
	mov edx, dword[ebp+16]
	push edx
	mov edx, dword[ebp+12]
	push edx
	push ecx
	push ecx
	push ecx
	push ecx
	push dword[eax+4]
	push dword[eax]
	call XQueryPointer
	
	mov esp, ebp
	pop ebp
	ret
	
	
window_setCursorPosition:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]		;window in eax
	
	push dword[ebp+16]
	push dword[ebp+12]
	push 0
	push 0
	push 0
	push 0
	push dword[eax+4]
	push 0
	push dword[eax]
	call XWarpPointer
	call XFlush
	
	
	mov esp, ebp
	pop ebp
	ret
	
	
window_hideCursor:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	
	push 0
	push dword[eax+4]
	push dword[eax]
	call XDefineCursor
	call XFlush
	
	mov esp, ebp
	pop ebp
	ret
