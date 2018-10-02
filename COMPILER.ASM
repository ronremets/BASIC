ideal

include "STRINGS.ASM"

dataseg

;----------COMMANDS----------
compiler_print_command      db  'PRINT $'
compiler_print_asm_prefix   db  'mov ah, 09', 13, 10
                            db  'lea dx, [str$'
compiler_print_asm_suffix   db  ']', 13, 10
                            db  'int 21h', 13, 10, '$'
;----------------------------

compiler_str_count      db 0  ; how many const str exist

compiler_code_label     db ';code', 13, 10, 0

compiler_template       db  'ideal', 13, 10
                        db  'model small', 13, 10
                        db  'stack 100h',13,10
                        db  'dataseg', 13, 10
                        db  ';data', 13, 10
                        db  256h dup('$')  ; this is the size of your data
                        db  13, 10
                        db  'codeseg', 13, 10
                        db  'proc main', 13, 10
                        db  'mov ax, @data', 13, 10
                        db  'mov ds, ax', 13, 10
                        db  ';code', 13, 10
                        db  256h dup('$')  ; this is the size of your code
                        db  13, 10
                        db  'endp main', 13, 10
                        db  'end main', 13, 10, 0

codeseg


; adds print to code
; note!: the termination of the code label and str must ne the same!
proc add_print_command
;----------PARAMS----------
_compiler_add_print_command_str_ending      equ bp + 04
_compiler_add_print_command_str_dataseg     equ bp + 06
_compiler_add_print_command_str             equ bp + 08
_compiler_add_print_command_code_dataseg    equ bp + 10
_compiler_add_print_command_code            equ bp + 12
;--------------------------
;----------VARS----------
_compiler_add_print_code_label_length   equ bp - 02
_compiler_add_print_print_prefix_length equ bp - 04
_compiler_add_print_print_suffix_length equ bp - 06
;------------------------
    push    bp
    mov     bp, sp
    
;----------MALLOC----------
    sub     sp, 6  ; 3 vars
;--------------------------
    
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di
    push    ds
    push    es
    
    xor     ax, ax
    mov     si, [_compiler_add_print_command_str]
    mov     di, [_compiler_add_print_command_code]
    mov     ds, [_compiler_add_print_command_str_dataseg]
    mov     es, [_compiler_add_print_command_code_dataseg]
    
    push    offset compiler_code_label
    push    seg compiler_code_label
    push    ax  ; 0
    call    strlen  ; stored in bx
    mov     [_compiler_add_print_code_label_length], bx
    
    push    offset compiler_print_asm_prefix
    push    seg compiler_print_asm_prefix
    push    [_compiler_add_print_command_str_ending]
    call    strlen  ; stored in bx
    mov     [_compiler_add_print_print_prefix_length], bx
    
    push    offset compiler_print_asm_suffix
    push    seg compiler_print_asm_suffix
    push    [_compiler_add_print_command_str_ending]
    call    strlen  ; stored in bx
    mov     [_compiler_add_print_print_suffix_length], bx
    
    push    offset compiler_code_label
    push    seg compiler_code_label
    push    [_compiler_add_print_command_code]
    push    [_compiler_add_print_command_code_dataseg]
    push    ax  ; 0
    push    ax  ; 0
    call    get_index  ; stored in bx
    
    add     bx, [_compiler_add_print_code_label_length]  ; get to the end of the code label
    
    ;add_str_const  str
    
    push    offset compiler_print_asm_prefix
    push    seg compiler_print_asm_prefix
    push    [_compiler_add_print_command_code]
    push    [_compiler_add_print_command_code_dataseg]
    push    bx
    push    [_compiler_add_print_command_str_ending]
    call    strcpy
    
    add     bx, [_compiler_add_print_print_prefix_length]
    mov     dl, [compiler_str_count]
    add     dl, '0'
    mov     [es:di + bx], dl
    inc     bx
    
    push    offset compiler_print_asm_suffix
    push    seg compiler_print_asm_suffix
    push    [_compiler_add_print_command_code]
    push    [_compiler_add_print_command_code_dataseg]
    push    bx
    push    [_compiler_add_print_command_str_ending]
    call    strcpy
    
    add     bx, [_compiler_add_print_print_suffix_length]

    pop     es
    pop     ds
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    
;----------FREE----------
    add     sp, 6  ; 3 vars
;------------------------
    
    pop     bp
    ret     10
endp add_print_command
