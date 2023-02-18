.model tiny
.code
org 100h


Start:	
		;mov bx, 0b800h
		;mov es, bx
		;xor bx, bx		
		xor si, si
		call SymWord		; there is a num in ax 
		mov es:[0h], ax
		
		push ax				; save in stack first num
		
		xor ax, ax
		call SymWord		; second num in ax
		mov es:[1h], ax

		mov bx, ax			; in bx - second num
		pop ax				; in ax - first num
		push ax
		
		add ax, bx			; sum in ax
		mov es:[2h], ax		; sum in es:[2h]

		pop ax
		push ax

		sub ax, bx			
		mov es:[4h], ax		; sub in es:[3h]

		pop ax
		push ax				; save ax

		mul bx
		mov es:[6h], ax		; mul in es:[4h]
		
		pop ax
		push ax

		div bx
		mov es:[8h], ax
		
		pop ax
		
		mov si, 80d * 25d
		mov bx, es:[2h]
		call NumSysBin

		mov ax, 4c00h
		int 21h

;include ARGCONSOLE.COM	; take the num from the console

;------------------------------------------------
;TAKE THE ARGUMENT FROM THE CONSOLE
;------------------------------------------------
;Entry:		
;
;Exit:      
;Excepts:	SI = 0000h
;Destroys:	AX, BX, CX, SI
;------------------------------------------------

SymWord     proc

            mov cx, [0082h + si]    ; command line
            inc si	
            mov ch, 00h
            cmp cx, 20h
            jne ??IsEndStr          ; this is not ' '

            je ??EndStr
            
??IsEndStr: cmp cx, 0Dh
            je ??EndStr
            sub cx, 30h             ; this is not '\n'
            
            mov bx, 10d             ; ok 
            mul bx
            add ax, cx

            jmp SymWord

??EndStr:   ret
            endp

;------------------------------------------------------
;OUTPUT A NUMBER IN BINARY MODE
;------------------------------------------------------
;Entry:		BX, SI
;
;Exit:      
;Excepts:	DX = 00000001b, ES = 0b800h
;Destroys:	AX, BX, CX, ES, SI
;-------------------------------------------------------

NumSysBin		proc

				mov dx, 0b800h
		        mov es, dx

                mov dx, 00000001b   ; mask
                mov cx, 16          ; number of bits
                call Binary

				ret
				endp

Binary          proc    

                push bx

                AND bx, dx
                cmp bx, 1h
                je ??movOne
                jne ??movNull


??MovOne:       mov bh, 34h
                mov bl, 31h         ; bx & mask == 1, then ASCII 1
                mov es:[si], bx
                add si, 2
                jmp ??EndCompar
                
??MovNull:      mov bh, 34h
                mov bl, 30h         ; bx & mask == 0, then ASCII 0
                mov es:[si], bx
                add si, 2
                jmp ??EndCompar

??EndCompar:    pop bx

                SHR bx, 1h
                
                loop Binary

                ret
                endp

end Start