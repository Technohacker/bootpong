; Key press state
w_key: db 0
s_key: db 0
up_key: db 0
down_key: db 0

; ISR to handle game-like keyboard input
; Reports W, S, Up, Down active and inactive states
keyboard_isr:
    ; Save registers to the stack
    pusha

    ; Read keyboard scan code into al
    in al, 0x60

    ; Split the scan code into (in)active and scan code
    xor bh, bh
    mov bl, al
    ; bx = scan code
    and bl, 0x7F
    ; al = 0 if pressed, 1 if released
    shr al, 7
    ; XOR to flip the boolean: al = 1 if pressed, 0 if released
    xor al, 1

    ; Push bx and ax onto the stack
    pusha

    ; send EOI to XT keyboard
    in al, 0x61
    mov ah, al
    or al, 0x80
    out 0x61, al
    mov al, ah
    out 0x61, al

    ; send EOI to master PIC
    mov al, 0x20
    out 0x20, al

    ; Pop the scan code and status from the stack
    popa

.w_key:
    cmp bx, 0x11 ; W
    ; Check next key if not equal
    jne .s_key

    ; Else set W
    mov [w_key], al
.s_key:
    cmp bx, 0x1F ; S
    ; Check next key if not equal
    jne .up_key

    ; Else set S
    mov [s_key], al
.up_key:
    cmp bx, 0x48 ; Up
    ; Check next key if not equal
    jne .down_key

    ; Else set Up
    mov [up_key], al
.down_key:
    cmp bx, 0x50 ; Down
    ; Return if not equal
    jne .continue

    ; Else set Down
    mov [down_key], al

.continue:
    ; Restore all registers
    popa
    ; Return from interrupt
    iret
