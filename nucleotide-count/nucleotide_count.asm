section .text
global nucleotide_counts
nucleotide_counts:
    ; `rdi` = char* nucleotide, `rsi` = *int64_t counts

    mov rbx, -1 ; Index into nucleotide string buffer
    ; Initialise counters for each nucleotide
    mov r11, 0
    mov r12, 0
    mov r13, 0
    mov r14, 0

.nucleotide_iter:
    inc rbx ; Move to next byte
    mov cl, byte [rdi + rbx] ; Read byte into register from input buffer

    cmp cl, 0 ; Check for end of string
    je .success

    ; Increment the counter corresponding to the nucleotide
    cmp cl, "A"
    je .adenine
    cmp cl, "C"
    je .cytosine
    cmp cl, "G"
    je .guanine
    cmp cl, "T"
    je .thymine

    jmp .failure ; Invalid byte, return failure

.adenine:
    inc r11
    jmp .nucleotide_iter
.cytosine:
    inc r12
    jmp .nucleotide_iter
.guanine:
    inc r13
    jmp .nucleotide_iter
.thymine:
    inc r14
    jmp .nucleotide_iter

.success:
    mov rax, 0
    ; Populate output buffer at address `rsi` with counts
    ; Each element is 64-bit so increment by 8 bytes at a time
    mov [rsi], r11
    mov [rsi + 8], r12
    mov [rsi + 16], r13
    mov [rsi + 24], r14
    ret

.failure:
    mov rax, -1
    ; Populate output buffer with -1 to show invalid
    mov [rsi], rax
    mov [rsi + 8], rax
    mov [rsi + 16], rax
    mov [rsi + 24], rax
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
