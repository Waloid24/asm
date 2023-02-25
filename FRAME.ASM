.model tiny

.data
LENMAS = 101d
DEFMAS db 12d, 'Hello world!'

.code
org 100h

Start:
            call GetNum         ; Ox
            lea di, PARAMS
            mov [di], ax
            add di, 2

            call GetNum         ; Oy
            mov [di], ax
            add di, 2

            call GetNum         ; Height
            mov [di], ax
            add di, 2

            call GetNum         ; Width
            mov [di], ax
            add di, 2

            call GetNum         ; Mode
            mov [di], ax

            call GetConsText

            lea si, PARAMS
              
            mov ax, [si + 2]
            cmp ax, 0d
            je ??ShiftOx
            dec ax
            mov bl, 160d
            mul bl
??ShiftOx:  mov bx, [si]
            add bx, bx
            add ax, bx          ; left upper corner

            push ax

            mov di, ax 
            mov ax, [si + 8]
            mov bx, [si + 6]
            mov dx, [si + 4]
            call Frame

            mov ax, [si + 4]  ; height
            shr ax, 1d
            
            mov bl, 160d
            mul bl

            mov bx, ax
            pop ax
            add ax, bx
            
            add ax, [si + 6]
            lea di, MASSAGE

            mov bx, 0d
            cmp [di], bx
            jne ??UserMas1  
            lea di, DEFMAS 

??UserMas1: mov bx, [di]
            xor bh, bh
            sub ax, bx
            mov di, ax
            test di, 1d
            je ??Evenn
            inc di

??Evenn:    xor si, si          ; rm 
            xor bx, bx          ; rm
            ;xor ax, ax          ; rm 

            call SendTextVid

            mov ax, 4c00h
            int 21h

MASSAGE db 101 dup(?)
PARAMS  dw 5 dup(?)

MODE1 db 201d, 203d, 187d, 204d, 206d, 185d, 200d, 202d, 188d, 34h
MODE2 db 214d, 205d, 183d, 186d, 0d, 186d, 211d, 205d, 189d, 34h

;----------------------------------------------------
;FRAME
;----------------------------------------------------
;Entry:	DI (upper left corner), AX (mode), BX (width), DX (height)
;
;Exit:      
;Excepts:	
;Destroys:	AX, BX, CX, SI
;----------------------------------------------------	

Frame           proc

                push si
                push es
                push cx

                call SetMode        ; now ax free, si has address of MODE

                mov ax, 0b800h
                mov es, ax          ; video mem access
                mov cx, bx          ; bx is width

                mov ah, [si + 9]    ; style
                mov al, [si]
                mov es:[di], ax
                add di, 2
                sub cx, 2

                cld
                mov al, [si + 1] 
                rep stosw               ; print left upper line

                mov al, [si + 2]        ; right upper corner
                mov es:[di], ax
                
                mov ax, 4c00h
                int 21h

                add di, 162d
                push bx
                add bx, bx
                sub di, bx              ; left border on next level
                pop bx

                sub dx, 2               ; without top and bottom line
                mov cx, dx


??FrameBody:    push cx

                mov cx, bx              ; cx is width
                
                mov al, [si + 3]        ; left border
                mov es:[di], ax
                add di, 2
                sub cx, 2
                
                mov al, [si + 4]
                rep stosw

                mov al, [si + 5]
                mov es:[di], ax
                add di, 2
                add di, 160d
                push bx
                add bx, bx
                sub di, bx              ; left border on next level
                pop bx

                pop cx
                loop ??FrameBody

                mov cx, bx

                mov al, [si + 6]
                mov es:[di], ax         ; left bottom corner
                add di, 2
                sub cx, 2

                cld
                mov al, [si + 7] 
                rep stosw               ; print bottom line

                mov al, [si + 8]        ; right bottom corner
                mov es:[di], ax                

                pop cx
                pop es
                pop si

                ret
                endp
;----------------------------------------------------
;SET MODE 
;----------------------------------------------------
;Entry:	SI (left corner), AX (mode), BX (width), DX (height)
;
;Exit:      SI
;Excepts:	
;Destroys:	
;----------------------------------------------------	

SetMode         proc

                cmp ax, 1d
                je ??Mode1 

                cmp ax, 2d
                je ??Mode2

??Mode1:        lea si, MODE1
                jmp ??Exit

??Mode2:        lea si, MODE2
                jmp ??Exit

??Exit:         ret 
                endp

;------------------------------------------------
;TAKE THE NUM FROM THE CONSOLE
;------------------------------------------------
;Entry:		
;
;Exit:      AX
;Excepts:	
;Destroys:	AX, CX
;------------------------------------------------

GetNum      proc

            xor ax, ax
            push cx
            push bx

??Next:     mov cx, [0082h + si]    ; command line
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

            jmp ??Next

??EndStr:   pop bx
            pop cx

            ret
            endp

;------------------------------------------------
;TAKE THE TEXT FROM THE CONSOLE
;------------------------------------------------
;Entry:		SI (start text in console)
;
;Exit:      
;Excepts:	
;Destroys:	
;------------------------------------------------

GetConsText     proc

                push di
                push si
                push ax
                push cx
                push bx

                cld
                add si, 0082h
                lea di, MASSAGE+1
                mov cx, LENMAS
                mov bl, 0Dh

                push cs
                pop es

??GetText:      lodsb            ; in al
                cmp al, 0d
                je ??EndCopy
                cmp al, 0Dh
                je ??EndCopy
                stosb
                
                loop ??GetText

??EndCopy:      cmp cx, 0d
                jne ??LenStr

                lea si, MASSAGE
                mov al, LENMAS
                mov [si], al
                jmp ??end

??LenStr:       mov ax, LENMAS
                sub ax, cx
                lea si, MASSAGE
                mov [si], al

??end:          pop bx
                pop cx
                pop ax
                pop si
                pop di

                ret
                endp

;------------------------------------------------
;DISPLAY TEXT ON THE SCREEN
;------------------------------------------------
;Entry:		DI
;
;Exit:      
;Excepts:	
;Destroys:	
;------------------------------------------------

SendTextVid     proc

                push cx
                push es
                push ax
                push di
                push si

                lea si, MASSAGE ; there was a hint [MASSAGE]
                mov ax, 0b800h
                mov es, ax

                mov cx, [si]    ; length massage
                cmp cx, 0d
                jne ??UserMas

                lea si, DEFMAS
                mov cx, [si]

??UserMas:      xor ch, ch
                inc si          ; si -> text
                ;mov di, 160d    ; the start print place 

??Print:        lodsb
                mov ah, 34h         ;Color
                stosw               ;put in VidMem

                loop ??Print

                pop si
                pop di
                pop ax
                pop es
                pop cx
                
                ret
                endp

end 	Start