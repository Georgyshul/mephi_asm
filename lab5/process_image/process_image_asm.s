section .data
    ; Syscall
    SYS_READ    equ 0
    SYS_WRITE   equ 0x01
    SYS_OPEN    equ 0x02
    SYS_CLOSE   equ 0x03
    SYS_MMAP    equ 0x09
    SYS_MUNMAP  equ 0x0b
    SYS_EXIT    equ 0x3c

    ; Lengths
    length_header               equ 0x36
    length_footer               equ 0x54
    length_input_file_error     equ 29
    length_output_file_error    equ 30

    ; Messages
    input_file_error    db "Error: can't open input file", 0x0a, 0
    output_file_error   db "Error: can't open output file", 0x0a, 0

section .bss
    header  resb length_header
    footer  resb length_footer

section .text
    global  process_image

process_image:
    ; Arguments: rdi = input_filename, rsi = output_filename

    lea     rdi, [rdi]      ; input_filename
    push    rsi             ; save output_filename

    ; scan_image(input_filename)
    call    scan_image

    ; Save for writing
    push    rax     ; save size
    push    rbx     ; save data

    ; Process image data
    mov     rcx, rax
    .loop:
        test    rcx, rcx
        jz      .end_loop

        ; Load r, g, b
        movzx   rdi, byte [rbx]
        movzx   rsi, byte [rbx + 0x01]
        movzx   rdx, byte [rbx + 0x02]

        ; Gray = MAX(r, g, b)
        ; max(r = rdi, g = rsi, b = rdx)
	call    max

        ; Update r, g, b
        mov     byte [rbx], al
        mov     byte [rbx + 0x01], al
        mov     byte [rbx + 0x02], al

        add     rbx, 3
        sub     rcx, 3
        jmp     .loop
    .end_loop:

    ; write_image(output_filename = rdi, data = rsi, size = rdx)
    pop     rsi
    pop     rdx
    pop     rdi
    call    write_image

    ; munmap(address = rdi, length = rsi)
    mov     rax, SYS_MUNMAP
    mov     rdi, rdx
    mov     rsi, rcx
    syscall
    ret

scan_image:
    ; Arguments: rdi = input_filename
    mov     rax, SYS_OPEN
    xor     rsi, rsi        ; no flags
    xor     rdx, rdx        ; no permissions
    syscall                 ; open(pathname = rdi, flags = rsi, mode = rdx)
    cmp     rax, 0          ; check if file opened successfully
    jge     .continue
        mov     rdi, input_file_error           ; message
        mov     rsi, length_input_file_error    ; length
        call    error_exit                      ; error_exit(message = rdi, length = rsi)
    .continue:

    ; Save file descriptor
    mov     r10, rax

    ; Read header
    mov     rax, SYS_READ
    mov     rdi, r10     ; file descriptor
    mov     rsi, header  ; buffer
    mov     rdx, 0x36    ; count
    syscall              ; read(fd = rdi, buf = rsi, count = rdx)

    ; Get width and height from header
    mov     eax, dword[rsi + 0x12]
    mov     ebx, dword[rsi + 0x16]

    ; Calculate size = 3 * width * height
    imul    rax, rbx
    imul    rax, 0x03
    push    rax

    ; Map memory for data
    push    r10
    mov     rsi, rax        ; length
    mov     rax, SYS_MMAP
    xor     rdi, rdi        ; starting address
    mov     rdx, 0x03       ; PROT_READ | PROT_WRITE
    mov     r10, 0x21       ; MAP_SHARED | MAP_ANONYMOUS
    mov     r8, -1          ; no file descriptor
    xor     r9, r9          ; no offset
    syscall                 ; mmap(addr = rdi, length = rsi, prot = rdx, flags = r10, fd = r8, offset = r9)
    mov     rbx, rax        ; save the pointer into rbx
    pop     r10

    ; Read data into mapped memory
    mov     rax, SYS_READ
    mov     rdi, r10        ; file descriptor
    mov     rdx, rsi        ; count
    mov     rsi, rbx        ; buffer
    syscall                 ; read(fd = rdi, buf = rsi, count = rdx)

    ; Read footer
    mov     rax, SYS_READ
    mov     rdi, r10        ; file descriptor
    mov     rdx, 0x54       ; count
    mov     rsi, footer     ; buffer
    syscall                 ; read(fd = rdi, buf = rsi, count = rdx)

    ; Return size
    pop     rax
    ret

write_image:
    ; Arguments: rdi = output_filename, rsi = data, rdx = size
    ; Save arguments
    push    rsi     ; data
    push    rdx     ; size

    ; Open file
    mov     rax, SYS_OPEN
    mov     rsi, 102o       ; write and create file flags
    mov     rdx, 600o       ; user read/write permissions
    syscall                 ; open(filename = rdi, flags = rsi, mode = rdx)
    cmp     rax, 0          ; check if file opened successfully
    jge     .continue
        mov     rdi, output_file_error              ; message
        mov     rsi, length_output_file_error       ; length
        call    error_exit                          ; error_exit(message = rdi, length = rsi)
    .continue:

    ; Save file descriptor
    mov     r10, rax

    ; Write header
    ; write(fd = rdi, header = rsi, count = rdx)
    mov     rax, SYS_WRITE
    mov     rdi, r10
    mov     rsi, header
    mov     rdx, length_header
    syscall

    ; Write data;
    ; write(fd = rdi, data = rsi, count = rdx)
    mov     rax, SYS_WRITE
    mov     rdi, r10
    pop     rdx
    pop     rsi
    syscall

    ; Write footer
    ; write(fd = rdi, footer = rsi, count = rdx)
    mov     rax, SYS_WRITE
    mov     rdi, r10
    mov     rsi, footer
    mov     rdx, length_footer
    syscall

    ; Close file
    ; close(fd = rdi)
    mov     rax, SYS_CLOSE
    mov     rdi, r10
    syscall
    ret

max:
    ; Arguments: rdi = r, rsi = g, rdx = b
    mov    rax, rdi
    cmp    rax, rsi
    jge    .second
        mov    rax, rsi
    .second:
    cmp    rax, rdx
    jge    .ret
        mov    rax, rdx
    .ret:
	ret

error_exit:
    ; Arguments: rdi = message, rsi = length

    ; write(fd = rdi, str = rsi, length = rdx)
    mov     rax, SYS_WRITE
    mov     rdx, rsi        ; count
    mov     rsi, rdi        ; message
    mov     rdi, 1          ; stdout descriptor
    syscall

    ; Terminate program
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall
