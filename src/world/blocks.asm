;block side order
;neg z
;neg x
;pos z
;pos x
;pos y
;neg y


;blocks
BLOCK_AIR equ 0
BLOCK_GRASS equ 1
BLOCK_DIRT equ 2
BLOCK_STONE equ 3

global BLOCK_AIR
global BLOCK_GRASS
global BLOCK_DIRT
global BLOCK_STONE

section .rodata

	;block colours (argb)
	BLOCK_COLOUR_INDEX dd BLOCK_AIR_COLOURS, BLOCK_GRASS_COLOURS, BLOCK_DIRT_COLOURS, BLOCK_STONE_COLOURS
	global BLOCK_COLOUR_INDEX
	
	BLOCK_AIR_COLOURS dd 0,0,0,0,0,0
	BLOCK_GRASS_COLOURS dd 0xFF0A780A, 0xFF096C09, 0xFF075407, 0xFF086008, 0xFF0B840B, 0xFF064806
	BLOCK_DIRT_COLOURS dd 0xFF8C5E24, 0xFF7D4120, 0xFF5F3018, 0xFF6E381C, 0xFF9B5328, 0xFF502818
	BLOCK_STONE_COLOURS dd 0xFF7D7D7D, 0xFF6E6E6E, 0xFF505050, 0xFF5F5F5F, 0xFF8C8C8C, 0xFF414141
	
	global BLOCK_AIR_COLOURS
	global BLOCK_GRASS_COLOURS
	global BLOCK_DIRT_COLOURS
	global BLOCK_STONE_COLOURS
	
	;block vertices
	BLOCK_VERTICES_INDEX dd BLOCK_VERTICES_NEG_Z, BLOCK_VERTICES_NEG_X, BLOCK_VERTICES_POS_Z, BLOCK_VERTICES_POS_X, BLOCK_VERTICES_POS_Y, BLOCK_VERTICES_NEG_Y
	BLOCK_VERTICES_NEG_Z dd -0.5, -0.5, -0.5,  0.5, -0.5, -0.5,  0.5, 0.5, -0.5,  -0.5, 0.5, -0.5
	BLOCK_VERTICES_NEG_X dd -0.5, -0.5, 0.5,  -0.5, -0.5, -0.5,  -0.5, 0.5, -0.5,  -0.5, 0.5, 0.5
	BLOCK_VERTICES_POS_Z dd 0.5, -0.5, 0.5,  -0.5, -0.5, 0.5,  -0.5, 0.5, 0.5,  0.5, 0.5, 0.5
	BLOCK_VERTICES_POS_X dd 0.5, -0.5, -0.5,  0.5, -0.5, 0.5,  0.5, 0.5, 0.5,  0.5, 0.5, -0.5
	BLOCK_VERTICES_POS_Y dd 0.5, 0.5, 0.5,  -0.5, 0.5, 0.5,  -0.5, 0.5, -0.5,  0.5, 0.5, -0.5
	BLOCK_VERTICES_NEG_Y dd 0.5, -0.5, -0.5,  -0.5, -0.5, -0.5,  -0.5, -0.5, 0.5,  0.5, -0.5, 0.5
	
	global BLOCK_VERTICES_INDEX
	global BLOCK_VERTICES_NEG_Z
	global BLOCK_VERTICES_NEG_X
	global BLOCK_VERTICES_POS_Z
	global BLOCK_VERTICES_POS_X
	global BLOCK_VERTICES_POS_Y
	global BLOCK_VERTICES_NEG_Y
	
	;block indices
	BLOCK_INDICES dd 1,2,0, 0,2,3
	global BLOCK_INDICES
	
	
	TERRAIN_GEN_HELPER_1 dd 0.013
	TERRAIN_GEN_HELPER_2 dd 0.021
	TERRAIN_GEN_HELPER_3 dd 15.0
	TERRAIN_GEN_HELPER_4 dd 18.0
	
	
section .text
	global blocks_getTerrainHeight		;extern int blocks_getTerrainHeight(int x, int z)
	
blocks_getTerrainHeight:
	push ebp
	mov ebp, esp
	
	sub esp, 4		;float x
	sub esp, 4		;float z
	sub esp, 4		;float height
	
	;convert arguments to float
	fild dword[ebp+8]
	fstp dword[ebp-4]
	fild dword[ebp+12]
	fstp dword[ebp-8]
	
	;temporary function
	movss xmm0, dword[TERRAIN_GEN_HELPER_1]
	movss xmm1, dword[ebp-4]
	mulss xmm0, xmm1
	
	movss xmm1, dword[TERRAIN_GEN_HELPER_2]
	movss xmm2, dword[ebp-8]
	mulss xmm1, xmm2
	addss xmm0, xmm1
	movss dword[ebp-12], xmm0
	
	fld dword[ebp-12]
	fsin
	fstp dword[ebp-12]
	
	movss xmm0, dword[TERRAIN_GEN_HELPER_3]
	movss xmm1, dword[ebp-12]
	mulss xmm0, xmm1
	movss xmm1, dword[TERRAIN_GEN_HELPER_4]
	addss xmm0, xmm1
	movss dword[ebp-12], xmm0
	
	;convert the result to int
	fld dword[ebp-12]
	fistp dword[ebp-12]
	
	mov eax, dword[ebp-12]
	
	mov esp, ebp
	pop ebp
	ret
