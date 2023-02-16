.model tiny
.code
org 100h

Start:  mov bx, 0b800h				; Video mem seg addr
	mov es, bx
	
	xor bx, ( 80 * 25/2 + 80/2 ) * 2	; Center of screen


	mov byte ptr [bx], 88d			; 88d = 58h = 'X' 

	mov byte ptr es:[bx], 88d
	mov byte ptr es:[bx+1], 4ch		; Yellow in 4ch

	mov ax, 4c00h
	int 21h

end 	Start

		4ch = 0100 1110
		      kRGB irgb