[ORG 0x7C00]
BITS 16

%define SNAKE_ARRAY 0x8000

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ax, 0x0003
    int 0x10

    mov word [longueur], 3
    mov di, SNAKE_ARRAY
    mov word [di], 0x0C28
    mov word [di+2], 0x0C27
    mov word [di+4], 0x0C26
    
    mov byte [dir_x], 1
    mov byte [dir_y], 0
    call spawn_apple

game_loop:
    call clear_screen
    mov dx, 0
    call set_cursor
    mov si, message_score
    call print_string
    mov ax, [longueur]
    sub ax, 3
    call print_number

    call draw_apple
    call draw_snake
    call handle_input
    call deplacement_snake
    call check_collision
    call delay
    jmp game_loop

game_over:
    mov dx, 0x0A23
    call set_cursor
    mov si, message_gameover
    call print_string
.wait:
    xor ax, ax
    int 0x16
    cmp al, 13
    jne .wait
    jmp start

set_cursor:
    mov ah, 0x02
    xor bh, bh
    int 0x10
    ret

clear_screen:
    mov ax, 0x0600
    mov bh, 0x07
    xor cx, cx
    mov dx, 0x184F
    int 0x10
    ret

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

print_number:
    mov bx, 10
    xor cx, cx
.div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .div_loop
.print_loop:
    pop ax
    add al, '0'
    mov ah, 0x0E
    int 0x10
    loop .print_loop
    ret

draw_snake:
    mov cx, [longueur]
    mov si, SNAKE_ARRAY
.loop:
    push cx
    mov dx, [si]
    call set_cursor
    mov ah, 0x0E
    mov al, '#'
    int 0x10
    add si, 2
    pop cx
    loop .loop
    ret

draw_apple:
    mov dh, [apple_y]
    mov dl, [apple_x]
    call set_cursor
    mov ah, 0x0E
    mov al, '@'
    int 0x10
    ret

spawn_apple:
    mov ah, 0x00
    int 0x1A
    mov ax, dx
    xor dx, dx
    mov cx, 75
    div cx
    inc dl
    mov [apple_x], dl
    mov ax, dx
    xor dx, dx
    mov cx, 22
    div cx
    inc dl
    mov [apple_y], dl
    ret

handle_input:
    mov ah, 0x01
    int 0x16
    jz .done
    xor ax, ax
    int 0x16
    cmp al, 'w'
    je .up
    cmp al, 's'
    je .down
    cmp al, 'a'
    je .left
    cmp al, 'd'
    je .right
.done:
    ret
.up:    mov byte [dir_x], 0
        mov byte [dir_y], -1
        ret
.down:  mov byte [dir_x], 0
        mov byte [dir_y], 1
        ret
.left:  mov byte [dir_x], -1
        mov byte [dir_y], 0
        ret
.right: mov byte [dir_x], 1
        mov byte [dir_y], 0
        ret

deplacement_snake:
    mov cx, [longueur]
    dec cx
    mov si, SNAKE_ARRAY
    mov ax, cx
    shl ax, 1
    add si, ax
.shift:
    mov ax, [si-2]
    mov [si], ax
    sub si, 2
    loop .shift
    mov di, SNAKE_ARRAY
    mov al, [di]
    add al, [dir_x]
    mov ah, [di+1]
    add ah, [dir_y]
    mov [di], ax
    ret

check_collision:
    mov di, SNAKE_ARRAY
    mov ax, [di]
    cmp al, 0
    jl .die
    cmp al, 79
    jg .die
    cmp ah, 0
    jl .die
    cmp ah, 24
    jg .die
    mov cx, [longueur]
    dec cx
    mov si, SNAKE_ARRAY
    add si, 2
.self:
    cmp ax, [si]
    je .die
    add si, 2
    loop .self
    cmp al, [apple_x]
    jne .ret
    cmp ah, [apple_y]
    jne .ret
    inc word [longueur]
    call spawn_apple
.ret:
    ret
.die:
    pop ax
    jmp game_over

delay:
    mov ah, 0
    int 0x1A
    mov bx, dx
.wait:
    int 0x1A
    sub dx, bx
    cmp dx, 2
    jl .wait
    ret

longueur    dw 0
dir_x     db 0
dir_y     db 0
apple_x   db 0
apple_y   db 0
message_gameover  db "GAME OVER ! PRESS ENTER TO RESTART", 0
message_score db "Score:", 0

times 510-($-$$) db 0
dw 0AA55h