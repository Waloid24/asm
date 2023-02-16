.model tiny
.code 
org 100h

Start:
			mov bx, 0b800h
			mov es, bx
			
			xor bx, bx
			mov cx, (80/2 + 25/2)d

			mov byte ptr ax, ds:0080h

Next:			mov es:[bx], ax
			inc ah
			add bx, 2
			
			
					



end 			Start