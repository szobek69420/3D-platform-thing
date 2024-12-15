TEXT_ORIGIN_LEFT equ 0b00000001
TEXT_ORIGIN_HCENTER equ 0b00000010
TEXT_ORIGIN_RIGHT equ 0b00000100
TEXT_ORIGIN_TOP equ 0b00010000
TEXT_ORIGIN_VCENTER equ 0b00100000
TEXT_ORIGIN_BOTTOM equ 0b01000000

TEXT_ALIGN_TOP_LEFT equ 0b00010001
TEXT_ALIGN_TOP_CENTER equ 0b00010010
TEXT_ALIGN_TOP_RIGHT equ 0b00010100
TEXT_ALIGN_CENTER_LEFT equ 0b00100001
TEXT_ALIGN_CENTER_CENTER equ 0b00100010
TEXT_ALIGN_CENTER_RIGHT equ 0b00100100
TEXT_ALIGN_BOTTOM_LEFT equ 0b01000001
TEXT_ALIGN_BOTTOM_CENTER equ 0b01000010
TEXT_ALIGN_BOTTOM_RIGHT equ 0b01000100

	global TEXT_ALIGN_TOP_LEFT
	global TEXT_ALIGN_TOP_CENTER
	global TEXT_ALIGN_TOP_RIGHT
	global TEXT_ALIGN_CENTER_LEFT
	global TEXT_ALIGN_CENTER_CENTER
	global TEXT_ALIGN_CENTER_RIGHT
	global TEXT_ALIGN_BOTTOM_LEFT
	global TEXT_ALIGN_BOTTOM_CENTER
	global TEXT_ALIGN_BOTTOM_RIGHT

section .data
	TEXT_COLOUR dd 0xFFFFFFFF
	
	print_char_format db "%c",10,0
	print_string_format db "%s",10,0
	print_two_ints_format db "%d %d",10,0

section .text
	extern printf
	extern strlen

	extern FONT_CHAR_WIDTH
	extern FONT_CHAR_HEIGHT
	extern FONT_TABLE
	
	FONT_SCALE equ 2

	global textRenderer_setColour		;void textRenderer_setColour(int colour)
	global textRenderer_getTextWidth	;int textRenderer_getTextWidth(char* text)
	global textRenderer_getTextHeight	;int textRenderer_getTextHeight(char* text)
	global textRenderer_renderText		;void textRenderer_renderText(char* text, ScreenInfo* window, int x, int y, int alignment)
	
textRenderer_setColour:
	mov eax, dword[esp+4]
	mov dword[TEXT_COLOUR], eax
	ret
	
textRenderer_getTextWidth:
	mov eax, dword[esp+4]
	push eax
	call strlen
	add esp, 4
	
	mov ecx, FONT_CHAR_WIDTH
	inc ecx
	imul eax, ecx
	dec eax
	ret
	
textRenderer_getTextHeight:
	mov eax, FONT_CHAR_HEIGHT
	ret
	
textRenderer_renderText:
	push ebp
	mov ebp, esp
	
	sub esp, 4		;actual y pos
	sub esp, 4		;actual x pos
	
	
	;calculate horizontal position
	mov ecx, dword[ebp+24]		;alignment in ecx
	and ecx, TEXT_ORIGIN_LEFT
	cmp ecx, 0
	je _renderText_origin_not_left
		mov edx, dword[ebp+16]
		mov dword[ebp-8], edx
		jmp _renderText_origin_horizontal_done
	_renderText_origin_not_left:
	
	mov ecx, dword[ebp+24]		;alignment in ecx
	and ecx, TEXT_ORIGIN_HCENTER
	cmp ecx, 0
	je _renderText_origin_not_hcenter
		push dword[ebp+8]
		call textRenderer_getTextWidth
		shr eax, 1
		add esp, 4
		
		mov ecx, dword[ebp+12]
		mov ecx, dword[ecx+40]		;screen width in ecx
		shr ecx, 1
		
		sub ecx, eax
		add ecx, dword[ebp+16]
		mov dword[ebp-8], ecx
		
		jmp _renderText_origin_horizontal_done
	_renderText_origin_not_hcenter:
	
	mov ecx, dword[ebp+24]		;alignment in ecx
	and ecx, TEXT_ORIGIN_RIGHT
	cmp ecx, 0
	je _renderText_origin_not_right
		push dword[ebp+8]
		call textRenderer_getTextWidth
		add esp, 4
		
		mov ecx, dword[ebp+12]
		mov ecx, dword[ecx+40]		;screen width in ecx
		
		sub ecx, eax
		sub ecx, dword[ebp+16]
		mov dword[ebp-8], ecx
		
		jmp _renderText_origin_horizontal_done
	_renderText_origin_not_right:	
	_renderText_origin_horizontal_done:
	
	
	;calculate vertical position
	mov ecx, dword[ebp+24]		;alignment in ecx
	and ecx, TEXT_ORIGIN_TOP
	cmp ecx, 0
	je _renderText_origin_not_top
		mov edx, dword[ebp+20]
		mov dword[ebp-4], edx
		jmp _renderText_origin_vertical_done
	_renderText_origin_not_top:
	
	mov ecx, dword[ebp+24]		;alignment in ecx
	and ecx, TEXT_ORIGIN_VCENTER
	cmp ecx, 0
	je _renderText_origin_not_vcenter
		push dword[ebp+8]
		call textRenderer_getTextHeight
		shr eax, 1
		add esp, 4
		
		mov ecx, dword[ebp+12]
		mov ecx, dword[ecx+44]		;screen height in ecx
		shr ecx, 1
		
		sub ecx, eax
		add ecx, dword[ebp+20]
		mov dword[ebp-4], ecx
		
		jmp _renderText_origin_vertical_done
	_renderText_origin_not_vcenter:
	
	mov ecx, dword[ebp+24]		;alignment in ecx
	and ecx, TEXT_ORIGIN_BOTTOM
	cmp ecx, 0
	je _renderText_origin_not_bottom
		push dword[ebp+8]
		call textRenderer_getTextHeight
		add esp, 4
		
		mov ecx, dword[ebp+12]
		mov ecx, dword[ecx+44]		;screen height in ecx
		
		sub ecx, eax
		sub ecx, dword[ebp+20]
		mov dword[ebp-4], ecx
		
		jmp _renderText_origin_vertical_done
	_renderText_origin_not_bottom:	
	_renderText_origin_vertical_done:
	
	push dword[ebp-4]
	push dword[ebp-8]
	push dword[ebp+12]
	push dword[ebp+8]
	call textRenderer_renderTextInternal
	
	mov esp, ebp
	pop ebp
	ret
	
textRenderer_renderTextInternal:	;void textRenderer_renderTextInternal(char* text, ScreenInfo* window, int x, int y)
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	sub esp, 4		;screen buffer
	sub esp, 4		;window height
	sub esp, 4		;window width
	sub esp, 4		;current character y pos
	sub esp, 4		;current character x pos
	
	;obtain data
	mov eax, dword[ebp+24]
	mov ecx, dword[eax+32]
	mov dword[ebp-4], ecx
	mov ecx, dword[eax+40]
	mov dword[ebp-12], ecx
	mov ecx, dword[eax+44]
	mov dword[ebp-8], ecx
	
	mov ecx, dword[ebp+28]
	mov dword[ebp-20], ecx
	mov ecx, dword[ebp+32]
	mov dword[ebp-16], ecx
	
	
	mov eax, dword[ebp+20]	 ;current character
	mov ebx, dword[ebp-4]	;screen buffer
	mov esi, dword[ebp+28]	;current pixel x
	mov edi, dword[ebp+32]	;current pixel y
	mov cl, byte[eax]
	cmp cl, 0
	je _renderText_string_loop_end
	_renderText_string_loop_start:
		mov ecx, 0
		mov edi, dword[ebp-16]
		_renderText_character_y_loop_start:
			cmp edi, 0
			jl _renderText_character_y_loop_continue
			cmp edi, dword[ebp-8]
			jge _renderText_character_y_loop_end
			
			push ecx
			mov ecx, 0
			mov esi, dword[ebp-20]
			_renderText_character_x_loop_start:
				cmp esi, 0
				jl _renderText_character_x_loop_continue
				cmp esi, dword[ebp-12]
				jge _renderText_character_x_loop_end
				
				push ecx
				xor edx, edx
				mov dl, byte[eax]
				mov edx, dword[4*edx+FONT_TABLE]
				mov ecx, dword[esp+4]
				imul ecx, FONT_CHAR_WIDTH
				add ecx, dword[esp]
				add edx, ecx
				xor ecx, ecx
				mov cl, byte[edx]
				cmp ecx, 0
				je _renderText_no_colour				
					lea edx, [4*edi]
					imul edx, dword[ebp-12]
					lea edx, [edx+4*esi]
					mov ecx, dword[TEXT_COLOUR]
					mov dword[ebx+edx], ecx
				_renderText_no_colour:
				pop ecx
				
				_renderText_character_x_loop_continue:
				inc esi
				inc ecx
				cmp ecx, FONT_CHAR_WIDTH
				jl _renderText_character_x_loop_start
			_renderText_character_x_loop_end:
			pop ecx
			
			_renderText_character_y_loop_continue:
			inc edi
			inc ecx
			cmp ecx, FONT_CHAR_HEIGHT
			jl _renderText_character_y_loop_start
		_renderText_character_y_loop_end:
		mov edx, dword[ebp-20]
		add edx, FONT_CHAR_WIDTH
		inc edx
		mov dword[ebp-20], edx
		
		inc eax
		xor ecx, ecx
		mov cl, byte[eax]		
		cmp cl, 0
		jne _renderText_string_loop_start
	_renderText_string_loop_end:
	
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
