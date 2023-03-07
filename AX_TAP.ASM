.286
.model tiny
.code
org 100h

locals

Start:              cli                               ; we prohibit interrupts
                    xor bx, bx
                    mov es, bx
                    mov bx, 4d * 8d

                    mov ax, es:[bx]
                    mov Old08Ofs, ax

                    mov ax, es:[bx + 2]
                    mov Old08Seg, ax

                    mov bx, 4d * 9d
                    
                    mov ax, es:[bx]
                    mov Old09Ofs, ax
                    mov es:[bx], offset New09Ofs

                    mov ax, es:[bx + 2]
                    mov Old09Seg, ax
                    mov ax, cs
                    mov es:[bx + 2], ax

                    sti                                 ; we allow interrupts

                    mov ax, 3100h
                    mov dx, offset EOP
                    shr dx, 4d
                    inc dx
                    int 21h

SAVE_BUF db 9d*9d*2d dup(?)
DRAW_BUF db 9d*9d*2d dup(?)

LENG_FRAME = 9d
WIDT_FRAME = 9d

;========================================================
;SEND INFORMATION TO SAVE BUFFER
;========================================================
;--------------------------------------------------------
; 
; 
;--------------------------------------------------------
;
;ENTRY:     DS:SI -- where to send data from
;
;DESTROYS:  FLAGS
;--------------------------------------------------------

New09Ofs            proc
                    push ax bx dx di es ds

                    in al, 60h
                    cmp al, 3d

                    je @@Frame

                    cmp al, 4d
                    je @@OffFrame

                    jmp @@End

@@Frame:
                    call CmpDbAndVM

                    mov di, 160d * 2d + 138d
                    mov bx, 9d
                    mov dx, 9d

                    call Frame

                    lea si, PrAx
                    add di, 160d + 2d
                    call PrintArr

                    lea si, PrBx
                    add di, 320d
                    call PrintArr

                    lea si, PrCx
                    add di, 320d
                    call PrintArr

                    lea si, PrDx
                    add di, 320d
                    call PrintArr

                    call SendDB

                    cli
                    xor bx, bx
                    mov es, bx
                    mov bx, 4d * 8d

                    mov es:[bx], offset New08Ofs
                    mov ax, cs
                    mov es:[bx + 2], ax
                    sti
                    
                    jmp @@End

@@OffFrame:         
                    mov di, 160d * 2d + 138d
                    mov cx, 0b800h
                    mov es, cx
                    mov cx, cs
                    mov ds, cx
                    lea si, SAVE_BUF
                    
                    mov cx, 9d          ; frame height

@@Next:             push cx
                    mov cx, 9d          ; frame width 
                    push di
                    
                    rep movsw           ; ds:si -> es:di

                    pop di
                    add di, 160d
                    pop cx
                    loop @@Next
                    
                    cli
                    xor bx, bx
                    mov es, bx
                    mov bx, 4d * 8d

                    mov ax, Old08Ofs
                    mov es:[bx], ax
                    mov ax, Old08Seg
                    mov es:[bx + 2], ax
                    sti
                    

                    jmp @@End

@@End:              pop ds es di dx bx ax
                    db 0eah
Old09Ofs dw 0
Old09Seg dw 0

                    endp

;========================================================
; COMPARE DRAW BUFFER WITH VIDEO MEMORY
;========================================================
;--------------------------------------------------------
; The function compares the contents of the video memory
; with the contents of the buffer. 
; Sends the difference to the buffer.
;--------------------------------------------------------
;
;ENTRY:     
;
;DESTROYS:  FLAGS
;
;--------------------------------------------------------

CmpDbAndVM          proc

                    push si di cx dx ds es

                    cld

                    mov si, 0b800h
                    mov ds, si
                    mov si, 160d * 2d + 138d        ; ds:si - videomem

                    mov cx, cs
                    mov es, cx
                    lea di, DRAW_BUF                ; es:di - DRAW_BUF

                    mov cx, 9d 

@@Next:             
                    push cx
                    mov cx, 9d
                    push si

@@NextLet:          cmpsw

                    jne @@NotEqual
                    loop @@NextLet

@@NextLet1:         
                    pop si
                    add si, 160d
                    pop cx
                    loop @@Next
                    jmp @@End


@@NotEqual:         push dx
                    push di
                    push si
                    

                    ;mov dx, 0b800h
                    ;mov ds, dx
                    ;mov dx, cs
                    ;mov es, dx

                    lea si, DRAW_BUF
                    sub di, si
                    sub di, 2d
                    mov dx, di

                    lea di, SAVE_BUF
                    add di, dx                ; es:di -- SAVE_BUF

                    pop si
                    sub si, 2

                    movsw                     ; ds:si -> es:di

                    pop di                    ; es:di - DRAW_BUF
                    
                    pop dx
                    loop @@NextLet
                    jmp @@NextLet1

@@End:

                    pop es ds dx cx di si

                    ret
                    endp


;========================================================
;SEND INFORMATION TO SAVE BUFFER
;========================================================
;--------------------------------------------------------
; 
; 
;--------------------------------------------------------
;
;ENTRY:     DS:SI -- where to send data from
;
;DESTROYS:  FLAGS
;--------------------------------------------------------

SendDB              proc

                    push cx si di ds es 
                    mov di, 0b800h
                    mov ds, di
                    mov si, 160d * 2d + 138d

                    mov di, cs
                    mov es, di
                    lea di, DRAW_BUF

                    mov cx, 9d          ; frame height

@@Next:             
                    push cx
                    mov cx, 9d          ; frame width 
                    push si
                    
                    
                    rep movsw           ; ds:si -> es:di

                    pop si
                    add si, 160d
                    pop cx
                    loop @@Next

                    pop es ds di si cx

                    ret
                    endp


;========================================================
; COMPARE DRAW BUFFER WITH VIDEO MEMORY
;========================================================
;--------------------------------------------------------
; New actions performed when IRQ0 is interrupted:
;   -> processes DRAW and SAVE buffers
;   -> prints and updates registers in video memory
;   -> standart IRQ0
;--------------------------------------------------------
;
;ENTRY:     NONE
;
;DESTROYS:  FLAGS
;
;--------------------------------------------------------

New08Ofs            proc
                    push bp
                    mov bp, sp

                    push ax bx cx dx di

                    call CmpDbAndVM

                    mov di, 160d * 3d + 152d
                    mov ax, [bp - 2]        ; ax
                    call PrintHex

                    add di, 320d
                    mov ax, [bp - 4]
                    call PrintHex

                    add di, 320d
                    mov ax, [bp - 6]
                    call PrintHex

                    add di, 320d
                    mov ax, [bp - 8]
                    call PrintHex

                    call SendDB

@@End:              
                    pop di dx cx bx ax
                    pop bp
                    db 0eah
Old08Ofs dw 0
Old08Seg dw 0

RegA dw 0
                    endp

;========================================================
;PRINT THE REGISTER NAME
;========================================================
;--------------------------------------------------------
; Prints the register name at the address specified
; in es:di. It is assumed that this is video memory.
;--------------------------------------------------------
;
;ENTRY: ES:DI -- indicates the location where the 
;       register will be print
;       SI    -- indicates the array to be printed
;
;DESTROYS: FLAGS
;--------------------------------------------------------

PrintArr        proc

                push di si ax cx ds es
                cld
                mov cx, 0b800h
                mov es, cx
                mov cx, cs
                mov ds, cx
                mov cx, 3d

@@Next:         lodsb               ; in al first symbol 
                                    ;of the array
                mov ah, 4eh
                stosw
                loop @@Next

                pop es ds cx ax si di

                ret

PrAx db 41h, 58h, 3dh 
PrBx db 42h, 58h, 3dh
PrCx db 43h, 58h, 3dh
PrDx db 44h, 58h, 3dh

                endp

;========================================================
;REGISTER CONTENTS
;========================================================
;--------------------------------------------------------
; Prints the contents of the register
; to the specified address
;--------------------------------------------------------
;
;ENTRY:     DI -- offset relative to the es register
;           ("es" points to the video memory 
;           area: es = 0b800h)
;           AX -- your register
;
;WORK WITH: AX, BX, CX, DX, ES, SI -- doesn't destroy
;DESTROYS:  FLAGS
;--------------------------------------------------------

PrintHex    proc

            push ax cx dx es di
            pushf

            mov dx, 0b800h
            mov es, dx
            mov dx, 00001111b   ; mask
            mov cx, 4d          ; number of bits
            call Hex

            popf
            pop di es dx cx ax

            ret
            endp

Hex         proc

            push ax

            and ax, dx
            cmp ax, 10d
            jl @@Num

            add al, 37h         ; letter
            jmp @@Print

@@Num:      add al, 30h

@@Print:    mov ah, 4eh

            std                 ; <-- (printing direction)
            stosw

            pop ax
            shr ax, 4d
                
            loop Hex

            ret
            endp

;----------------------------------------------------------------------------
;FRAME
;----------------------------------------------------------------------------
;Entry:	DI (upper left corner), BX (width), DX (height)
;
;Exit:      frame in the video memory
;WORK WITH: AX, BX, CX, DX, ES, SI, DI -- doesn't destroy
;DESTROYS:  FLAGS
;----------------------------------------------------------------------------	

Frame           proc

                push es ds si di
                push ax bx cx dx

                push bx
                push dx
                
                mov ax, cs
                mov ds, ax          ; set ds in this resident

                lea si, MODE1

                mov ax, 0b800h
                mov es, ax          ; video mem access

                mov cx, bx          ; cx is width
                mov ah, [si + 9]    ; style
                mov al, [si]
                mov bh, [si + 9]
                mov bl, [si + 1]
                mov dh, [si + 9]
                mov dl, [si + 2]

                call FrLine

                mov al, [si + 3]
                mov dl, [si + 5]

                pop cx
                sub cx, 2
                pop bx              ; width


@@Next:         push cx
                mov cx, bx
                push bx 
                mov bh, [si + 9]
                mov bl, [si + 4]
                call FrLine
                pop bx
                pop cx
                loop @@Next

                mov cx, bx
                mov al, [si + 6]
                mov bh, [si + 9]
                mov bl, [si + 7]
                mov dl, [si + 8]

                call FrLine
                
                pop dx cx bx ax
                pop di si ds es

                ret

MODE1 db 214d, 205d, 183d, 186d, 0d, 186d, 211d, 205d, 189d, 4eh

                endp

;----------------------------------------------------------------------------
;PRINT FRAME LINE
;----------------------------------------------------------------------------
;Entry:	    AX (left sym), BX (middle sym), CX (length line) DX (right sym)
;Exit:      NONE
;Destroys:	AX, BX, CX, DI, SI FLAGS
;----------------------------------------------------------------------------

FrLine          proc

                push di
                push cx

                stosw
                sub cx, 2d
                mov ax, bx
                rep stosw
                mov ax, dx
                stosw               

                pop cx
                pop di
                add di, 80d * 2d
                
                ret
                endp

EOP:        end                 Start