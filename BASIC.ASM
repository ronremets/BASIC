ideal
model small
stack 100h

include "COMPILER.ASM"

dataseg
new_line        db 13, 10, '$'
exit_code       db  0
code_filename   db  'code.txt', 0
asm_filename    db  'code.asm', 0
buffer          db  100h dup('$')
buffer2         db  100h dup('$')
error_msg       db  13, 10, 'error: $'
ending          db  '"$'
msg             db  'hello world$'

codeseg

proc clear
;----------PARAMS----------
_basic_clear_buffer_ending    equ bp + 04
_basic_clear_buffer_dataseg   equ bp + 06
_basic_clear_buffer           equ bp + 08
;--------------------------
    push    bp
    mov     bp, sp
    
    push    ax
    push    bx
    push    si
    push    ds
    
    mov     al, [_basic_clear_buffer_ending]
    
_basic_clear_next_char_initialization:
    xor     bx, bx
    jmp     _basic_clear_next_char_condition
    
_basic_clear_next_char_update:
    inc     bx
    
_basic_clear_next_char_condition:
    cmp     [ds:si + bx], al  ; did you get to the end?
    je     _basic_clear_next_char_end
    
_basic_clear_next_char:
    mov     [ds:si + bx], al
    jmp     _basic_clear_next_char_update
    
_basic_clear_next_char_end:
    pop     ds
    pop     si
    pop     bx
    pop     ax
    
    pop     bp
    ret     06
endp clear


proc handle_error
    push    offset buffer2
    push    seg buffer2
    push    '$'
    call    clear
    
    lea     dx, [error_msg]
    mov     ah, 09
    int     21h
    
    push    ax
    push    offset buffer2
    push    seg buffer2
    call    int_to_string
    
    lea     dx, [buffer2]
    mov     ah, 09
    int     21h
    
    lea     dx, [new_line]
    mov     ah, 09
    int     21h
    mov     [exit_code], 1
    jmp     exit
endp handle_error

proc main
    mov     ax, @data
    mov     ds, ax
    
    mov     ah, 3ch  ; create file
    lea     dx, [asm_filename]
    xor     cx, cx  ; normal file
    int     21h
    jnc      ok1
    call    handle_error
ok1:
    xor     bx, bx
    
    push    offset compiler_template
    push    seg compiler_template
    push    bx
    call    strlen
    
    mov     cx, bx
    mov     bx, ax

    push    offset compiler_template
    push    seg compiler_template
    push    offset msg
    push    seg msg
    push    '$'
    call    add_print_command
    
    mov     ah, 40h  ; write
    lea     dx, [compiler_template]
    push    ds
    push    seg compiler_template
    pop     ds
    int     21h
    jnc      ok11
    call    handle_error
ok11:
    pop     ds
    
    mov     ah, 3eh  ; close file
    int     21h
    jnc      ok2
    call    handle_error
ok2:
    mov     ah, 3dh  ; open file
    mov     al, 0  ; read mode
    lea     dx, [code_filename]
    int     21h
    
    mov     bx, ax
    
    mov     ah, 3fh  ; read from file
    mov     cx, 100  ; read 100 bytes
    lea     dx, [buffer]
    int     21h
    jnc      ok3
    call    handle_error
ok3:
    
    
    mov     ah, 3eh  ; close file
    int     21h
    jnc      ok4
    call    handle_error
ok4:
    
    mov     ah, 09
    lea     dx, [buffer]
    int     21h
    
    push    offset ending
    push    seg ending
    push    offset buffer
    push    seg buffer
    push    0
    push    '$'
    call    get_index
    
    inc     bx  ; we want the index after
    mov     dx, bx  ; store start index
    
    push    offset ending
    push    seg ending
    push    offset buffer
    push    seg buffer
    push    bx
    push    '$'
    call    get_index  ; bx = end index
    
    push    offset buffer
    push    seg buffer
    push    offset buffer2
    push    seg buffer2
    push    dx  ; start
    push    bx  ; end
    call    substring
    
    mov     ah, 09
    lea     dx, [buffer2]
    int     21h
    
    jmp     exit
    
exit:
    mov     ah, 4ch
    mov     al, [exit_code]
    int     21h
endp main
end main
