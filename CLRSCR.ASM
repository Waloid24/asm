.model tiny
.code
org 100h

Start:			mov ax, 0000h
			mov bx, 0b800h
			mov es, bx
			call clrscr

			mov ax, 4c00h
			int 21h

;--------------------------------------------------------
;CLEAR THE SCREEN
;--------------------------------------------------------
;Entry:			AH: color str	(arguments)	
;			AL: sym
;Exit:			None		
;Excepts:		ES = 0b800h	(ojidaet)
;Destroys:		BX CX		(razrushaet)
;--------------------------------------------------------

clrscr			proc
			
			xor bx, bx
			mov cx, 80d*25d

??Next:			mov es:[bx], ax
			add bx, 2
			loop ??Next

			ret
			endp	

;Start:			mov ax, 0000h
;			mov bx, 0b800h
;			mov es, bx
;			call clrscr
;
;			mov ax, 4c00h
;			int 21h
;
end 			Start