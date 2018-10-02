ideal
model small
stack 100h

include "COMPILER.ASM"

dataseg

exit_code   db  0
filename    db  'code.txt', 0
buffer      db  100 dup('$')
num         dw  00ffh
msg         db  ' $'
hello       db  ' $'
codeseg


proc main
    mov     ax, @data
    mov     ds, ax
    
    ;push    offset compiler_template
    ;push    seg compiler_template
    ;push    offset msg
    ;push    seg msg
    ;push    '$'
    ;call    add_print_command
    
    ;push    ds
    ;mov     dx, offset compiler_template
    ;push    seg compiler_template
    ;pop     ds
    ;mov     ah, 09
    ;int     21h
    ;pop     ds
    
    push    offset hello
    push    seg hello
    push    offset msg
    push    seg msg
    push    0000    
    push    '$'
    call    get_index
    
    push    bx
    push    offset buffer
    push    seg buffer
    call    signed_int_to_string
    
    lea     dx, [buffer]
    mov     ah, 09
    int     21h
    
exit:
    mov     ah, 4ch
    mov     al, [exit_code]
    int     21h
endp main
end main
