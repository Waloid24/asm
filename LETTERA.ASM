.model tiny
.code
org 100h

Start:		mov bx, 0b800h
		mov es, bx
		
		xor bx, bx
		xor si, si

		mov cx, 12d
		mov ah, 83d

Next:		mov al, byte ptr Words [si]
		mov es:[bx + (80 * 25) - 10], ax
		add bx, 2
		inc si
		loop Next

Words:		db 'Hello world!$'

		mov ax, 4c00h
		int 21h


end 		Start		