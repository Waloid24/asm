.model tiny
.code
org 100h


Start:	xor si, si
		call SymWord		; there is a num in ax 
		mov ds:[0h], ax
		
		push ax				; save in stack first num
		
		xor ax, ax
		call SymWord		; second num in ax
		mov ds:[2h], ax

		mov bx, ax			; in bx - second num
		pop ax				; in ax - first num
		push ax
		
		add ax, bx			; sum in ax
		mov ds:[4h], ax		; sum in es:[4h]

		pop ax
		push ax

		sub ax, bx			
		mov ds:[6h], ax		; sub in es:[6h]

		pop ax
		push ax				; save ax

		mul bx
		mov ds:[8h], ax		; mul in es:[8h]
		
		pop ax
		push ax

		div bx
		mov ds:[10d], ax	; mul in es:[10d]
		
		pop ax
		;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		mov si, (80d * 3d * 2d) + (65d * 2d)
		mov bx, ds:[4h]
		call NumSysBin
		
		mov si, (80d * 4d * 2d) + (65d * 2d)
		mov bx, ds:[4h]
		call HexStart
		;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		mov si, (80d * 8d * 2d) + (65d * 2d)
		mov bx, ds:[6h]
		call NumSysBin

		mov si, (80d * 9d * 2d) + (65d * 2d)
		mov bx, ds:[6h]
		call HexStart
		;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		mov si, (80d * 13d * 2d) + (65d * 2d)
		mov bx, ds:[8h]
		call NumSysBin

		mov si, (80d * 14d * 2d) + (65d * 2d)
		mov bx, ds:[8h]
		call HexStart
		;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		mov si, (80d * 18d * 2d) + (65d * 2d)
		mov bx, ds:[10d]
		call NumSysBin

		mov si, (80d * 19d * 2d) + (65d * 2d)
		mov bx, ds:[10d]
		call HexStart
		;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		mov ax, 4c00h
		int 21h



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
;Destroys:	AX, BX, CX, DX, ES, SI
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
                sub si, 2
                jmp ??EndCompar
                
??MovNull:      mov bh, 34h
                mov bl, 30h         ; bx & mask == 0, then ASCII 0
                mov es:[si], bx
                sub si, 2
                jmp ??EndCompar

??EndCompar:    pop bx

                SHR bx, 1h
                
                loop Binary

                ret
                endp
				
;------------------------------------------------------
;OUTPUT A NUMBER IN HEX MODE
;------------------------------------------------------
;Entry:		BX, SI
;
;Exit:      
;Excepts:	DX = 00000001b, ES = 0b800h
;Destroys:	AX, BX, CX, DX, ES, SI
;-------------------------------------------------------		
	
HexStart    proc

            mov dx, 0b800h
		    mov es, dx

            mov dx, 00001111b   ; mask
            mov cx, 4d          ; number of bits
            call Hex

            ret
            endp

Hex         proc

            push bx

            AND bx, dx
            cmp bx, 10d
            jae ??Letter
            jl ??Num

??Letter:   
            add bl, 37h
            mov bh, 34h
            mov es:[si], bx
            sub si, 2
            jmp ??EndComp

??Num:      add bl, 30h
            mov bh, 34h
            mov es:[si], bx
            sub si, 2
            jmp ??EndComp

??EndComp:  pop bx

            SHR bx, 4d
                
            loop Hex

            ret
            endp

end 			Start