section .rodata
	debug_message db "sugus",10,0
	debug_print_string db "%s",10,0

	KEY_LEFT equ 11
	KEY_RIGHT equ 12
	KEY_UP equ 13
	KEY_DOWN equ 14
	KEY_LEFT_STRING db "Left",0
	KEY_RIGHT_STRING db "Right",0
	KEY_UP_STRING db "Up",0
	KEY_DOWN_STRING db "Down",0

	KEY_ESCAPE equ 27
	KEY_ESCAPE_STRING db "Escape",0
	KEY_SHIFT equ 31
	KEY_SHIFT_STRING db "Shift_L",0
	KEY_SPACE equ 32
	KEY_SPACE_STRING db "space",0
	
	KEY_NON_DIGIT_COUNT equ 7
	KEY_NON_DIGIT_STRINGS dd KEY_LEFT_STRING, KEY_RIGHT_STRING, KEY_UP_STRING, KEY_DOWN_STRING, KEY_ESCAPE_STRING, KEY_SHIFT_STRING, KEY_SPACE_STRING
	KEY_NON_DIGIT_CODES dd KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_ESCAPE, KEY_SHIFT, KEY_SPACE

	KEY_0 equ 48
	KEY_1 equ 49
	KEY_2 equ 50
	KEY_3 equ 51
	KEY_4 equ 52
	KEY_5 equ 53
	KEY_6 equ 54
	KEY_7 equ 55
	KEY_8 equ 56
	KEY_9 equ 57

	KEY_A equ 97
	KEY_B equ 98
	KEY_C equ 99
	KEY_D equ 100
	KEY_E equ 101
	KEY_F equ 102
	KEY_G equ 103
	KEY_H equ 104
	KEY_I equ 105
	KEY_J equ 106
	KEY_K equ 107
	KEY_L equ 108
	KEY_M equ 109
	KEY_N equ 110
	KEY_O equ 111
	KEY_P equ 112
	KEY_Q equ 113
	KEY_R equ 114
	KEY_S equ 115
	KEY_T equ 116
	KEY_U equ 117
	KEY_V equ 118
	KEY_W equ 119
	KEY_X equ 120
	KEY_Y equ 121
	KEY_Z equ 122
	
	
	global KEY_A
	global KEY_B
	global KEY_C
	global KEY_D
	global KEY_E
	global KEY_F
	global KEY_G
	global KEY_H
	global KEY_I
	global KEY_J
	global KEY_K
	global KEY_L
	global KEY_M
	global KEY_N
	global KEY_O
	global KEY_P
	global KEY_Q
	global KEY_R
	global KEY_S
	global KEY_T
	global KEY_U
	global KEY_V
	global KEY_W
	global KEY_X
	global KEY_Y
	global KEY_Z
	
	global KEY_0
	global KEY_1
	global KEY_2
	global KEY_3
	global KEY_4
	global KEY_5
	global KEY_6
	global KEY_7
	global KEY_8
	global KEY_9
	
	global KEY_LEFT
	global KEY_RIGHT
	global KEY_UP
	global KEY_DOWN
	
	global KEY_SPACE
	global KEY_ESCAPE
	global KEY_SHIFT
	
section .bss
	key_held resb 128	;one, if the key has been held for more than one frame
	key_pressed resb 128	;one, if the key has just been pressed (one for one frame)
	key_released resb 128	;one, if the key has just been released (one for one frame)
	
section .text
	extern printf
	extern memcpy
	extern memset
	extern strlen
	extern strcmp
	
	extern KeyPressEvent
	extern KeyReleaseEvent
	
	global input_init		;void input_init()
	global input_update		;void input_update()
	global input_processEvent	;void input_processEvent(Event* event)  //Event is the struct Event from the window file
	
	global input_isKeyPressed	;int input_isKeyPressed(int keycode)
	global input_isKeyHeld		;int input_isKeyHeld(int keycode)
	global input_isKeyReleased	;int input_isKeyReleased(int keycode) //true if it has just been released, so not the inverse of the input_isKeyHeld function
	
input_init:
	push ebp
	mov ebp, esp
	
	push 128
	push 0
	push key_held
	call memset
	mov dword[esp], key_pressed
	call memset
	mov dword[esp], key_released
	call memset
	add esp, 12
	
	mov esp, ebp
	pop ebp
	ret
	
input_update:
	push ebp
	mov ebp, esp
	
	xor eax, eax
_update_loop_start:
	mov cl, byte[eax+key_held]
	or cl, byte[eax+key_pressed]
	mov dl, 1
	sub dl, byte[eax+key_released]
	and cl, dl
	mov byte[eax+key_held], cl
	
	inc eax
	cmp eax, 128
	jl _update_loop_start
	
	
	push 128
	push 0
	push key_pressed
	call memset
	mov dword[esp], key_released
	call memset
	add esp, 12
	
	mov esp, ebp
	pop ebp
	ret
	
	
input_processEvent:
	push ebp
	push esi
	push edi
	push ebx
	mov ebp, esp
	
	
	mov ebx, dword[ebp+20]		;event in ebx
	
	mov esi, dword[ebx]		;event type in esi
	
	
	cmp esi, KeyPressEvent
	jne _processEvent_not_key_press
	mov edi, key_pressed
	jmp _processEvent_key_event
_processEvent_not_key_press:
	cmp esi, KeyReleaseEvent
	jne _processEvent_not_key_event
	mov edi, key_released
_processEvent_key_event:	
	
	lea eax, [ebx+4]
	push eax
	call strlen
	cmp eax, 1
	jne _processEvent_key_event_not_single_digit
	
	xor ecx, ecx
	mov cl, byte[ebx+4]
	mov byte[edi+ecx], 1
	jmp _processEvent_done
	
_processEvent_key_event_not_single_digit:

	add ebx, 4
	mov esi, 0
_processEvent_key_event_not_single_digit_loop_start:

	push ebx
	push dword[4*esi+KEY_NON_DIGIT_STRINGS]
	call strcmp
	add esp, 8
	cmp eax, 0
	jne _processEvent_key_event_not_single_digit_loop_continue
	
	mov ecx, dword[4*esi+KEY_NON_DIGIT_CODES]
	mov dword[edi+ecx], 1
	jmp _processEvent_done
_processEvent_key_event_not_single_digit_loop_continue:
	inc esi
	cmp esi, KEY_NON_DIGIT_COUNT
	jl _processEvent_key_event_not_single_digit_loop_start
	
_processEvent_not_key_event:
	
	
_processEvent_done:
	mov esp, ebp
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret
	
	
input_isKeyPressed:
	mov ecx, dword[esp+4]
	xor eax, eax
	mov al, byte[ecx+key_pressed]
	ret
	
input_isKeyReleased:
	mov ecx, dword[esp+4]
	xor eax, eax
	mov al, byte[ecx+key_released]
	ret
	
input_isKeyHeld:
	mov ecx, dword[esp+4]
	xor eax, eax
	mov al, byte[ecx+key_held]
	ret

