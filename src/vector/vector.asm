;vector layout:
;struct{
;  int size;
;  int capacity;
;  int element_size;
;  void* data;
;}

section .data
	format db "element size: %d",10,0

section .text
	extern malloc
	extern realloc
	extern free
	extern printf
	extern memcpy

	global vector_init
	global vector_destroy
	global vector_push_back

vector_init: ;vector vector_init(element_size)
	push ebp
	mov ebp, esp
	
	;fill up the struct given as a target (vector* as a first parameter basically)
	mov ecx, dword[ebp+8]
	mov dword [ecx], 0 ;size
	mov dword [ecx+4], 1 ;capacity
	mov eax, dword[ebp+12]
	mov dword [ecx+8], eax ;element size
	
	push ecx
	push eax
	call malloc
	add esp, 4
	pop ecx
	mov dword[ecx+12], eax ;data
	
	mov eax, 0
	mov esp, ebp
	pop ebp
	ret
	
vector_destroy:		;void vector_destroy(vector* gaynigga)
	push ebp
	mov ebp, esp
	
	mov ecx, dword [ebp+8]
	mov dword [ecx], 0
	mov dword [ecx+4], 0
	mov eax, dword[ecx+12]
	push eax
	mov dword[ecx+12], 0	;set to NULL
	call free
	
	mov esp, ebp
	pop ebp
	ret
	
	
vector_push_back:	;void vector_push_back(vector* robloxman, element _element) (element is pushed to the stack)
	push ebp
	mov ebp, esp
	
	mov ecx, dword [ebp+8] ;vector* in ecx
	
	mov eax, dword[ecx]	;size
	mov edx, dword[ecx+4]	;capacity
	
	cmp eax, edx
	jl _push_back_no_realloc
	
	imul edx, 2
	mov dword[ecx+4], edx	;new capacity
	
	push ecx	;save ecx
	
	imul edx, dword[ecx+8]	;calculate new size
	push edx
	mov eax, dword[ecx+12]
	push eax
	call realloc
	add esp, 8
	pop ecx		;restore ecx
	
	mov dword[ecx+12], eax	;save new data*
	
_push_back_no_realloc:
	mov eax, dword[ecx]
	imul eax, dword[ecx+8]	;offset from data*
	mov edx, dword[ecx+12]
	add edx, eax

	
	mov eax, dword[ecx+8]
	push eax
	lea eax, [ebp+12]
	push eax
	push edx
	call memcpy
	add esp, 12
	
	mov eax, dword[ebp+8]
	mov ecx, dword[eax]
	inc ecx
	mov dword[eax],ecx
	
	mov esp, ebp
	pop ebp
	ret
