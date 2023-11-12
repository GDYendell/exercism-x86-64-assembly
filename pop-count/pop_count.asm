section .text
global egg_count
egg_count:
    ; Initialise count to return
    mov rax, 0
.loop:
    ; Shift input right
    shr rdi, 1
    ; Skip increment if no carry (truncated bit was 0)
    jnc .checkdone
    ; Else add bit to counter
    inc rax
.checkdone:
    ; Compare input to 0
    cmp rdi, 0
    ; Continue to next loop if input still greater than 0
    jg .loop
    ; Else done
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
