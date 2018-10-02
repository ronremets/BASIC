; Contains functions that operate on strings
; some of the comments are written in the c language

; private names work like -
; _filename_function_name_variable_name

; a for loop looks like -
; _filename_function_name_loop_name_initialization:
; jmp loop_name_condition
; _filename_function_name_loop_name_update:
; jmp loop_name_condition
; _filename_function_name_loop_name_condition:
; jmp loop_name  ; (if true)
; jmp loop_name_end  ; (if false)
; _filename_function_name_loop_name:
; jmp loop_name_update
; _filename_function_name_loop_name_end:
ideal

;----------GLOBALS----------
STRINGS_FALSE   equ 01
STRINGS_TRUE    equ 00
;---------------------------

codeseg


; get the length of a terminated string and put result in   bx
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
    
    mov     ax, [_strings_strlen_str_ending]
    mov     si, [_strings_strlen_str]
    mov     ds, [_strings_strlen_str_dataseg]
    
    xor     bx, bx
    jmp     _strings_strlen_next_char  ; skip the updating (like in a for loop)

_strings_strlen_next_char_update:
    inc     bx

_strings_strlen_next_char:
    cmp     [ds:si + bx], al  ; did you see the end of str?
    jne _strings_strlen_next_char_update

    pop     ds
    pop     si
    pop     ax
    
    pop     bp
    ret     06
endp strlen


; compare 2 strings and put the result in   al
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


; add '-' to the buffer and print the parse the number * -1 (if it is negitive)
; to the buffer
proc signed_int_to_string
;----------PARAMS----------
_strings_signed_int_to_string_buffer_dataseg   equ bp + 04
_strings_signed_int_to_string_buffer           equ bp + 06
_strings_signed_int_to_string_number           equ bp + 08
;--------------------------
    push    bp
    mov     bp, sp
    
    push    si
    push    ds
    
    mov     si, [_strings_signed_int_to_string_buffer]
    mov     ds, [_strings_signed_int_to_string_buffer_dataseg]
    
    ; if number < 0 then number *= -1 and write - to buffer
    cmp     [word ptr _strings_signed_int_to_string_number], 0000
    jge      _strings_signed_int_to_string_call  ; call normal function if number >= 0
    neg     [word ptr _strings_signed_int_to_string_number]
    mov     [byte ptr ds:si], '-'
    inc     si  ; inc buffer offset by 1 (because of the added '-')
    
_strings_signed_int_to_string_call:
    push    [_strings_signed_int_to_string_number]  ; number
    push    si  ; buffer offset
    push    ds  ; buffer dataseg
    call    int_to_string
    
    pop     ds
    pop     si
    
    pop     bp
    ret     06
endp signed_int_to_string


; parse a number to string in buffer
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
    xor     dx, dx  ; needed for idiv
    idiv    cx  ; number (ax) / 10 (cx); dx stores the digit (reminder) and ax the result
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
_strings_get_index_of_char_str_ending   equ bp + 04  ; the temination symbol (only use lower byte)
_strings_get_index_of_char_start_index  equ bp + 06
_strings_get_index_of_char_str_dataseg  equ bp + 08
_strings_get_index_of_char_str          equ bp + 10  ; where to find
_strings_get_index_of_char_char         equ bp + 12  ; what to find, only use lower byte
;--------------------------
    push    bp
    mov     bp, sp
    
    push    ax
    push    si
    push    ds
    
    mov     si, [_strings_get_index_of_char_str]
    mov     ds, [_strings_get_index_of_char_str_dataseg]
    
    mov     bx, [_strings_get_index_of_char_start_index]
    jmp     _strings_get_index_of_char_next_char  ; skip the updating (like in a for loop)
    
_strings_get_index_of_char_next_char_update:
    inc     bx
_strings_get_index_of_char_next_char:
    mov     al, [ds:si + bx]
    cmp     al, [_strings_get_index_of_char_str_ending]  ; did the string terminate?
    je      _strings_get_index_of_char_not_found
    cmp     al, [_strings_get_index_of_char_char]  ; did you find the char?
    jne     _strings_get_index_of_char_next_char_update
    jmp     _strings_get_index_of_char_end
    
_strings_get_index_of_char_not_found:
    mov     bx, -1
    
_strings_get_index_of_char_end:
    pop     ds
    pop     si
    pop     ax
    
    pop     bp
    ret     10
endp get_index_of_char


; find the index of str1 in a str2 starting at a given index
; and put the result in   bx
; if string not found, return -1
; temination char and the requested string can not be the same!
proc get_index
;----------PARAMS----------
_strings_get_index_str_ending   equ bp + 04  ; the temination symbol (only use lower byte)
_strings_get_index_start_index  equ bp + 06  ; starting index
_strings_get_index_str2_dataseg equ bp + 08
_strings_get_index_str2         equ bp + 10  ; where to find
_strings_get_index_str1_dataseg equ bp + 12
_strings_get_index_str1         equ bp + 14  ; what to find
;--------------------------
;----------VARS----------
_strings_get_index_str1_index   equ bp - 02
_strings_get_index_str2_index   equ bp - 04
_strings_get_index_found_str    equ bp - 06
;------------------------
    push    bp
    mov     bp, sp
    
;----------MALLOC----------
    sub     sp, 6  ; 3 vars
;--------------------------
    
    push    dx
    push    si
    push    di
    push    ds
    push    es
    
    mov     si, [_strings_get_index_str2]
    mov     di, [_strings_get_index_str1]
    mov     ds, [_strings_get_index_str2_dataseg]
    mov     es, [_strings_get_index_str1_dataseg]
    mov     [word ptr _strings_get_index_found_str], STRINGS_FALSE

    ; str2_index = start_index
_strings_get_index_next_char_initialization:
    mov     bx, [_strings_get_index_start_index]  ; set starting index
    mov     [_strings_get_index_str2_index], bx  ; str2 index
    jmp     _strings_get_index_next_char_condition
    
    ; str2_index++
_strings_get_index_next_char_update:
    inc     [word ptr _strings_get_index_str2_index]
    
    ; str2[str2_index] != str_ending
    ; on exit:
    ; found_str = false
_strings_get_index_next_char_condition:
    mov     bx, [_strings_get_index_str2_index]
    mov     dl, [ds:si + bx]  ; get char from str2
    cmp     dl, [_strings_get_index_str_ending]  ; did str2 terminate?
    jne      _strings_get_index_next_char
    ; if str2 terminate, end the loop with false
    mov     [word ptr _strings_get_index_found_str], STRINGS_FALSE
    jmp     _strings_get_index_next_char_end

_strings_get_index_next_char:
    push    [_strings_get_index_str2_index]  ; store the index of str2
    jmp     _strings_get_index_next_found_char_initialization  ; start second loop

    ; str1_index = 0
_strings_get_index_next_found_char_initialization:
    mov     [word ptr _strings_get_index_str1_index], 0
    jmp     _strings_get_index_next_found_char_condition
    
    ; str1_index++, str2_index++
_strings_get_index_next_found_char_update:
    inc     [word ptr _strings_get_index_str1_index]
    inc     [word ptr _strings_get_index_str2_index]

    ; str1[str1_index] != str_ending
_strings_get_index_next_found_char_condition:
    mov     bx, [_strings_get_index_str1_index]
    mov     dl, [es:di + bx]  ; get char from str1
    cmp     dl, [_strings_get_index_str_ending]  ; did str1 terminate?
    jne      _strings_get_index_next_found_char
    mov     [word ptr _strings_get_index_found_str], STRINGS_TRUE  ; if it did, end the loop with true
    jmp     _strings_get_index_next_found_char_end

_strings_get_index_next_found_char:
    mov     bx, [_strings_get_index_str1_index]
    mov     dl, [es:di + bx]  ; get char from str1
    mov     bx, [_strings_get_index_str2_index]
    cmp     dl, [ds:si + bx]  ; is str1[i] equal to str2[i]?
    je      _strings_get_index_next_found_char_update
    ; if they are not, end the loop with false
    mov     [word ptr _strings_get_index_found_str], STRINGS_FALSE
    jmp     _strings_get_index_next_found_char_end
    
_strings_get_index_next_found_char_end:
    pop     [_strings_get_index_str2_index]  ; restore str2 index
    cmp     [word ptr _strings_get_index_found_str], STRINGS_TRUE  ; did you find the string?
    je      _strings_get_index_next_char_end  ; if you did, end the main loop
    jmp     _strings_get_index_next_char_update ; if not, continue the main loop

_strings_get_index_next_char_end:
    cmp     [word ptr _strings_get_index_found_str], STRINGS_TRUE  ; did you find the string?
    je      _strings_get_index_found
    jmp     _strings_get_index_not_found

_strings_get_index_found:
    mov     bx, [_strings_get_index_str2_index]
    jmp     _strings_get_index_end
    
_strings_get_index_not_found:
    mov     bx, -1
    
_strings_get_index_end:
    pop     es
    pop     ds
    pop     di
    pop     si
    pop     dx
    
;----------FREE----------
    add     sp, 6  ; 3 vars
;------------------------
    
    pop     bp
    ret     12
endp get_index


; put in buffer everything from starting index to end index of str
; start index - including
; end index - not including
proc substring
;----------PARAMS----------
_strings_substring_end_index        equ bp + 04
_strings_substring_start_index      equ bp + 06
_strings_substring_buffer_dataseg   equ bp + 08
_strings_substring_buffer           equ bp + 10
_strings_substring_str_dataseg      equ bp + 12
_strings_substring_str              equ bp + 14
;--------------------------
;----------VARS----------
_strings_substring_str_index    equ bp - 02
_strings_substring_buffer_index equ bp - 04
;------------------------
    push    bp
    mov     bp, sp
    
;----------MALLOC----------
    sub     sp, 4  ; 2 vars
;--------------------------
    
    push    bx
    push    dx
    push    si
    push    di
    push    ds
    push    es
    
    mov     si, [_strings_substring_str]
    mov     di, [_strings_substring_buffer]
    mov     ds, [_strings_substring_str_dataseg]
    mov     es, [_strings_substring_buffer_dataseg]
    
    ; str_index = start_index, buffer_index = 0
_strings_substring_next_char_initialization:
    mov     bx, [_strings_substring_start_index]
    mov     [_strings_substring_str_index], bx  ; set starting index
    mov     [word ptr _strings_substring_buffer_index], 0
    jmp     _strings_substring_next_char_condition
    
    ; str_index++, buffer_index++
_strings_substring_next_char_update:
    inc     [word ptr _strings_substring_str_index]
    inc     [word ptr _strings_substring_buffer_index]

    ; str_index != end_index
_strings_substring_next_char_condition:
    mov     bx, [_strings_substring_str_index]
    cmp     bx, [_strings_substring_end_index]  ; did str terminate?
    je      _strings_substring_next_char_end
    
_strings_substring_next_char:
    mov     bx, [_strings_substring_str_index]
    mov     dl, [ds:si + bx]  ; get str char
    mov     bx, [_strings_substring_buffer_index]
    mov     [es:di + bx], dl  ; assign to buffer
    jmp     _strings_substring_next_char_update
    
_strings_substring_next_char_end:
    pop     es
    pop     ds
    pop     di
    pop     si
    pop     dx
    pop     bx
    
;----------FREE----------
    add     sp, 4  ; 2 vars
;------------------------
    
    pop     bp
    ret     12
endp substring


proc strcpy
;----------PARAMS----------
_strings_strcpy_ending          equ bp + 04
_strings_strcpy_start_index     equ bp + 06
_strings_strcpy_buffer_dataseg  equ bp + 08
_strings_strcpy_buffer          equ bp + 10
_strings_strcpy_str_dataseg     equ bp + 12
_strings_strcpy_str             equ bp + 14
;--------------------------
;----------VARS----------
_strings_strcpy_str_index    equ bp - 02
_strings_strcpy_buffer_index equ bp - 04
;------------------------
    push    bp
    mov     bp, sp
    
;----------MALLOC----------
    sub     sp, 4  ; 2 vars
;--------------------------
    
    push    bx
    push    dx
    push    si
    push    di
    push    ds
    push    es
    
    mov     si, [_strings_strcpy_str]
    mov     di, [_strings_strcpy_buffer]
    mov     ds, [_strings_strcpy_str_dataseg]
    mov     es, [_strings_strcpy_buffer_dataseg]
    
    ; str_index = 0, buffer_index = start_index
_strings_strcpy_next_char_initialization:
    mov     bx, [_strings_strcpy_start_index]
    mov     [_strings_strcpy_buffer_index], bx  ; set starting index
    mov     [word ptr _strings_strcpy_str_index], 0
    jmp     _strings_strcpy_next_char_condition
    
    ; str_index++, buffer_index++
_strings_strcpy_next_char_update:
    inc     [word ptr _strings_strcpy_str_index]
    inc     [word ptr _strings_strcpy_buffer_index]

    ; str_index != ending
_strings_strcpy_next_char_condition:
    mov     bx, [_strings_strcpy_str_index]
    mov     dl, [ds:si + bx]
    cmp     dl, [_strings_strcpy_ending]  ; did str terminate?
    je      _strings_strcpy_next_char_end
    
_strings_strcpy_next_char:
    mov     bx, [_strings_strcpy_str_index]
    mov     dl, [ds:si + bx]  ; get str char
    mov     bx, [_strings_strcpy_buffer_index]
    mov     [es:di + bx], dl  ; assign to buffer
    jmp     _strings_strcpy_next_char_update
    
_strings_strcpy_next_char_end:
    pop     es
    pop     ds
    pop     di
    pop     si
    pop     dx
    pop     bx
    
;----------FREE----------
    add     sp, 4  ; 2 vars
;------------------------
    
    pop     bp
    ret     12
endp strcpy

