section .text
global square
square:
    ; Return 0 if input is <=0
    mov rax, 0
    cmp rdi, 0
    jle .done
    ; or >=65
    cmp rdi, 65
    jge .done

    ; Initialise first bit of return value
    mov rax, 1
    ; Move input into `rcx` to use `cl` as shift operand
    mov rcx, rdi
    ; Decrement square number input in `cl` to be index of square
    dec cl
    ; Shift 1 left by index of square to give count on that square
    shl rax, cl
.done:
    ; Return count in `rax`
    ret

global total
total:
    ; Return max u64
    mov rax, -1
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
