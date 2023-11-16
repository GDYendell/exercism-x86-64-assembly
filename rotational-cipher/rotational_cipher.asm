default rel ; Use relative addressing

section .data
up_a: db 65
up_z: dq 90 ; This must be dq to be used with cmov and zero the upper bytes
down_a: db 97
down_z: db 122
alpha_length: db 26

section .text
global rotate
rotate:
    ; `rdi` = char*: input, `rsi` = int: shift, `rdx` = char*: output

    ; Restrict shift to 0-26
    push rdx ; Preserve `rdx` output buffer
    mov rax, rsi ; Move shift into `rax` for `div`
    mov r8, 26 ;
    mov rdx, 0 ; Clear remainder output
    div r8 ; Remainder -> `rdx`
    mov rsi, rdx ; Move restricted shift back in to `rsi`
    pop rdx ; Restore `rdx` output buffer

    mov rbx, -1 ; Initialise index for buffers - start at -1 to inc to 0

; Loop through input and construct shifted output
.array_iter:
    inc rbx ; Move to next index
    mov r9, 0
    mov r11, 0
    mov r9b, byte [rdi + rbx] ; Load byte from input

    cmp r9b, 0 ; Check for end of input
    je .done

    ; Check if byte is a letter
    cmp r9b, [up_a] ; Store directly if below upper case letters
    jl .store
    cmp r9b, [down_z] ; or above lower case letters
    jg .store
    cmp r9b, [down_a] ; or if below lower case letters
    jl .check_between_letters
    jmp .shift ; Else do shift

.check_between_letters:
    ; Assume byte is less than `down_a` at this point
    cmp r9b, [up_z] ; If also more than `up_z` it is not a letter
    jg .store

.shift:
    ; Check if byte is upper or lower case to determine upper bound
    mov r11b, [down_z] ; Load 'z' as upper bound
    cmp r9b, [down_a]
    cmovl r11, [up_z] ; Load 'Z' if input byte < 'a'

    ; Shift value and wrap around 'z' + 1 -> 'a'
    ; This uses 16-bit arithmetic to avoid 8-bit overflow
    add r9w, si ; Shift value (`si` is bytes 0-1 of `rsi`)
    cmp r9w, r11w ; Store if less than upper bound
    jle .store
    sub r9w, [alpha_length] ; Else wrap around

.store:
    mov byte [rdx + rbx], r9b ; Store result in output
    jmp .array_iter ; Continue to next byte

.done:
    mov byte [rdx + rbx], 0 ; Null terminate output
    mov rax, 0 ; Void return value
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
