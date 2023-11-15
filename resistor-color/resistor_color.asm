default rel ; Use relative addressing

section .rodata

; Store each color word as an array of bytes (db) terminating with a `0`
; Each of these is a pointer to the first of a sequence of bytes with a null
; terminator, i.e. `char*`
black: db "black", 0
brown: db "brown", 0
red: db "red", 0
orange: db "orange", 0
yellow: db "yellow", 0
green: db "green", 0
blue: db "blue", 0
violet: db "violet", 0
grey: db "grey", 0
white: db "white", 0

section .data

; Store pointer to each word to be iterated through when looking up a color
; These are 64-bit address, so store as dq (quadword)
; This is a sequence of pointers to `char*`, i.e. a `char**`
color_array: dq black, brown, red, orange, yellow, green, blue, violet, grey, white, 0

section .text

global color_code
color_code:
    ; First argument `rdi` is address of first byte of input word

    ; In contrast to `mov`, which loads a value by dereferencing an address,
    ; `lea` just loads the address, so that we can do pointer arithmetic
    lea rcx, [color_array] ; Load address of `color_array` from .data section
    mov rax, -1 ; Start index at -1 and increment to 0 for first loop

; Loop until array pointer `rdx` reaches end of `color_array` (0)
.array_iter:
    inc rax ; Increment color array index
    ; Load address of nth word by offsetting from `color_array` address
    ; Each word address is 64-bit, so shift by 8 bytes at a time and read into
    ; a 64-bit register
    mov rdx, [rcx + rax * 8]
    cmp rdx, 0 ; Check for end of color array
    je .no_match ; End of colors, failed to find a match

; Loop until a byte in words doesn't match or end of input word
.strcmp:
    mov r8b, byte [rdx] ; Load 1 byte of test word
    mov r9b, byte [rdi] ; Load 1 byte of input word

    cmp r9b, 0 ; Check for end of the input word
    je .done ; End of input word, so this is a match

    cmp r8b, r9b ; Compare
    jne .array_iter ; No match, try next color

    inc rdx ; Increment word pointers to next byte
    inc rdi
    jmp .strcmp ; Continue comparing test word

.no_match:
    mov rax, -1 ; No match found, return with failure

.done:
    ; `rax` is now the index of the given color in `color_array`, or -1 to
    ; indicate failure to find the color
    ret

global colors
colors:
    ; Return address of `color_array`
    lea rax, [color_array]
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
