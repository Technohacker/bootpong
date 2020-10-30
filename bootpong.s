; ==============================
; Boot Pong
; By Technohacker
; ==============================

; We're working in 16-bit real mode in the MBR
bits 16

; The MBR is placed in 0x7c00 in memory
org 0x7c00

; Make CS:IP consistent by jumping to 0000:7C00
jmp 0x00:start

; Paddle information
paddle_width: equ 16
paddle_height: equ 128
paddle_vy: equ 8

p1_paddle_x: equ 64
p1_paddle_y: dw 16

p2_paddle_x: equ (640 - (p1_paddle_x + paddle_width))
p2_paddle_y: dw 320

; Ball info
ball_side: equ 8
ball_x: dw ((640 / 2) - (ball_side / 2))
ball_y: dw ((480 / 2) - (ball_side / 2))

ball_vx: dw -8
ball_vy: dw -4

; Start the program!
start:
    ; Disable interrupts (clear interrupt flag)
    cli

    ; Set up stack at 0000:7BFE
    xor ax, ax
    mov ss, ax
    mov sp, 0x7BFE

    ; Install our ISR
    ; IVT fields are [segment:offset]
    ; IVT starts at 0000:0000h
    ; 
    ; Keyboard is INT9

    ; Offset, our ISR
    mov [(0x09 * 4)], WORD keyboard_isr
    ; Segment, our CS
    mov [(0x09 * 4) + 2], cs

    ; Switch to a graphics mode
    ; 
    ; AH=00 Set Graphics mode
    ; AL=11 640x480 B/W
    mov ax, 0x00_11
    int 0x10

    ; Enable interrupts (set interrupt flag)
    sti

; Main game loop
.game_loop:
    ; ====== Handle keyboard input

    ; Move paddle 1 first
    ; -(w_key_pressed) + (s_key_pressed)
    xor ax, ax
    sub al, [w_key]
    add al, [s_key]

    ; Extend the 8-bit al to the 16-bit ax
    movsx ax, al
    ; Multiply by 16 (left shift 4)
    shl ax, 4

    ; Move paddle
    add [p1_paddle_y], ax

    ; Then paddle 2
    ; -(up_key_pressed) + (down_key_pressed)
    xor ax, ax
    sub al, [up_key]
    add al, [down_key]

    ; Extend the 8-bit al to the 16-bit ax
    movsx ax, al
    ; Multiply by 16 (left shift 4)
    shl ax, 4

    ; Move paddle
    add [p2_paddle_y], ax

    ; ====== Key handling done

    ; ====== Move the ball
.p1_check:
    ; Load the ball's x coordinate
    mov ax, [ball_x]

    ; Check if we're beyond the paddle's right side
    cmp ax, (p1_paddle_x + paddle_width)
    ; If so, skip to paddle 2 check
    jg .p2_check

    ; Check if we're beyond the paddle's left side
    cmp ax, p1_paddle_x
    ; If so, skip to paddle 2 check
    jl .p2_check

    ; Else, load the Y coordinate
    mov ax, [ball_y]

    ; Check if we're colliding with the paddle
    mov bx, [p1_paddle_y]
    cmp ax, bx
    ; If not, skip to paddle 2 check
    jl .p2_check

    ; Check lower edge
    add bx, paddle_height
    cmp ax, bx
    ; If not, skip to paddle 2 check
    jg .p2_check

    ; Bounce the ball
    neg WORD [ball_vx]

.p2_check:
    ; Load the ball's x coordinate
    mov ax, [ball_x]

    ; Check if we're beyond the paddle's right side
    cmp ax, (p2_paddle_x + paddle_width)
    ; If so, skip to top and bottom edge check
    jg .top_bottom_check

    ; Check if we're beyond the paddle's left side
    cmp ax, p2_paddle_x
    ; If so, skip to top and bottom edge check
    jl .top_bottom_check

    ; Load the Y coordinate
    mov ax, [ball_y]

    ; Check if we're colliding with the paddle
    mov bx, [p2_paddle_y]
    cmp ax, bx
    ; If not, skip to top and bottom edge check
    jl .top_bottom_check

    ; Check lower edge
    add bx, paddle_height
    ; If not, skip to top and bottom edge check
    cmp ax, bx
    jg .top_bottom_check

    ; Bounce the ball
    neg WORD [ball_vx]

.top_bottom_check:
    ; Load ball y coordinate
    mov ax, [ball_y]

    ; Check if it's beyond the top edge
    ; Not exactly 0 to account for overshoot
    cmp ax, ball_side
    ; If so, bounce the ball
    jle .bounce_y

    ; Check if it's beyond the bottom edge
    cmp ax, (480 - ball_side)
    ; If so, bounce the ball
    jge .bounce_y

    ; Else just move the ball
    jmp .apply_velocity

.bounce_y:
    neg WORD [ball_vy]

.apply_velocity:
    ; Add the ball's x velocity to the ball's x coordinate
    mov ax, [ball_vx]
    add [ball_x], ax

    ; Add the ball's y velocity to the ball's y coordinate
    mov ax, [ball_vy]
    add [ball_y], ax
    ; ====== Ball movement done

    ; ====== Check for scoring situations
    ; Right edge: P1 scores
    cmp WORD [ball_x], 640
    jge .p1_win

    ; Left edge: P2 scores
    cmp WORD [ball_x], 0
    jle .p2_win

    ; Else just continue
    jmp .continue

.p1_win:
.p2_win:
    ; We don't do anything yet due to size restrictions
    ; Reset the ball to the center
    mov WORD [ball_x], ((640 / 2) - (ball_side / 2))

.continue:
    ; ====== Score check done

    ; ====== Draw the screen

    ; Clear the screen
    ; 
    ; AH=00 Set Graphics mode
    ; AL=11 640x480 B/W
    mov ax, 0x00_11
    int 0x10

    ; Draw paddle 1
    mov [box_x], WORD p1_paddle_x

    mov ax, [p1_paddle_y]
    mov [box_y], ax

    mov [box_width], WORD paddle_width
    mov [box_height], WORD paddle_height

    call draw_box

    ; Draw paddle 2
    mov [box_x], WORD p2_paddle_x

    mov ax, [p2_paddle_y]
    mov [box_y], ax

    mov [box_width], WORD paddle_width
    mov [box_height], WORD paddle_height

    call draw_box

    ; Draw ball
    mov ax, [ball_x]
    mov [box_x], ax

    mov ax, [ball_y]
    mov [box_y], ax

    mov [box_width], WORD ball_side
    mov [box_height], WORD ball_side

    call draw_box
    ; ====== Screen drawing done

    ; Jump back to loop start
    jmp .game_loop

    hlt

; Include our ISR
%include "isr.s"
; Include our utility subroutines
%include "utility.s"

; Fill the file with no-ops until byte 446
; (446 - (current position in program - start of segment))
times 446 - ($ - $$) nop

; Partition table entries
times (4 * 16) db 'a'

; Store the MBR magic bytes
dw 0xAA55
