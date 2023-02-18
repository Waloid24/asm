.model tiny
.code
org 100h 

;------------------------------------------------
;TAKE THE ARGUMENT FROM THE CONSOLE
;------------------------------------------------
;Entry:		
;
;Exit:      
;Excepts:	SI = 0000h
;Destroys:	AX, BX, CX, SI
;------------------------------------------------

takeArg:        mov si, 0000h
                        
                call SymWord
                jmp EndProg

SymWord     proc

            mov cx, [0082h + si]
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

EndProg:
end         takeArg

