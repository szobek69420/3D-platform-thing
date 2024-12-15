section .data
	TEXT_COLOUR dd 0xFFFFFFFF
	
	print_char_format db "%c",10,0
	print_string_format db "%s",10,0
	print_two_ints_format db "%d %d",10,0

section .text
	extern printf

	extern FONT_CHAR_WIDTH
	extern FONT_CHAR_HEIGHT
	extern FONT_TABLE
	
	FONT_SCALE equ 2


	global textRenderer_renderText		;void textRenderer_renderText(char* text, ScreenInfo* window, int x, int y)
	
	
textRenderer_renderText:
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
					mov dword[ebx+edx], 0xFFFFFFFF
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
