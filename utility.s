var_base: equ 0xFFFF

box_x: equ (var_base - (2 * 1))
box_y: equ (var_base - (2 * 2))
box_width: equ (var_base - (2 * 3))
box_height: equ (var_base - (2 * 4))

; Draws a rectangle based on the values above
draw_box:
    ; Y End Coord
    mov ax, [box_y]
    ; Extend the box Y end with the Y coord
    add [box_height], ax

    ; X Coord
    mov ax, [box_x]
    ; Extend the box X end with the X coord
    add [box_width], ax

    ; From this point onward, box_width and box_height signify box_x_end and box_y_end
    ; (As in, they point to the final coordinates for each axis)

    ; Horizontal lines

    ; X Counter
    mov cx, [box_x]

.horizontals:
    ; Position at correct y-coordinate
    mov dx, [box_y]

    ; Int 10h       Graphics
    ; AH = 0C       Draw a single pixel
    ; AL = 01111111 Pixel Colour
    ; BH = 0        Page
    ; CX = Column # (along X-axis)
    ; DX = Row # (along Y-axis)
    mov ax, 0x0C_7F
    xor bh, bh
    int 0x10

    ; Offset to bottom of box
    mov dx, [box_height]

    ; Call it again
    int 0x10
    
    ; Increment CX to the next pixel
    inc cx
    ; Compare with X end
    cmp cx, [box_width]
    ; Loop if not done
    jne .horizontals

    ; Vertical lines

    ; Y Counter
    mov dx, [box_y]

.verticals:
    ; Position at correct x-coordinate
    mov cx, [box_x]

    ; Int 10h       Graphics
    ; AH = 0C       Draw a single pixel
    ; AL = 01111111 Pixel Colour
    ; BH = 0        Page
    ; CX = Column # (along X-axis)
    ; DX = Row # (along Y-axis)
    mov ax, 0x0C_7F
    xor bh, bh
    int 0x10

    ; Offset to bottom of box
    mov cx, [box_width]

    ; Call it again
    int 0x10
    
    ; Increment DX to the next pixel
    inc dx
    ; Compare with Y end
    cmp dx, [box_height]
    ; Loop if not done
    jne .verticals

    ; Return to sender
    ret
