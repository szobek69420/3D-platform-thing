;layout
;struct chunk{
;	int chunkX, chunkZ;			;0
;	char* blocks; //y,x,z			;8
;	renderable* mesh;			;12
;	colliderGroup* cg;			;16
;} //20 bytes

CHUNK_WIDTH equ 16
CHUNK_HEIGHT equ 50
CHUNK_WIDTH_PLUS_TWO equ 18
CHUNK_HEIGHT_PLUS_TWO equ 52

section .rodata
	print_chunk_count db "Active chunk count: %d",10,0
	print_chunk_generation_error db "Couldn't create chunk x=%d z=%d lol",10,0

section .data
	chunkCount dd 0
	
section .text
	extern printf
	extern malloc
	extern free
	extern memset
	extern memcpy
	
	extern vector_init
	extern vector_push_back
	extern vector_destroy
	
	extern renderable_create
	extern renderable_destroy
	
	
	global chunk_printChunkCount			;void chunk_printChunkCount()
	
	global chunk_generateChunk			;chunk* chunk_generateChunk(int seed, int chunkX, int chunkZ)
	global chunk_destroyChunk			;void chunk_destroyChunk(chunk* chunk)
	
chunk_printChunkCount:
	push dword[chunkCount]
	push print_chunk_count
	call printf
	add esp, 8
	ret
	
	

chunk_generateChunk:
	push ebp
	push ebx
	push esi
	push edi
	mov ebp, esp
	
	sub esp, 4		;chunk*
	sub esp, 16		;vector<vec3> vertices
	sub esp, 16		;vector<int> indices
	sub esp, 16		;vector<int> colours
	
	
	;alloc chunk
	push 20
	call malloc
	add esp, 4
	mov dword[ebp-4], eax	;save chunk
	cmp eax, 0
	jne _generateChunk_chunk_malloc_no_error
	
	push dword[ebp+28]
	push dword[ebp+24]
	push print_chunk_generation_error
	call printf
	add esp, 12
	xor eax, eax
	jmp _generateChunk_done
	
_generateChunk_chunk_malloc_no_error:
	
	;alloc chunk renderable
	push 84
	call malloc
	add esp, 4
	mov ecx, dword[ebp-4]
	mov dword[ecx+12],eax	;save renderable
	
	cmp eax, 0
	jne _generateChunk_chunk_renderable_malloc_no_error
	
	push dword[ebp-4]
	call free
	add esp, 4
	
	push dword[ebp+28]
	push dword[ebp+24]
	push print_chunk_generation_error
	call printf
	add esp, 12
	xor eax, eax
	jmp _generateChunk_done
	
_generateChunk_chunk_renderable_malloc_no_error:

	;alloc chunk blocks
	mov eax, CHUNK_WIDTH_PLUS_TWO
	imul eax, CHUNK_WIDTH_PLUS_TWO
	imul eax CHUNK_HEIGHT_PLUS_TWO
	
	push eax
	call malloc
	add esp, 4
	mov ecx, dword[ebp-4]
	mov dword[ecx+8], eax
	
	cmp eax, 0
	jne _generateChunk_chunk_blocks_malloc_no_error
	
	mov eax, dword[ebp-4]
	push dword[eax+12]
	call free
	add esp, 4
	
	push dword[ebp-4]
	call free
	add esp, 4
	
	push dword[ebp+28]
	push dword[ebp+24]
	push print_chunk_generation_error
	call printf
	add esp, 12
	xor eax, eax
	jmp _generateChunk_done
	
_generateChunk_chunk_blocks_malloc_no_error:

	;init temp vectors
	lea eax, [ebp-20]
	push 12
	push eax
	call vector_init
	add esp, 8
	
	lea eax, [ebp-36]
	push 4
	push eax
	call vector_init
	add esp, 8
	
	lea eax[ebp-52]
	push 4
	push eax
	call vector_init
	add esp, 8
	
	
	;construct visible mesh
	
	
	
	;free resources
	lea eax, [ebp-20]
	push eax
	call vector_destroy
	add esp, 4
	
	lea eax, [ebp-36]
	push eax
	call vector_destroy
	add esp, 4
	
	lea eax[ebp-52]
	push eax
	call vector_destroy
	add esp, 4
	
	
	;set return value
	mov eax, dword[ebp-4]
	
_generateChunk_done:
	mov esp, ebp
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
	
	
	
chunk_destroyChunk:
	push ebp
	mov ebp, esp
	
	mov eax, dword[ebp+8]
	push dword[eax+8]
	call free
	add esp, 4
	
	mov eax, dword[ebp+8]
	push dword[eax+12]
	call renderable_destroy
	call free
	add esp, 4
	
	push dword[ebp+8]
	call free
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret
