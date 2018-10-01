; Contains functions that operate on strings
; some of the comments are written in the c language
ideal

;----------GLOBALS----------
STRINGS_FALSE   equ 01
STRINGS_TRUE    equ 00
;---------------------------

codeseg


; get the length of a null terminated string and put result in   bx
proc strlen
;----------PARAMS----------
_strings_strlen_str_ending  equ bp + 04  ; the temination symbol (the lower byte)
_strings_strlen_str_dataseg equ bp + 06
_strings_strlen_str         equ bp + 08
;--------------------------
    push    bp
    mov     bp, sp

    push    ax
    push    si
    push    ds
    
    mov     si, [_strings_strlen_str]
    mov     ds, [_strings_strlen_str_dataseg]
    mov     ax, [_strings_strlen_str_ending]
    
    xor     bx, bx
    jmp     _strings_strlen_next_char  ; skip the updating (like in a for loop)

_strings_strlen_next_char_update:
    inc     bx
_strings_strlen_next_char:
    cmp     [ds:si + bx], al  ; did you see the end of str?
    jne _strings_strlen_next_char

    pop     ds
    pop     si
    pop     ax
    
    pop     bp
    ret     06
endp strlen


; compare 2 strings and put the result in   ax (in al)
proc strcmp
;----------PARAMS----------
_strings_strcmp_str_ending      equ bp + 04  ; the temination symbol (the lower byte)
_strings_strcmp_str2_dataseg    equ bp + 06
_strings_strcmp_str2            equ bp + 08
_strings_strcmp_str1_dataseg    equ bp + 10
_strings_strcmp_str1            equ bp + 12
;--------------------------
    push    bp
    mov     bp, sp
    
    push    bx
    push    dx
    push    si
    push    di
    push    ds
    push    es
    
    mov     al, [byte ptr _strings_strcmp_str_ending]
    mov     si, [_strings_strcmp_str1]
    mov     di, [_strings_strcmp_str2]
    mov     ds, [_strings_strcmp_str1_dataseg]
    mov     es, [_strings_strcmp_str2_dataseg]
    
    xor     bx, bx
_strings_strcmp_next_char:
    mov     dl, [ds:si + bx]
    cmp     dl, [es:di + bx]  ; is str1[bx] equal to str2[bx]?
    jne     _strings_strcmp_not_equal
    
    cmp     dl, al  ; did str1 terminate?
    je      _strings_strcmp_equal
    inc     bx
    jmp     _strings_strcmp_next_char
    
_strings_strcmp_equal:
    mov     al, STRINGS_TRUE  ; str1 == str2
    jmp     _strings_strcmp_end

_strings_strcmp_not_equal:
    mov     al, STRINGS_FALSE  ; str1 != str2
    
_strings_strcmp_end:
    pop     es
    pop     ds
    pop     di
    pop     si
    pop     dx
    pop     bx
    
    pop     bp
    ret     10
endp strcmp


proc int_to_string
;----------PARAMS----------
_strings_int_to_string_buffer_dataseg   equ bp + 04
_strings_int_to_string_buffer           equ bp + 06
_strings_int_to_string_number           equ bp + 08
;--------------------------
    push    bp
    mov     bp, sp
    
    push    ax
    push    bx
    push    cx
    push    dx
    push    ds
    
    mov     ax, [_strings_int_to_string_number]
    mov     cx, 10  ; a constant for div (for base 10), this is not a variable for speed
    mov     di, [_strings_int_to_string_buffer]
    mov     ds, [_strings_int_to_string_buffer_dataseg]
    
    xor     bx, bx
_strings_int_to_string_next_digit:
    xor     dx, dx
    div     cx  ; number / 10; dx stores the digit (reminder) and ax the result
    add     dl, '0' ; dx will always be < 10 since we divide by 10
    mov     [ds:di + bx], dl  ; store the digit in the buffer
    inc     bx
    cmp     ax, 0000
    jne     _strings_int_to_string_next_digit
    
    pop     ds
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    
    pop     bp
    ret     06
endp int_to_string


; find the index of char in a string and put the result in   bx
; if char not found, return -1
; temination char and the requested char can not be the same!
proc get_index_of_char
;----------PARAMS----------
_strings_get_index_of_char_str_ending   equ bp + 04 ; the temination symbol (only use lower byte)
_strings_get_index_of_char_str_dataseg  equ bp + 06
_strings_get_index_of_char_str          equ bp + 08
_strings_get_index_of_char_char         equ bp + 10 ; only use lower byte
;--------------------------
    push    bp
    mov     bp, sp
    
    push    ax
    push    dx
    push    si
    push    ds
    
    mov     dh, [_strings_get_index_of_char_char]
    mov     dl, [_strings_get_index_of_char_str_ending]
    mov     si, [_strings_get_index_of_char_str]
    mov     ds, [_strings_get_index_of_char_str_dataseg]
    
    xor     bx, bx
    jmp     _strings_get_index_of_char_next_char  ; skip the updating (like in a for loop)
    
_strings_get_index_of_char_next_char_update:
    inc     bx
_strings_get_index_of_char_next_char:
    mov     al, [ds:si + bx]
    cmp     al, dl  ; did the string terminate?
    je      _strings_get_index_of_char_not_found
    cmp     al, dh  ; did you find the char?
    jne     _strings_get_index_of_char_next_char_update
    jmp     _strings_get_index_of_char_end
    
_strings_get_index_of_char_not_found:
    mov     bx, -1
    
_strings_get_index_of_char_end:
    pop     ds
    pop     si
    pop     dx
    pop     ax
    
    pop     bp
    ret     08
endp get_index_of_char


; find the index of str1 in a str2 and put the result in   bx
; if string not found, return -1
; temination char and the requested string can not be the same!
proc get_index
;----------PARAMS----------
_strings_get_index_str_ending   equ bp + 04 ; the temination symbol (only use lower byte)
_strings_get_index_str2_dataseg equ bp + 06
_strings_get_index_str2         equ bp + 08
_strings_get_index_str1_dataseg equ bp + 10
_strings_get_index_str1         equ bp + 12
;--------------------------
    push    bp
    mov     bp, sp
    
    push    ax
    push    cx
    push    dx
    push    si
    push    ds
    
    mov     dh, [_strings_get_index_str_ending]
    mov     si, [_strings_get_index_str2]
    mov     di, [_strings_get_index_str1]
    mov     ds, [_strings_get_index_str2_dataseg]
    mov     es, [_strings_get_index_str1_dataseg]

    xor     ax, ax  ; str2 index
    xor     cx, cx  ; str1 index
    jmp     _strings_get_index_next_char  ; skip the updating (like in a for loop)
    
_strings_get_index_next_char_update:
    inc     ax
_strings_get_index_next_char:
    mov     bx, ax
    mov     dl, [ds:si + bx]  ; get char from str2
    cmp     dl, [_strings_get_index_str_ending]  ; did str2 terminate?
    je      _strings_get_index_not_found
    
    push    ax  ; store the index of str2
    jmp     _strings_get_index_next_found_char  ; skip the updating (like in a for loop)
    
_strings_get_index_next_found_char_update:
    inc     cx
    inc     ax
_strings_get_index_next_found_char:
    mov     bx, cx  ; only bx can be used for indexing ):
    mov     dl, [es:di + bx]  ; get char from str1
    cmp     dl, [_strings_get_index_str_ending]  ; did str1 terminate?
    je      _strings_get_index_found
    
    mov     bx, ax  ; only bx can be used for indexing ):
    cmp     dl, [ds:si + bx]  ; is str1[cx] equal to str2[ax]?
    je      _strings_get_index_next_char_update
    pop     ax  ; str1 was not found, so restore it's index
    xor     cx, cx  ; prepare cx for next loop
    jmp     _strings_get_index_next_char_update
    
_strings_get_index_found:
    mov     bx, ax
    jmp     _strings_get_index_end
    
_strings_get_index_not_found:
    mov     bx, -1
    
_strings_get_index_end:
    pop     ds
    pop     si
    pop     dx
    pop     cx
    pop     ax
    
    pop     bp
    ret     10
endp get_index