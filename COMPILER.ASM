ideal

include "STRINGS.ASM"

dataseg

;----------COMMANDS----------
compiler_print_command  db  'PRINT$'
;----------------------------

compiler_str_count      db 0  ; how many const str exist

compiler_code_label     db 'code:', 13, 10, 0

compiler_template       db  'ideal', 13, 10
                        db  'model small', 13, 10
                        db  'stack 100h',13,10
                        db  'dataseg', 13, 10
                        db  'codeseg', 13, 10
                        db  'proc main', 13, 10
                        db  'mov ax, @data', 13, 10
                        db  'mov ds, ax', 13, 10
                        db  'code:', 13, 10
                        db  256 dup(0)  ; this is the size of your code
                        db  'endp main', 13, 10
                        db  'end main', 13, 10, '$'

codeseg


; opens a file and puts in   bx   the file handle and in   ax   the error code
; ax = 0: no error
; ax = 2: file not found
; ax = 5: too many opened files
; ax = 12: permission denied
proc open
;----------PARAMS----------
_compiler_open_filename_dataseg equ bp + 04
_compiler_open_filename         equ bp + 06
;--------------------------
    push    bp
    mov     bp, sp
    
    push    dx
    push    ds
    
    mov     ah, 3Dh                                 ; open a file
    mov     al, 0                                   ; mode: read
    mov     dx, [_compiler_open_filename]           ; file name: filename
    mov     ds, [_compiler_open_filename_dataseg]   ; set ds to filename's ds
    int     21h
    jc      _compiler_open_open_end                 ; if an error happened then don't do ax = 0
    
    mov     bx, ax                                  ; put the file handle in bx
    xor     ax, ax                                  ; no error so ax = 0

_compiler_open_open_end:
    pop     ds
    pop     dx
        
    pop     bp
    ret     04
endp open


; closes a file
proc close
;----------PARAMS----------
_compiler_close_handle  equ bp + 04
;--------------------------
    push    bp
    mov     bp, sp
    
    push    ax
    push    bx
    
    mov     ah, 3Eh                         ; close a file
    mov     bx, [_compiler_close_handle]    ; file handler: handle
    int     21h
    
    pop     ax
    pop     bx
    
    pop     bp
    ret     02
endp close


; read from a file. ax will have the num of bytes read or error code
; ax = 2: file not found
; ax = 5: too many opened files
; ax = 12: permission denied
proc read
;----------PARAMS----------
_compiler_read_buffer_dataseg   equ bp + 04
_compiler_read_buffer           equ bp + 06
_compiler_read_size             equ bp + 08
_compiler_read_handle           equ bp + 10
;--------------------------
    push    bp
    mov     bp, sp
    
    push    bx
    push    cx
    push    dx
    push    ds
    
    mov     ah, 3Fh                             ; read from a file
    mov     bx, [_compiler_read_handle]         ; file handler: handle
    mov     cx, [_compiler_read_size]           ; number of bytes: size
    mov     dx, [_compiler_read_buffer]         ; buffer: buffer
    mov     ds, [_compiler_read_buffer_dataseg] ; buffer dataseg: buffer_dataseg
    int     21h
    
    pop     ds
    pop     dx
    pop     cx
    pop     bx
    
    pop     bp
    ret     08
endp read


; adds print to 
proc add_print_command
;----------PARAMS----------
_compiler_add_print_command_str_ending      equ bp + 04
_compiler_add_print_command_str_dataseg     equ bp + 06
_compiler_add_print_command_str             equ bp + 08
_compiler_add_print_command_code_dataseg    equ bp + 10
_compiler_add_print_command_code            equ bp + 12
;--------------------------
    push    bp
    mov     bp, sp
    
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di
    push    ds
    push    es
    
    mov     si, [_compiler_add_print_command_str_dataseg]
    mov     di, [_compiler_add_print_command_code]
    mov     ds, [_compiler_add_print_command_str_dataseg]
    mov     es, [_compiler_add_print_command_code_dataseg]
    
    push    offset compiler_code_label
    push    seg compiler_code_label
    push    [_compiler_add_print_command_code]
    push    [_compiler_add_print_command_code_dataseg]
    push    [_compiler_add_print_command_str_ending]
    call    get_index  ; stored in bx
    
    mov     ax, bx  ; store the index
    
    push    offset compiler_code_label
    push    seg compiler_code_label
    push    [_compiler_add_print_command_str_ending]
    call    strlen
    
    add     ax, bx  ; get to the end of the label
    xor     cx, cx
    jmp     _compiler_add_print_command_next_char
    
_compiler_add_print_command_next_char_update:
    inc     ax
    inc     cx
_compiler_add_print_command_next_char:
    mov     bx, ax
    mov     dl, [ds:si + bx]
    
    cmp     dl, [_compiler_add_print_command_str_ending]  ; did the string finish?
    je      _compiler_add_print_command_end

    mov     bx, cx
    mov     [es:di + bx], dl
    jmp     _compiler_add_print_command_next_char_update
    
_compiler_add_print_command_end:
    pop     es
    pop     ds
    pop     di
    pop     si
    pop     dx
    pop     cx
    push    bx
    pop     ax
    
    pop     bp
    ret     10
endp add_print_command
