section .rodata
	
	FONT_TABLE:
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_COMMA
		dd TEXT_SPACE
		dd TEXT_DOT
		dd TEXT_SPACE
		
		dd TEXT_0
		dd TEXT_1
		dd TEXT_2
		dd TEXT_3
		dd TEXT_4
		dd TEXT_5
		dd TEXT_6
		dd TEXT_7
		
		dd TEXT_8
		dd TEXT_9
		dd TEXT_COLON
		dd TEXT_SEMICOLON
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		
		dd TEXT_A
		dd TEXT_B
		dd TEXT_C
		dd TEXT_D
		dd TEXT_E
		dd TEXT_F
		dd TEXT_G
		dd TEXT_H
		
		dd TEXT_I
		dd TEXT_J
		dd TEXT_K
		dd TEXT_L
		dd TEXT_M
		dd TEXT_N
		dd TEXT_O
		dd TEXT_P
		
		dd TEXT_Q
		dd TEXT_R
		dd TEXT_S
		dd TEXT_T
		dd TEXT_U
		dd TEXT_V
		dd TEXT_W
		dd TEXT_X
		
		dd TEXT_Y
		dd TEXT_Z
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
		dd TEXT_SPACE
	
	TEXT_SPACE:
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	
	TEXT_COMMA:
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 1, 1, 0, 0, 0
	db 0, 1, 1, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	
	TEXT_DOT:
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	
	TEXT_COLON:
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	
	TEXT_SEMICOLON:
	db 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 1, 1, 0, 0, 0
	db 0, 1, 1, 0, 0, 0
	db 0, 0, 0, 0, 0, 0
	db 0, 1, 1, 0, 0, 0
	db 0, 1, 1, 0, 0, 0
	db 1, 1, 0, 0, 0, 0

	TEXT_A:
	db 0, 0, 1, 1, 0, 0
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	
	TEXT_B:
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 1, 1, 1, 0
	
	TEXT_C:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_D:
	db 1, 1, 1, 1, 0, 0
	db 1, 1, 0, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 1, 1, 0
	db 1, 1, 1, 1, 0, 0
	
	TEXT_E:
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 1, 1, 1, 1
	
	TEXT_F:
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	
	TEXT_G:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 1, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_H:
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	
	TEXT_I:
	db 0, 1, 1, 1, 1, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 1, 1, 1, 1, 0
	
	TEXT_J:
	db 0, 0, 1, 1, 1, 1
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 0, 1, 1, 0
	db 1, 1, 0, 1, 1, 0
	db 0, 1, 1, 1, 0, 0
	
	TEXT_K:
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 1, 1, 0
	db 1, 1, 1, 1, 0, 0
	db 1, 1, 1, 0, 0, 0
	db 1, 1, 1, 1, 0, 0
	db 1, 1, 0, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	
	TEXT_L:
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 1, 1, 1, 1
	
	TEXT_M:
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 1, 0, 1, 1
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 0, 1, 0, 1
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 0, 0, 0, 1
	
	TEXT_N:
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 1, 0, 1, 1
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 0, 1, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	
	TEXT_O:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_P:
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	
	TEXT_Q:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	db 0, 0, 0, 1, 1, 1
	
	TEXT_R:
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 1, 1, 0, 0
	db 1, 1, 0, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	
	TEXT_S:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 0, 0
	db 0, 1, 1, 1, 1, 0
	db 0, 0, 0, 0, 1, 1
	db 0, 0, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_T:
	db 1, 1, 1, 1, 1, 1
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	
	TEXT_U:
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_V:
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	db 0, 0, 1, 1, 0, 0
	
	TEXT_W:
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 0, 0, 0, 1
	db 1, 1, 0, 1, 0, 1
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 0, 1, 1
	db 1, 1, 0, 0, 0, 1
	
	TEXT_X:
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	
	TEXT_Y:
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	
	TEXT_Z:
	db 1, 1, 1, 1, 1, 1
	db 0, 0, 0, 0, 1, 1
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 1, 1, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 1, 1, 1, 1
	
	TEXT_0:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 1, 1, 1
	db 1, 1, 1, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_1:
	db 0, 0, 1, 1, 0, 0
	db 0, 1, 1, 1, 0, 0
	db 1, 1, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 1, 1, 1, 1, 1, 1
	
	TEXT_2:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 0, 0, 0, 0, 1, 1
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 1, 1, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 1, 1, 1, 1
	
	TEXT_3:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 0, 0, 0, 0, 1, 1
	db 0, 0, 1, 1, 1, 0
	db 0, 0, 0, 0, 1, 1
	db 0, 0, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_4:
	db 0, 0, 0, 0, 1, 0
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 1, 1, 1, 0
	db 0, 1, 0, 1, 1, 0
	db 1, 1, 1, 1, 1, 1
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 0, 1, 1, 0
	
	TEXT_5:
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 1, 1, 1, 0
	db 0, 0, 0, 0, 1, 1
	db 0, 0, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_6:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 0, 0
	db 1, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_7:
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 0, 0, 1, 1, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	
	TEXT_8:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
	
	TEXT_9:
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 1
	db 0, 0, 0, 0, 1, 1
	db 0, 0, 0, 0, 1, 1
	db 1, 1, 0, 0, 1, 1
	db 0, 1, 1, 1, 1, 0
