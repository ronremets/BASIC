ideal
model small
stack 100h

include "COMPILER.ASM"

dataseg

exit_code   db  0
filename    db  'code.txt', 0
buffer      db  100 dup('$')
num         dw  0ffh
msg         db  'hello world$'

codeseg


proc main
    mov     ax, @data
    mov     ds, ax
    
    push    offset compiler_template
    push    seg compiler_template
    push    offset msg
    push    seg msg
    push    '$'
    call    add_print_command
    
    push    ds
    mov     dx, offset compiler_template
    push    seg compiler_template
    pop     ds
    mov     ah, 09
    int     21h
    pop     ds
    
exit:
    mov     ah, 4ch
    mov     al, [exit_code]
    int     21h
endp main
end main
