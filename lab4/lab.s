bits 64

; implementation of asin(x) from math.h
; data type -- double
; in argv should be passed logfile name
; output: 	--math.h result::stdout
;		--custom result::stdout
;		--series elements::logfile
section .data
	msg_scan_x	db "input x: ", 0
	msg_scan_n	db "input n: ", 0
	msg_test	db "test", 0

	specifier_double	db "%lf", 0
	specifier_int		db "%d", 0

	msg_res_library	db "Library result: %20.15lf", 0x0a, 0
	msg_res_custom	db "Custom result:  %20.15lf", 0x0a, 0

	log_into_file	db "%.15lf", 0x0a, 0
 
	x		dq 0
	n		dq 0
	accuracy	dq 0
	res_lib		dq 0
	res_cus		dq 0

	file_open_mode	db "w", 0
	filename	db 0


section .text
	extern 	scanf
	extern	printf
	extern	asin
	extern	fopen
	extern	fclose
	extern	fprintf
	global 	main

main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 0x10

	; save filename from argv into memory
	mov	rax, [rsi + 8]
	mov	rax, [rax]
	mov	[filename], rax

	xor 	rax, rax
	call	scan_x
	
	; check if |x|<=1
	call	check_x
	cmp	rax, 0
	jnz	.ret

	xor	eax, eax
	call	scan_n

	; check if n>=1
	cmp	qword[n], 1
	jl	.ret

	call 	calc_accuracy

	call 	my_asin

	movsd	xmm0, [res_cus]
	lea	rax, msg_res_custom
	mov	rdi, rax
	mov	eax, 1
	call	printf
	
	call	lib

	movsd	xmm0, [res_lib]
	lea	rax, msg_res_library
	mov	rdi, rax
	mov	eax, 1
	call	printf
	
	.ret:
		mov	eax, 0
		leave
		ret


scan_x:
	push    rbp
	mov	rbp, rsp
	sub 	rsp, 0x10

	lea	rax, msg_scan_x
	mov	rdi, rax
	xor	rax, rax
	call 	printf

	lea	rax, specifier_double
	mov	rdi, rax
	lea	rax, x
	mov 	rsi, rax
	xor	rax, rax
	call	scanf
	
	movsd	xmm0, [x]
	xor	rax, rax
    	leave
    	ret

check_x:
	push		rbp
	mov		rbp, rsp
	sub 		rsp, 0x10	

	movsd		xmm2, [x]
	
	mov		rcx, 0
	cvtsi2sd	xmm1, rcx

	mov 		rax, 1
	ucomisd		xmm2, xmm1
	jae 	.more_than_zero
	.less_than_zero:
		neg		rax
		cvtsi2sd	xmm1, rax
		mulsd		xmm2, xmm1	
	.more_than_zero:
		mov		rax, 1
		cvtsi2sd	xmm1, rax
		mov		rax, 0
		ucomisd		xmm2, xmm1
		jbe		.ret
		mov		rax, 1
		jmp		.ret
	.ret:
		leave
		ret

scan_n:
	push    rbp
	mov	rbp, rsp
	sub 	rsp, 0x10

	lea	rax, msg_scan_n
	mov	rdi, rax
	xor	rax, rax
	call 	printf

	lea	rax, specifier_int
	mov	rdi, rax
	lea	rax, n
	mov	rsi, rax
	xor	rax, rax
	call	scanf
	
	mov	rax, [n]
    	leave
    	ret

calc_accuracy:
	push		rbp
	mov		rbp, rsp
	sub		rsp, 0x10

	mov		rax, 1
	cvtsi2sd	xmm0, rax
	
	mov		rax, 10
	cvtsi2sd	xmm1, rax

	mov		rcx, 0
	jmp		.check
	.loop:
		divsd	xmm0, xmm1
		inc	rcx

		.check:
			cmp	rcx, [n]
			jl	.loop

	mov	rax, accuracy
	movsd	[rax + 0], xmm0
	movsd	xmm1, [accuracy]
	leave
	ret

	
	
lib:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 0x20
	movsd	xmm0, [x]
	mov	rax, [x]
	call    asin
	
	mov	rax, res_lib
	movsd	[rax + 0], xmm0
	;movq	xmm0, rax
	leave
	ret

my_asin:
	push 	rbp
	mov 	rbp, rsp
	sub	rsp, 0x10

	; xmm8  --  current series element
	; xmm9  --  x^2 value
	; xmm10  --  current series sum

	movsd		xmm8, [x]	
	movsd 		xmm9, xmm8
	mulsd		xmm9, xmm9
	mov		rax, 0
	cvtsi2sd	xmm10, rax
	mov		rcx, 0		; loop index

	lea		rax, filename
	;mov 		rdi, rax
	mov		rdi, filename
	xor		rax, rax
	mov		rsi, file_open_mode
	call 		fopen

	mov		rdi, rax
	mov		r13, rdi

	;mov		rdi, rax
	;mov		rsi, log_into_file
	;movsd		xmm0, xmm8
	;mov		eax, 1
	;call		fprintf
	.loop:
		; make log
		push		rcx
		mov		rdi, r13
		;mov		rsi, msg_test
		mov		rsi, log_into_file
		movsd		xmm0, xmm8
		mov		eax, 1
		call		fprintf
		pop		rcx

		addsd		xmm10, xmm8	; sum += element

		mulsd		xmm8, xmm9	; *x^2
		
		mov		rax, 4
		pxor		xmm3, xmm3
		cvtsi2sd	xmm3, rax
		divsd		xmm8, xmm3	; / 4

		pxor		xmm3, xmm3
		cvtsi2sd	xmm3, rcx	; xmm3 = n		

		movsd		xmm4, xmm3
		mov 		rax, 2
		cvtsi2sd	xmm5, rax
		mulsd		xmm4, xmm5	; xmm4 = 2n

		mov		rax, 1
		cvtsi2sd	xmm5, rax
		addsd		xmm3, xmm5	; xmm3 = n + 1

		divsd		xmm8, xmm3	; / (n+1)
		divsd		xmm8, xmm3	; / (n+1)

		addsd		xmm4, xmm5	; xmm4 = 2n+1
		mulsd		xmm8, xmm4	; *(2n+1)
		mulsd		xmm8, xmm4	; *(2n+1)
		
		addsd		xmm4, xmm5	; xmm4 = 2n+2
		mulsd		xmm8, xmm4	; *(2n+2)

		addsd		xmm4, xmm5	; xmm4 = 2n+3
		divsd		xmm8, xmm4	; /(2n+3)

		inc		rcx
		.check:
			mov		rax, 0
			cvtsi2sd	xmm3, rax
			movsd		xmm4, xmm8
			ucomisd		xmm8, xmm3
			jae 		.compare
			mov		rax, -1
			cvtsi2sd	xmm3, rax
			mulsd		xmm4, xmm3
			.compare:
				movsd	xmm3, [accuracy]
				ucomisd	xmm4, xmm3
				jae	.loop

	movsd	xmm8, xmm10
	mov	rax, res_cus
	movsd	[rax + 0], xmm8
	;mov	rdi, [rbp - 0x10]
	mov	rdi, r13
	mov	rax, 1
	call	fclose

	leave
	ret
