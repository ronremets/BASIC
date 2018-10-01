ideal
model small
stack 100h

include "COMPILER.ASM"

dataseg

exit_code   db  0
filename    db  'code.txt', 0
buffer      db  100 dup('$')
buffer2     db  100 dup('$')

codeseg


proc main
    mov     ax, @data
    mov     ds, ax
    
    push    offset filename
    push    seg filename
    call    open

    cmp     ax, 0
    jne     exit1
    jmp     skip
exit1: jmp exit
skip:
    
    push    bx
    push    0005
    push    offset buffer
    push    seg buffer
    call    read
    
    push    offset compiler_print_command
    push    seg compiler_print_command
    push    offset buffer
    push    seg buffer
    push    '$'
    call    strcmp
    cmp     al, STRINGS_TRUE
    jne     fin

    push    bx
    push    0022
    push    offset buffer
    push    seg buffer
    call    read
    
fin:
    push    bx
    call    close
    
    push    offset buffer
    push    seg buffer
    push    '$'
    call    strlen
    
    push    bx
    push    offset buffer2
    push    seg buffer2
    call    int_to_string
    
    mov     ah, 09
    lea     dx, [buffer2]
    int     21h
    
    mov     ah, 09
    lea     dx, [buffer]
    int     21h
    
exit:
    mov     ah, 4ch
    mov     al, [exit_code]
    int     21h
endp main
end main
