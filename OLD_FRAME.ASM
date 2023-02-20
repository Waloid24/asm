.model tiny
.code 
org 100h

Start:
		
		mov ax, 10d 
		mov bx, 20d			; Oy
		mov dx, 40d			; Ox
		call Frame
		
		mov ax, 4c00h
		int 21h

;----------------------------------------------------
;FRAME
;----------------------------------------------------
;Entry:	AX, BX, DX	
;
;Exit:      
;Excepts:	SI = 0000h
;Destroys:	AX, BX, CX, SI
;----------------------------------------------------		

Frame		proc
			
			xor cx, cx				; cx free
			mov si, ax				; ax free (now si -> di)
			
			sub bx, 1d
			push ax
			mov ax, bx
			mov cx, 160d
			mul cl
			mov cx, ax

			pop ax
			add cx, ax 					; lower left corner

			mov di, cx					; lower left corner in di
			
			inc bx

			mov cx, 0b800h
			mov es, cx	
						
			sub dx, 1
			mov cx, dx					; cx - counter in loop (Ox)
	
			mov dl, 201d
			mov dh, 34h
			mov es:[si], dx
			mov dl, 200d
			mov es:[di], dx
			add si, 2
			add di, 2
			jmp ??EndLR

??High:		mov dl, 203d
			mov dh, 34h
			mov es:[si], dx
			mov dl, 202d
			mov es:[di], dx
			add si, 2
			add di, 2
			
??EndLR:	loop ??High

			mov cl, 187d
			mov ch, 34h
			mov es:[si], cx
			mov cl, 188d
			mov es:[di], cx

			mov di, ax
			add si, 160d
			add di, 160d
			sub bx, 2d
			mov cx, bx

??Walls:	mov dl, 185d
			mov dh, 34h
			mov es:[si], dx
			mov dl, 204d
			mov es:[di], dx
			add si, 160d
			add di, 160d
			loop ??Walls

			ret
			endp

end 		Start