.model tiny
.code 
org 100h

Start:		
		mov si, 0082h		; adress of DTA (cmp byte ptr [si], 0)
		
		mov ah, 02h
		mov dl, [si]		; check [si]
		int 21h

		mov bx, 0b800h
		mov es, bx		; Go to video mem
	
		xor bx, bx

		;mov cx, [si]
		;add si, 1
		mov ax, [si]
		mov ah, 34h 
		
Next:		mov es:[bx + (80 * 25) - 10], ax
		add bx, 2

		add si, 1		; moving in command line
		mov ax, [si]
		mov ah, 34h
	
		mov dx, [si]
		cmp dx, 0Dh
		jne Next
		 
		mov ax, 4c00h
		int 21h

end 		Start