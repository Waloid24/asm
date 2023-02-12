.model tiny
.code
org 100h

Start:		mov bx, 0b800h			; video mem seg adrs
		mov es, bx
		
		xor bx, bx
		mov cx, 80*25d			; size of the screen

		mov ax, 0058h

Next: 		mov es:[bx], ax
		inc ah 				; ah = ah + 1
		add bx, 2
		loop Next                       ; !=0 next

		mov ax, 4c00h
		int 21h

end		Start
	
