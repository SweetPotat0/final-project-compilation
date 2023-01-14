%define T_void 				0
%define T_nil 				1
%define T_char 				2
%define T_string 			3
%define T_symbol 			4
%define T_closure 			5
%define T_boolean 			8
%define T_boolean_false 		(T_boolean | 1)
%define T_boolean_true 			(T_boolean | 2)
%define T_number 			16
%define T_rational 			(T_number | 1)
%define T_real 				(T_number | 2)
%define T_collection 			32
%define T_pair 				(T_collection | 1)
%define T_vector 			(T_collection | 2)

%macro PRINT_TEST 2
        push rax
        push rbx
        push rcx
        push rdx
        push rdi
        push rsi
        mov rdi, qword [stderr]
        mov rsi, fmt_test
        mov rdx, %1
        mov rcx, %2
        mov rax, 0
        ENTER
        call fprintf
        LEAVE
        pop rsi
        pop rdi
        pop rdx
        pop rcx
        pop rbx
        pop rax
%endmacro

%define SOB_CHAR_VALUE(reg) 		byte [reg + 1]
%define SOB_PAIR_CAR(reg)		qword [reg + 1]
%define SOB_PAIR_CDR(reg)		qword [reg + 1 + 8]
%define SOB_STRING_LENGTH(reg)		qword [reg + 1]
%define SOB_VECTOR_LENGTH(reg)		qword [reg + 1]
%define SOB_CLOSURE_ENV(reg)		qword [reg + 1]
%define SOB_CLOSURE_CODE(reg)		qword [reg + 1 + 8]

%define OLD_RDP 			qword [rbp]
%define RET_ADDR 			qword [rbp + 8 * 1]
%define ENV 				qword [rbp + 8 * 2]
%define COUNT 				qword [rbp + 8 * 3]
%define PARAM(n) 			qword [rbp + 8 * (4 + n)]
%define AND_KILL_FRAME(n)		(8 * (2 + n))

%macro ENTER 0
	enter 0, 0
	and rsp, ~15
%endmacro

%macro LEAVE 0
	leave
%endmacro

%macro assert_type 2
        cmp byte [%1], %2
        jne L_error_incorrect_type
%endmacro

%macro assert_type_integer 1
        assert_rational(%1)
        cmp qword [%1 + 1 + 8], 1
        jne L_error_incorrect_type
%endmacro

%define assert_void(reg)		assert_type reg, T_void
%define assert_nil(reg)			assert_type reg, T_nil
%define assert_char(reg)		assert_type reg, T_char
%define assert_string(reg)		assert_type reg, T_string
%define assert_symbol(reg)		assert_type reg, T_symbol
%define assert_closure(reg)		assert_type reg, T_closure
%define assert_boolean(reg)		assert_type reg, T_boolean
%define assert_rational(reg)		assert_type reg, T_rational
%define assert_integer(reg)		assert_type_integer reg
%define assert_real(reg)		assert_type reg, T_real
%define assert_pair(reg)		assert_type reg, T_pair
%define assert_vector(reg)		assert_type reg, T_vector

%define sob_void			(L_constants + 0)
%define sob_nil				(L_constants + 1)
%define sob_boolean_false		(L_constants + 2)
%define sob_boolean_true		(L_constants + 3)
%define sob_char_nul			(L_constants + 4)

%define bytes(n)			(n)
%define kbytes(n) 			(bytes(n) << 10)
%define mbytes(n) 			(kbytes(n) << 10)
%define gbytes(n) 			(mbytes(n) << 10)

section .data
L_constants:
	db T_void
	db T_nil
	db T_boolean_false
	db T_boolean_true
	db T_char, 0x00	; #\x0
	db T_string	; "whatever"
	dq 8
	db 0x77, 0x68, 0x61, 0x74, 0x65, 0x76, 0x65, 0x72
	db T_symbol	; whatever
	dq L_constants + 6
	db T_rational	; 0
	dq 0, 1
	db T_string	; "+"
	dq 1
	db 0x2B
	db T_symbol	; +
	dq L_constants + 49
	db T_string	; "all arguments need ...
	dq 32
	db 0x61, 0x6C, 0x6C, 0x20, 0x61, 0x72, 0x67, 0x75
	db 0x6D, 0x65, 0x6E, 0x74, 0x73, 0x20, 0x6E, 0x65
	db 0x65, 0x64, 0x20, 0x74, 0x6F, 0x20, 0x62, 0x65
	db 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72, 0x73
	db T_string	; "-"
	dq 1
	db 0x2D
	db T_symbol	; -
	dq L_constants + 109
	db T_rational	; 8
	dq 8, 1
	db T_rational	; 5
	dq 5, 1
	db T_rational	; 7
	dq 7, 1
	db T_rational	; 4
	dq 4, 1
	db T_pair	; (4)
	dq L_constants + 179, L_constants + 1
	db T_pair	; (7 4)
	dq L_constants + 162, L_constants + 196
	db T_pair	; (5 7 4)
	dq L_constants + 145, L_constants + 213

section .bss
free_var_0:	; location of null?
	resq 1
free_var_1:	; location of pair?
	resq 1
free_var_2:	; location of void?
	resq 1
free_var_3:	; location of char?
	resq 1
free_var_4:	; location of string?
	resq 1
free_var_5:	; location of symbol?
	resq 1
free_var_6:	; location of vector?
	resq 1
free_var_7:	; location of procedure?
	resq 1
free_var_8:	; location of real?
	resq 1
free_var_9:	; location of rational?
	resq 1
free_var_10:	; location of boolean?
	resq 1
free_var_11:	; location of number?
	resq 1
free_var_12:	; location of collection?
	resq 1
free_var_13:	; location of cons
	resq 1
free_var_14:	; location of display-sexpr
	resq 1
free_var_15:	; location of write-char
	resq 1
free_var_16:	; location of car
	resq 1
free_var_17:	; location of cdr
	resq 1
free_var_18:	; location of string-length
	resq 1
free_var_19:	; location of vector-length
	resq 1
free_var_20:	; location of real->integer
	resq 1
free_var_21:	; location of exit
	resq 1
free_var_22:	; location of integer->real
	resq 1
free_var_23:	; location of rational->real
	resq 1
free_var_24:	; location of char->integer
	resq 1
free_var_25:	; location of integer->char
	resq 1
free_var_26:	; location of trng
	resq 1
free_var_27:	; location of zero?
	resq 1
free_var_28:	; location of integer?
	resq 1
free_var_29:	; location of __bin-apply
	resq 1
free_var_30:	; location of __bin-add-rr
	resq 1
free_var_31:	; location of __bin-sub-rr
	resq 1
free_var_32:	; location of __bin-mul-rr
	resq 1
free_var_33:	; location of __bin-div-rr
	resq 1
free_var_34:	; location of __bin-add-qq
	resq 1
free_var_35:	; location of __bin-sub-qq
	resq 1
free_var_36:	; location of __bin-mul-qq
	resq 1
free_var_37:	; location of __bin-div-qq
	resq 1
free_var_38:	; location of error
	resq 1
free_var_39:	; location of __bin-less-than-rr
	resq 1
free_var_40:	; location of __bin-less-than-qq
	resq 1
free_var_41:	; location of __bin-equal-rr
	resq 1
free_var_42:	; location of __bin-equal-qq
	resq 1
free_var_43:	; location of quotient
	resq 1
free_var_44:	; location of remainder
	resq 1
free_var_45:	; location of set-car!
	resq 1
free_var_46:	; location of set-cdr!
	resq 1
free_var_47:	; location of string-ref
	resq 1
free_var_48:	; location of vector-ref
	resq 1
free_var_49:	; location of vector-set!
	resq 1
free_var_50:	; location of string-set!
	resq 1
free_var_51:	; location of make-vector
	resq 1
free_var_52:	; location of make-string
	resq 1
free_var_53:	; location of numerator
	resq 1
free_var_54:	; location of denominator
	resq 1
free_var_55:	; location of eq?
	resq 1
free_var_56:	; location of apply
	resq 1
free_var_57:	; location of ormap
	resq 1
free_var_58:	; location of map
	resq 1
free_var_59:	; location of andmap
	resq 1
free_var_60:	; location of reverse
	resq 1
free_var_61:	; location of append
	resq 1
free_var_62:	; location of fold-left
	resq 1
free_var_63:	; location of fold-right
	resq 1
free_var_64:	; location of +
	resq 1
free_var_65:	; location of -
	resq 1
free_var_66:	; location of list
	resq 1

extern printf, fprintf, stdout, stderr, fwrite, exit, putchar
global main
section .text
main:
        enter 0, 0
        
	; building closure for null?
	mov rdi, free_var_0
	mov rsi, L_code_ptr_is_null
	call bind_primitive

	; building closure for pair?
	mov rdi, free_var_1
	mov rsi, L_code_ptr_is_pair
	call bind_primitive

	; building closure for void?
	mov rdi, free_var_2
	mov rsi, L_code_ptr_is_void
	call bind_primitive

	; building closure for char?
	mov rdi, free_var_3
	mov rsi, L_code_ptr_is_char
	call bind_primitive

	; building closure for string?
	mov rdi, free_var_4
	mov rsi, L_code_ptr_is_string
	call bind_primitive

	; building closure for symbol?
	mov rdi, free_var_5
	mov rsi, L_code_ptr_is_symbol
	call bind_primitive

	; building closure for vector?
	mov rdi, free_var_6
	mov rsi, L_code_ptr_is_vector
	call bind_primitive

	; building closure for procedure?
	mov rdi, free_var_7
	mov rsi, L_code_ptr_is_closure
	call bind_primitive

	; building closure for real?
	mov rdi, free_var_8
	mov rsi, L_code_ptr_is_real
	call bind_primitive

	; building closure for rational?
	mov rdi, free_var_9
	mov rsi, L_code_ptr_is_rational
	call bind_primitive

	; building closure for boolean?
	mov rdi, free_var_10
	mov rsi, L_code_ptr_is_boolean
	call bind_primitive

	; building closure for number?
	mov rdi, free_var_11
	mov rsi, L_code_ptr_is_number
	call bind_primitive

	; building closure for collection?
	mov rdi, free_var_12
	mov rsi, L_code_ptr_is_collection
	call bind_primitive

	; building closure for cons
	mov rdi, free_var_13
	mov rsi, L_code_ptr_cons
	call bind_primitive

	; building closure for display-sexpr
	mov rdi, free_var_14
	mov rsi, L_code_ptr_display_sexpr
	call bind_primitive

	; building closure for write-char
	mov rdi, free_var_15
	mov rsi, L_code_ptr_write_char
	call bind_primitive

	; building closure for car
	mov rdi, free_var_16
	mov rsi, L_code_ptr_car
	call bind_primitive

	; building closure for cdr
	mov rdi, free_var_17
	mov rsi, L_code_ptr_cdr
	call bind_primitive

	; building closure for string-length
	mov rdi, free_var_18
	mov rsi, L_code_ptr_string_length
	call bind_primitive

	; building closure for vector-length
	mov rdi, free_var_19
	mov rsi, L_code_ptr_vector_length
	call bind_primitive

	; building closure for real->integer
	mov rdi, free_var_20
	mov rsi, L_code_ptr_real_to_integer
	call bind_primitive

	; building closure for exit
	mov rdi, free_var_21
	mov rsi, L_code_ptr_exit
	call bind_primitive

	; building closure for integer->real
	mov rdi, free_var_22
	mov rsi, L_code_ptr_integer_to_real
	call bind_primitive

	; building closure for rational->real
	mov rdi, free_var_23
	mov rsi, L_code_ptr_rational_to_real
	call bind_primitive

	; building closure for char->integer
	mov rdi, free_var_24
	mov rsi, L_code_ptr_char_to_integer
	call bind_primitive

	; building closure for integer->char
	mov rdi, free_var_25
	mov rsi, L_code_ptr_integer_to_char
	call bind_primitive

	; building closure for trng
	mov rdi, free_var_26
	mov rsi, L_code_ptr_trng
	call bind_primitive

	; building closure for zero?
	mov rdi, free_var_27
	mov rsi, L_code_ptr_is_zero
	call bind_primitive

	; building closure for integer?
	mov rdi, free_var_28
	mov rsi, L_code_ptr_is_integer
	call bind_primitive

	; building closure for __bin-apply
	mov rdi, free_var_29
	mov rsi, L_code_ptr_bin_apply
	call bind_primitive

	; building closure for __bin-add-rr
	mov rdi, free_var_30
	mov rsi, L_code_ptr_raw_bin_add_rr
	call bind_primitive

	; building closure for __bin-sub-rr
	mov rdi, free_var_31
	mov rsi, L_code_ptr_raw_bin_sub_rr
	call bind_primitive

	; building closure for __bin-mul-rr
	mov rdi, free_var_32
	mov rsi, L_code_ptr_raw_bin_mul_rr
	call bind_primitive

	; building closure for __bin-div-rr
	mov rdi, free_var_33
	mov rsi, L_code_ptr_raw_bin_div_rr
	call bind_primitive

	; building closure for __bin-add-qq
	mov rdi, free_var_34
	mov rsi, L_code_ptr_raw_bin_add_qq
	call bind_primitive

	; building closure for __bin-sub-qq
	mov rdi, free_var_35
	mov rsi, L_code_ptr_raw_bin_sub_qq
	call bind_primitive

	; building closure for __bin-mul-qq
	mov rdi, free_var_36
	mov rsi, L_code_ptr_raw_bin_mul_qq
	call bind_primitive

	; building closure for __bin-div-qq
	mov rdi, free_var_37
	mov rsi, L_code_ptr_raw_bin_div_qq
	call bind_primitive

	; building closure for error
	mov rdi, free_var_38
	mov rsi, L_code_ptr_error
	call bind_primitive

	; building closure for __bin-less-than-rr
	mov rdi, free_var_39
	mov rsi, L_code_ptr_raw_less_than_rr
	call bind_primitive

	; building closure for __bin-less-than-qq
	mov rdi, free_var_40
	mov rsi, L_code_ptr_raw_less_than_qq
	call bind_primitive

	; building closure for __bin-equal-rr
	mov rdi, free_var_41
	mov rsi, L_code_ptr_raw_equal_rr
	call bind_primitive

	; building closure for __bin-equal-qq
	mov rdi, free_var_42
	mov rsi, L_code_ptr_raw_equal_qq
	call bind_primitive

	; building closure for quotient
	mov rdi, free_var_43
	mov rsi, L_code_ptr_quotient
	call bind_primitive

	; building closure for remainder
	mov rdi, free_var_44
	mov rsi, L_code_ptr_remainder
	call bind_primitive

	; building closure for set-car!
	mov rdi, free_var_45
	mov rsi, L_code_ptr_set_car
	call bind_primitive

	; building closure for set-cdr!
	mov rdi, free_var_46
	mov rsi, L_code_ptr_set_cdr
	call bind_primitive

	; building closure for string-ref
	mov rdi, free_var_47
	mov rsi, L_code_ptr_string_ref
	call bind_primitive

	; building closure for vector-ref
	mov rdi, free_var_48
	mov rsi, L_code_ptr_vector_ref
	call bind_primitive

	; building closure for vector-set!
	mov rdi, free_var_49
	mov rsi, L_code_ptr_vector_set
	call bind_primitive

	; building closure for string-set!
	mov rdi, free_var_50
	mov rsi, L_code_ptr_string_set
	call bind_primitive

	; building closure for make-vector
	mov rdi, free_var_51
	mov rsi, L_code_ptr_make_vector
	call bind_primitive

	; building closure for make-string
	mov rdi, free_var_52
	mov rsi, L_code_ptr_make_string
	call bind_primitive

	; building closure for numerator
	mov rdi, free_var_53
	mov rsi, L_code_ptr_numerator
	call bind_primitive

	; building closure for denominator
	mov rdi, free_var_54
	mov rsi, L_code_ptr_denominator
	call bind_primitive

	; building closure for eq?
	mov rdi, free_var_55
	mov rsi, L_code_ptr_eq
	call bind_primitive

	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a25:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a25
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a25
.L_lambda_simple_env_end_0a25:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a25:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a25
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a25
.L_lambda_simple_params_end_0a25:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a25
	jmp .L_lambda_simple_end_0a25
.L_lambda_simple_code_0a25:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a25
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a25:
	enter 0, 0
	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a26:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a26
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a26
.L_lambda_simple_env_end_0a26:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a26:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a26
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a26
.L_lambda_simple_params_end_0a26:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a26
	jmp .L_lambda_simple_end_0a26
.L_lambda_simple_code_0a26:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a26
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a26:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_090c
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0f9c:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0f9c
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0f9c
.L_tc_recycle_frame_done_0f9c:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_090c
	.L_if_else_090c:
	mov rax, PARAM(0)
	.L_if_end_090c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a26:	; new closure is in rax
	push rax
	mov rax, PARAM(0)
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03c6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_03c6
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03c6
.L_lambda_opt_env_end_03c6:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03c6:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_03c6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03c6
.L_lambda_opt_params_end_03c6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03c6
	jmp .L_lambda_opt_end_03c6
.L_lambda_opt_code_03c6:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03c6
.L_lambda_opt_arity_check_exact_03c6:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03c6:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_03c6
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03c6
.L_lambda_opt_stack_enlarge_loop_exit_03c6:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_03c6
.L_lambda_opt_arity_check_more_03c6:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03c6:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03c6
	lea rcx, [rsi + (3 + 1)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03c6
.L_lambda_opt_list_create_loop_exit_03c6:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03c6:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_03c6
	mov rdi, 3
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03c6
.L_lambda_opt_stack_shrink_loop_exit_03c6:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_03c6:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_29]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0f9d:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0f9d
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0f9d
.L_tc_recycle_frame_done_0f9d:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_03c6:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a25:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_56], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03c7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_03c7
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03c7
.L_lambda_opt_env_end_03c7:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03c7:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_03c7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03c7
.L_lambda_opt_params_end_03c7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03c7
	jmp .L_lambda_opt_end_03c7
.L_lambda_opt_code_03c7:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03c7
.L_lambda_opt_arity_check_exact_03c7:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03c7:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_03c7
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03c7
.L_lambda_opt_stack_enlarge_loop_exit_03c7:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_03c7
.L_lambda_opt_arity_check_more_03c7:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03c7:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03c7
	lea rcx, [rsi + (3 + 1)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03c7
.L_lambda_opt_list_create_loop_exit_03c7:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03c7:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_03c7
	mov rdi, 3
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03c7
.L_lambda_opt_stack_shrink_loop_exit_03c7:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_03c7:
	enter 0, 0
	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a27:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a27
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a27
.L_lambda_simple_env_end_0a27:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a27:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0a27
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a27
.L_lambda_simple_params_end_0a27:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a27
	jmp .L_lambda_simple_end_0a27
.L_lambda_simple_code_0a27:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a27
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a27:
	enter 0, 0
	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a28:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0a28
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a28
.L_lambda_simple_env_end_0a28:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a28:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a28
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a28
.L_lambda_simple_params_end_0a28:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a28
	jmp .L_lambda_simple_end_0a28
.L_lambda_simple_code_0a28:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a28
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a28:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_090d
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	push rax
	push 2
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	jne .L_or_end_00ca
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0f9f:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0f9f
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0f9f
.L_tc_recycle_frame_done_0f9f:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
.L_or_end_00ca:
	jmp .L_if_end_090d
	.L_if_else_090d:
	lea rax, [2 + L_constants]
	.L_if_end_090d:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a28:	; new closure is in rax
	push rax
	mov rax, PARAM(0)
	pop qword [rax]
	mov rax, sob_void

	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	push 1
	mov rax, PARAM(0)
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa0:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0fa0
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa0
.L_tc_recycle_frame_done_0fa0:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a27:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0f9e:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0f9e
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0f9e
.L_tc_recycle_frame_done_0f9e:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_03c7:	; new closure is in rax
	mov qword [free_var_57], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03c8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_03c8
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03c8
.L_lambda_opt_env_end_03c8:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03c8:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_03c8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03c8
.L_lambda_opt_params_end_03c8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03c8
	jmp .L_lambda_opt_end_03c8
.L_lambda_opt_code_03c8:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03c8
.L_lambda_opt_arity_check_exact_03c8:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03c8:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_03c8
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03c8
.L_lambda_opt_stack_enlarge_loop_exit_03c8:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_03c8
.L_lambda_opt_arity_check_more_03c8:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03c8:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03c8
	lea rcx, [rsi + (3 + 1)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03c8
.L_lambda_opt_list_create_loop_exit_03c8:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03c8:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_03c8
	mov rdi, 3
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03c8
.L_lambda_opt_stack_shrink_loop_exit_03c8:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_03c8:
	enter 0, 0
	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a29:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a29
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a29
.L_lambda_simple_env_end_0a29:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a29:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0a29
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a29
.L_lambda_simple_params_end_0a29:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a29
	jmp .L_lambda_simple_end_0a29
.L_lambda_simple_code_0a29:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a29
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a29:
	enter 0, 0
	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a2a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0a2a
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a2a
.L_lambda_simple_env_end_0a2a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a2a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a2a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a2a
.L_lambda_simple_params_end_0a2a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a2a
	jmp .L_lambda_simple_end_0a2a
.L_lambda_simple_code_0a2a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a2a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a2a:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	jne .L_or_end_00cb
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	push rax
	push 2
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_090e
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa2:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0fa2
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa2
.L_tc_recycle_frame_done_0fa2:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_090e
	.L_if_else_090e:
	lea rax, [2 + L_constants]
	.L_if_end_090e:
.L_or_end_00cb:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a2a:	; new closure is in rax
	push rax
	mov rax, PARAM(0)
	pop qword [rax]
	mov rax, sob_void

	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	push 1
	mov rax, PARAM(0)
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa3:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0fa3
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa3
.L_tc_recycle_frame_done_0fa3:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a29:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa1:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0fa1
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa1
.L_tc_recycle_frame_done_0fa1:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_03c8:	; new closure is in rax
	mov qword [free_var_59], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [23 + L_constants]
	push rax
	lea rax, [23 + L_constants]
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a2b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a2b
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a2b
.L_lambda_simple_env_end_0a2b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a2b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a2b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a2b
.L_lambda_simple_params_end_0a2b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a2b
	jmp .L_lambda_simple_end_0a2b
.L_lambda_simple_code_0a2b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a2b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a2b:
	enter 0, 0
	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 1)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a2c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a2c
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a2c
.L_lambda_simple_env_end_0a2c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a2c:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0a2c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a2c
.L_lambda_simple_params_end_0a2c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a2c
	jmp .L_lambda_simple_end_0a2c
.L_lambda_simple_code_0a2c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a2c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a2c:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_090f
	lea rax, [1 + L_constants]
	jmp .L_if_end_090f
	.L_if_else_090f:
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa4:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fa4
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa4
.L_tc_recycle_frame_done_0fa4:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_090f:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a2c:	; new closure is in rax
	push rax
	mov rax, PARAM(0)
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a2d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a2d
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a2d
.L_lambda_simple_env_end_0a2d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a2d:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0a2d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a2d
.L_lambda_simple_params_end_0a2d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a2d
	jmp .L_lambda_simple_end_0a2d
.L_lambda_simple_code_0a2d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a2d
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a2d:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0910
	lea rax, [1 + L_constants]
	jmp .L_if_end_0910
	.L_if_else_0910:
	mov rax, PARAM(1)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa5:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fa5
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa5
.L_tc_recycle_frame_done_0fa5:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0910:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a2d:	; new closure is in rax
	push rax
	mov rax, PARAM(1)
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03c9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_03c9
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03c9
.L_lambda_opt_env_end_03c9:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03c9:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_03c9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03c9
.L_lambda_opt_params_end_03c9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03c9
	jmp .L_lambda_opt_end_03c9
.L_lambda_opt_code_03c9:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03c9
.L_lambda_opt_arity_check_exact_03c9:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03c9:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_03c9
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03c9
.L_lambda_opt_stack_enlarge_loop_exit_03c9:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_03c9
.L_lambda_opt_arity_check_more_03c9:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03c9:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03c9
	lea rcx, [rsi + (3 + 1)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03c9
.L_lambda_opt_list_create_loop_exit_03c9:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03c9:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_03c9
	mov rdi, 3
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03c9
.L_lambda_opt_stack_shrink_loop_exit_03c9:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_03c9:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0911
	lea rax, [1 + L_constants]
	jmp .L_if_end_0911
	.L_if_else_0911:
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa6:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fa6
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa6
.L_tc_recycle_frame_done_0fa6:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0911:
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_03c9:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a2b:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_58], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a2e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a2e
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a2e
.L_lambda_simple_env_end_0a2e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a2e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a2e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a2e
.L_lambda_simple_params_end_0a2e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a2e
	jmp .L_lambda_simple_end_0a2e
.L_lambda_simple_code_0a2e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a2e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a2e:
	enter 0, 0
	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a2f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a2f
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a2f
.L_lambda_simple_env_end_0a2f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a2f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a2f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a2f
.L_lambda_simple_params_end_0a2f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a2f
	jmp .L_lambda_simple_end_0a2f
.L_lambda_simple_code_0a2f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a2f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a2f:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0912
	mov rax, PARAM(1)
	jmp .L_if_end_0912
	.L_if_else_0912:
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa7:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fa7
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa7
.L_tc_recycle_frame_done_0fa7:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0912:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a2f:	; new closure is in rax
	push rax
	mov rax, PARAM(0)
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a30:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a30
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a30
.L_lambda_simple_env_end_0a30:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a30:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a30
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a30
.L_lambda_simple_params_end_0a30:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a30
	jmp .L_lambda_simple_end_0a30
.L_lambda_simple_code_0a30:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a30
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a30:
	enter 0, 0
	lea rax, [1 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa8:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fa8
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa8
.L_tc_recycle_frame_done_0fa8:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a30:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a2e:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_60], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [23 + L_constants]
	push rax
	lea rax, [23 + L_constants]
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a31:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a31
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a31
.L_lambda_simple_env_end_0a31:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a31:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a31
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a31
.L_lambda_simple_params_end_0a31:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a31
	jmp .L_lambda_simple_end_0a31
.L_lambda_simple_code_0a31:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a31
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a31:
	enter 0, 0
	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 1)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a32:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a32
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a32
.L_lambda_simple_env_end_0a32:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a32:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0a32
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a32
.L_lambda_simple_params_end_0a32:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a32
	jmp .L_lambda_simple_end_0a32
.L_lambda_simple_code_0a32:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a32
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a32:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0913
	mov rax, PARAM(0)
	jmp .L_if_end_0913
	.L_if_else_0913:
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fa9:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fa9
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fa9
.L_tc_recycle_frame_done_0fa9:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0913:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a32:	; new closure is in rax
	push rax
	mov rax, PARAM(0)
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a33:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a33
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a33
.L_lambda_simple_env_end_0a33:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a33:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0a33
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a33
.L_lambda_simple_params_end_0a33:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a33
	jmp .L_lambda_simple_end_0a33
.L_lambda_simple_code_0a33:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a33
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a33:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0914
	mov rax, PARAM(1)
	jmp .L_if_end_0914
	.L_if_else_0914:
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0faa:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0faa
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0faa
.L_tc_recycle_frame_done_0faa:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0914:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a33:	; new closure is in rax
	push rax
	mov rax, PARAM(1)
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03ca:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_03ca
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03ca
.L_lambda_opt_env_end_03ca:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03ca:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_03ca
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03ca
.L_lambda_opt_params_end_03ca:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03ca
	jmp .L_lambda_opt_end_03ca
.L_lambda_opt_code_03ca:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03ca
.L_lambda_opt_arity_check_exact_03ca:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03ca:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_03ca
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03ca
.L_lambda_opt_stack_enlarge_loop_exit_03ca:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_03ca
.L_lambda_opt_arity_check_more_03ca:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03ca:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03ca
	lea rcx, [rsi + (3 + 0)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03ca
.L_lambda_opt_list_create_loop_exit_03ca:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03ca:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_03ca
	mov rdi, 2
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03ca
.L_lambda_opt_stack_shrink_loop_exit_03ca:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_03ca:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0915
	lea rax, [1 + L_constants]
	jmp .L_if_end_0915
	.L_if_else_0915:
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fab:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fab
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fab
.L_tc_recycle_frame_done_0fab:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0915:
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_03ca:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a31:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_61], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a34:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a34
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a34
.L_lambda_simple_env_end_0a34:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a34:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a34
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a34
.L_lambda_simple_params_end_0a34:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a34
	jmp .L_lambda_simple_end_0a34
.L_lambda_simple_code_0a34:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a34
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a34:
	enter 0, 0
	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a35:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a35
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a35
.L_lambda_simple_env_end_0a35:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a35:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a35
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a35
.L_lambda_simple_params_end_0a35:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a35
	jmp .L_lambda_simple_end_0a35
.L_lambda_simple_code_0a35:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0a35
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a35:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_57]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0916
	mov rax, PARAM(1)
	jmp .L_if_end_0916
	.L_if_else_0916:
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 3
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 3
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fac:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_0fac
	mov rcx, 5
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fac
.L_tc_recycle_frame_done_0fac:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0916:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_0a35:	; new closure is in rax
	push rax
	mov rax, PARAM(0)
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03cb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_03cb
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03cb
.L_lambda_opt_env_end_03cb:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03cb:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_03cb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03cb
.L_lambda_opt_params_end_03cb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03cb
	jmp .L_lambda_opt_end_03cb
.L_lambda_opt_code_03cb:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 2 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03cb
.L_lambda_opt_arity_check_exact_03cb:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03cb:	 ; stack loop enlarge start
	cmp rsi, 5
	je .L_lambda_opt_stack_enlarge_loop_exit_03cb
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03cb
.L_lambda_opt_stack_enlarge_loop_exit_03cb:	 ; end of stack enlarge loop
	mov qword [rsp + 5*8], sob_nil
	mov qword [rsp + 2*8], 3
	jmp .L_lambda_opt_stack_adjusted_03cb
.L_lambda_opt_arity_check_more_03cb:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03cb:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03cb
	lea rcx, [rsi + (3 + 2)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03cb
.L_lambda_opt_list_create_loop_exit_03cb:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03cb:	; start of stack shrink loop
	cmp rsi, 5
	je .L_lambda_opt_stack_shrink_loop_exit_03cb
	mov rdi, 4
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03cb
.L_lambda_opt_stack_shrink_loop_exit_03cb:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 3
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 3
.L_lambda_opt_stack_adjusted_03cb:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 3
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fad:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_0fad
	mov rcx, 5
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fad
.L_tc_recycle_frame_done_0fad:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(3)
.L_lambda_opt_end_03cb:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a34:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_62], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a36:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a36
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a36
.L_lambda_simple_env_end_0a36:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a36:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a36
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a36
.L_lambda_simple_params_end_0a36:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a36
	jmp .L_lambda_simple_end_0a36
.L_lambda_simple_code_0a36:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a36
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a36:
	enter 0, 0
	mov qword rdi, 8
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a37:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a37
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a37
.L_lambda_simple_env_end_0a37:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a37:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a37
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a37
.L_lambda_simple_params_end_0a37:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a37
	jmp .L_lambda_simple_end_0a37
.L_lambda_simple_code_0a37:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0a37
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a37:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_57]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0917
	mov rax, PARAM(1)
	jmp .L_if_end_0917
	.L_if_else_0917:
	lea rax, [1 + L_constants]
	push rax
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 3
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_61]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fae:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fae
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fae
.L_tc_recycle_frame_done_0fae:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0917:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_0a37:	; new closure is in rax
	push rax
	mov rax, PARAM(0)
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03cc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_03cc
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03cc
.L_lambda_opt_env_end_03cc:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03cc:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_03cc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03cc
.L_lambda_opt_params_end_03cc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03cc
	jmp .L_lambda_opt_end_03cc
.L_lambda_opt_code_03cc:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 2 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03cc
.L_lambda_opt_arity_check_exact_03cc:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03cc:	 ; stack loop enlarge start
	cmp rsi, 5
	je .L_lambda_opt_stack_enlarge_loop_exit_03cc
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03cc
.L_lambda_opt_stack_enlarge_loop_exit_03cc:	 ; end of stack enlarge loop
	mov qword [rsp + 5*8], sob_nil
	mov qword [rsp + 2*8], 3
	jmp .L_lambda_opt_stack_adjusted_03cc
.L_lambda_opt_arity_check_more_03cc:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03cc:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03cc
	lea rcx, [rsi + (3 + 2)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03cc
.L_lambda_opt_list_create_loop_exit_03cc:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03cc:	; start of stack shrink loop
	cmp rsi, 5
	je .L_lambda_opt_stack_shrink_loop_exit_03cc
	mov rdi, 4
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03cc
.L_lambda_opt_stack_shrink_loop_exit_03cc:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 3
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 3
.L_lambda_opt_stack_adjusted_03cc:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 3
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0faf:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_0faf
	mov rcx, 5
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0faf
.L_tc_recycle_frame_done_0faf:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(3)
.L_lambda_opt_end_03cc:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a36:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_63], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a38:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a38
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a38
.L_lambda_simple_env_end_0a38:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a38:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a38
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a38
.L_lambda_simple_params_end_0a38:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a38
	jmp .L_lambda_simple_end_0a38
.L_lambda_simple_code_0a38:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0a38
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a38:
	enter 0, 0
	lea rax, [68 + L_constants]
	push rax
	lea rax, [59 + L_constants]
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb0:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fb0
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb0
.L_tc_recycle_frame_done_0fb0:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_0a38:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a39:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a39
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a39
.L_lambda_simple_env_end_0a39:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a39:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a39
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a39
.L_lambda_simple_params_end_0a39:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a39
	jmp .L_lambda_simple_end_0a39
.L_lambda_simple_code_0a39:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a39
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a39:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a3a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a3a
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a3a
.L_lambda_simple_env_end_0a3a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a3a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a3a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a3a
.L_lambda_simple_params_end_0a3a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a3a
	jmp .L_lambda_simple_end_0a3a
.L_lambda_simple_code_0a3a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a3a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a3a:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0918
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0919
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_34]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb2:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fb2
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb2
.L_tc_recycle_frame_done_0fb2:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_0919
	.L_if_else_0919:
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_091a
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb3:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fb3
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb3
.L_tc_recycle_frame_done_0fb3:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_091a
	.L_if_else_091a:
	push 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb4:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_0fb4
	mov rcx, 2
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb4
.L_tc_recycle_frame_done_0fb4:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_091a:
	.L_if_end_0919:
	jmp .L_if_end_0918
	.L_if_else_0918:
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_091b
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_091c
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb5:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fb5
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb5
.L_tc_recycle_frame_done_0fb5:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_091c
	.L_if_else_091c:
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_091d
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb6:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fb6
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb6
.L_tc_recycle_frame_done_0fb6:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_091d
	.L_if_else_091d:
	push 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb7:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_0fb7
	mov rcx, 2
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb7
.L_tc_recycle_frame_done_0fb7:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_091d:
	.L_if_end_091c:
	jmp .L_if_end_091b
	.L_if_else_091b:
	push 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb8:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_0fb8
	mov rcx, 2
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb8
.L_tc_recycle_frame_done_0fb8:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_091b:
	.L_if_end_0918:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a3a:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a3b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a3b
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a3b
.L_lambda_simple_env_end_0a3b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a3b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a3b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a3b
.L_lambda_simple_params_end_0a3b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a3b
	jmp .L_lambda_simple_end_0a3b
.L_lambda_simple_code_0a3b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a3b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a3b:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03cd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_03cd
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03cd
.L_lambda_opt_env_end_03cd:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03cd:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_03cd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03cd
.L_lambda_opt_params_end_03cd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03cd
	jmp .L_lambda_opt_end_03cd
.L_lambda_opt_code_03cd:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03cd
.L_lambda_opt_arity_check_exact_03cd:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03cd:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_03cd
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03cd
.L_lambda_opt_stack_enlarge_loop_exit_03cd:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_03cd
.L_lambda_opt_arity_check_more_03cd:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03cd:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03cd
	lea rcx, [rsi + (3 + 0)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03cd
.L_lambda_opt_list_create_loop_exit_03cd:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03cd:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_03cd
	mov rdi, 2
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03cd
.L_lambda_opt_stack_shrink_loop_exit_03cd:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_03cd:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	lea rax, [32 + L_constants]
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 3
	mov rax, qword [free_var_62]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb9:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_0fb9
	mov rcx, 5
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb9
.L_tc_recycle_frame_done_0fb9:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_03cd:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a3b:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fb1:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0fb1
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fb1
.L_tc_recycle_frame_done_0fb1:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a39:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_64], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a3c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a3c
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a3c
.L_lambda_simple_env_end_0a3c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a3c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a3c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a3c
.L_lambda_simple_params_end_0a3c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a3c
	jmp .L_lambda_simple_end_0a3c
.L_lambda_simple_code_0a3c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0a3c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a3c:
	enter 0, 0
	lea rax, [68 + L_constants]
	push rax
	lea rax, [119 + L_constants]
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fba:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fba
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fba
.L_tc_recycle_frame_done_0fba:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_0a3c:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a3d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0a3d
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a3d
.L_lambda_simple_env_end_0a3d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a3d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0a3d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a3d
.L_lambda_simple_params_end_0a3d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a3d
	jmp .L_lambda_simple_end_0a3d
.L_lambda_simple_code_0a3d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a3d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a3d:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a3e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a3e
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a3e
.L_lambda_simple_env_end_0a3e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a3e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a3e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a3e
.L_lambda_simple_params_end_0a3e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a3e
	jmp .L_lambda_simple_end_0a3e
.L_lambda_simple_code_0a3e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0a3e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a3e:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_091e
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_091f
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_35]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fbc:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fbc
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fbc
.L_tc_recycle_frame_done_0fbc:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_091f
	.L_if_else_091f:
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0920
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fbd:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fbd
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fbd
.L_tc_recycle_frame_done_0fbd:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_0920
	.L_if_else_0920:
	push 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fbe:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_0fbe
	mov rcx, 2
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fbe
.L_tc_recycle_frame_done_0fbe:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0920:
	.L_if_end_091f:
	jmp .L_if_end_091e
	.L_if_else_091e:
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0921
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0922
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fbf:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fbf
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fbf
.L_tc_recycle_frame_done_0fbf:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_0922
	.L_if_else_0922:
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0923
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fc0:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fc0
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fc0
.L_tc_recycle_frame_done_0fc0:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_0923
	.L_if_else_0923:
	push 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fc1:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_0fc1
	mov rcx, 2
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fc1
.L_tc_recycle_frame_done_0fc1:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0923:
	.L_if_end_0922:
	jmp .L_if_end_0921
	.L_if_else_0921:
	push 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fc2:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_0fc2
	mov rcx, 2
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fc2
.L_tc_recycle_frame_done_0fc2:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0921:
	.L_if_end_091e:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0a3e:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a3f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0a3f
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a3f
.L_lambda_simple_env_end_0a3f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a3f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0a3f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a3f
.L_lambda_simple_params_end_0a3f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a3f
	jmp .L_lambda_simple_end_0a3f
.L_lambda_simple_code_0a3f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a3f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a3f:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_03ce:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_03ce
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_03ce
.L_lambda_opt_env_end_03ce:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_03ce:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_03ce
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_03ce
.L_lambda_opt_params_end_03ce:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_03ce
	jmp .L_lambda_opt_end_03ce
.L_lambda_opt_code_03ce:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_03ce
.L_lambda_opt_arity_check_exact_03ce:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_03ce:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_03ce
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_03ce
.L_lambda_opt_stack_enlarge_loop_exit_03ce:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_03ce
.L_lambda_opt_arity_check_more_03ce:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_03ce:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_03ce
	lea rcx, [rsi + (3 + 1)]
	shl rcx, 3
	add rcx, rsp
	mov rcx, [rcx]
	push rsi ; save params
	push rbx

	push rax ; cdr
	push rcx ; car
	push qword 2 ; push num of args
	push qword 1 ; push garbage as env
	call L_code_ptr_cons

	pop rbx ; restore params
	pop rsi
	dec rsi
	jmp .L_lambda_opt_list_create_loop_03ce
.L_lambda_opt_list_create_loop_exit_03ce:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_03ce:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_03ce
	mov rdi, 3
	sub rdi, rsi; the index of the current stack member to move
	mov rcx, rbx
	sub rcx, rsi
	dec rcx ; the index of the target stack place to put the member
	mov rdx, rdi
	shl rdx, 3
	add rdx, rsp
	shl rcx, 3
	add rcx, rsp
	mov rdx, [rdx]
	mov [rcx], rdx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_03ce
.L_lambda_opt_stack_shrink_loop_exit_03ce:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_03ce:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_0924
	mov rax, PARAM(0)
	push rax
	lea rax, [32 + L_constants]
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fc3:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fc3
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fc3
.L_tc_recycle_frame_done_0fc3:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_0924
	.L_if_else_0924:
	mov rax, PARAM(1)
	push rax
	lea rax, [32 + L_constants]
	push rax
	mov rax, qword [free_var_64]
	push rax
	push 3
	mov rax, qword [free_var_62]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0a40:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0a40
	mov rcx, qword [rdi + 8 * rsi] ; Problem is here!!
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0a40
.L_lambda_simple_env_end_0a40:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0a40:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0a40
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0a40
.L_lambda_simple_params_end_0a40:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0a40
	jmp .L_lambda_simple_end_0a40
.L_lambda_simple_code_0a40:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0a40
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0a40:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fc5:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_0fc5
	mov rcx, 4
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fc5
.L_tc_recycle_frame_done_0fc5:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a40:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fc4:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0fc4
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fc4
.L_tc_recycle_frame_done_0fc4:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_0924:
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_03ce:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a3f:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_0fbb:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_0fbb
	mov rcx, 3
	sub rcx, rsi
	shl rcx, 3
	add rcx, rsp ; rcx is the address to move
	mov rbx, rsi
	shl rbx, 3
	neg rbx
	add rbx, rdi ;rbx is the address to move to
	mov rcx, [rcx]
	mov [rbx], rcx
	inc rsi
	jmp .L_tc_recycle_frame_loop_0fbb
.L_tc_recycle_frame_done_0fbb:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0a3d:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_65], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [230 + L_constants]
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, qword [free_var_66]
	push rax
	push 3
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

	mov rdi, rax
	call print_sexpr_if_not_void

        mov rdi, fmt_memory_usage
        mov rsi, qword [top_of_memory]
        sub rsi, memory
        mov rax, 0
	ENTER
        call printf
	LEAVE
	leave
	ret

L_error_non_closure:
        mov rdi, qword [stderr]
        mov rsi, fmt_non_closure
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -2
        call exit

L_error_improper_list:
	mov rdi, qword [stderr]
	mov rsi, fmt_error_improper_list
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -7
	call exit

L_error_incorrect_arity_simple:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_simple
        jmp L_error_incorrect_arity_common
L_error_incorrect_arity_opt:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_opt
L_error_incorrect_arity_common:
        pop rdx
        pop rcx
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -6
        call exit

section .data
fmt_incorrect_arity_simple:
        db `!!! Expected %ld arguments, but given %ld\n\0`
fmt_incorrect_arity_opt:
        db `!!! Expected at least %ld arguments, but given %ld\n\0`
fmt_memory_usage:
        db `\n\n!!! Used %ld bytes of dynamically-allocated memory\n\n\0`
fmt_non_closure:
        db `!!! Attempting to apply a non-closure!\n\0`
fmt_error_improper_list:
	db `!!! The argument is not a proper list!\n\0`
fmt_test:
        db `test here %d at %d\n\0`

section .bss
memory:
	resb gbytes(1)

section .data
top_of_memory:
        dq memory

section .text
malloc:
        mov rax, qword [top_of_memory]
        add qword [top_of_memory], rdi
        ret
        
print_sexpr_if_not_void:
	cmp rdi, sob_void
	jne print_sexpr
	ret

section .data
fmt_void:
	db `#<void>\0`
fmt_nil:
	db `()\0`
fmt_boolean_false:
	db `#f\0`
fmt_boolean_true:
	db `#t\0`
fmt_char_backslash:
	db `#\\\\\0`
fmt_char_dquote:
	db `#\\"\0`
fmt_char_simple:
	db `#\\%c\0`
fmt_char_null:
	db `#\\nul\0`
fmt_char_bell:
	db `#\\bell\0`
fmt_char_backspace:
	db `#\\backspace\0`
fmt_char_tab:
	db `#\\tab\0`
fmt_char_newline:
	db `#\\newline\0`
fmt_char_formfeed:
	db `#\\page\0`
fmt_char_return:
	db `#\\return\0`
fmt_char_escape:
	db `#\\esc\0`
fmt_char_space:
	db `#\\space\0`
fmt_char_hex:
	db `#\\x%02X\0`
fmt_closure:
	db `#<closure at 0x%08X env=0x%08X code=0x%08X>\0`
fmt_lparen:
	db `(\0`
fmt_dotted_pair:
	db ` . \0`
fmt_rparen:
	db `)\0`
fmt_space:
	db ` \0`
fmt_empty_vector:
	db `#()\0`
fmt_vector:
	db `#(\0`
fmt_real:
	db `%f\0`
fmt_fraction:
	db `%ld/%ld\0`
fmt_zero:
	db `0\0`
fmt_int:
	db `%ld\0`
fmt_unknown_sexpr_error:
	db `\n\n!!! Error: Unknown type of sexpr (0x%02X) `
	db `at address 0x%08X\n\n\0`
fmt_dquote:
	db `\"\0`
fmt_string_char:
        db `%c\0`
fmt_string_char_7:
        db `\\a\0`
fmt_string_char_8:
        db `\\b\0`
fmt_string_char_9:
        db `\\t\0`
fmt_string_char_10:
        db `\\n\0`
fmt_string_char_11:
        db `\\v\0`
fmt_string_char_12:
        db `\\f\0`
fmt_string_char_13:
        db `\\r\0`
fmt_string_char_34:
        db `\\"\0`
fmt_string_char_92:
        db `\\\\\0`
fmt_string_char_hex:
        db `\\x%X;\0`

section .text

print_sexpr:
	ENTER
	mov al, byte [rdi]
	cmp al, T_void
	je .Lvoid
	cmp al, T_nil
	je .Lnil
	cmp al, T_boolean_false
	je .Lboolean_false
	cmp al, T_boolean_true
	je .Lboolean_true
	cmp al, T_char
	je .Lchar
	cmp al, T_symbol
	je .Lsymbol
	cmp al, T_pair
	je .Lpair
	cmp al, T_vector
	je .Lvector
	cmp al, T_closure
	je .Lclosure
	cmp al, T_real
	je .Lreal
	cmp al, T_rational
	je .Lrational
	cmp al, T_string
	je .Lstring

	jmp .Lunknown_sexpr_type

.Lvoid:
	mov rdi, fmt_void
	jmp .Lemit

.Lnil:
	mov rdi, fmt_nil
	jmp .Lemit

.Lboolean_false:
	mov rdi, fmt_boolean_false
	jmp .Lemit

.Lboolean_true:
	mov rdi, fmt_boolean_true
	jmp .Lemit

.Lchar:
	mov al, byte [rdi + 1]
	cmp al, ' '
	jle .Lchar_whitespace
	cmp al, 92 		; backslash
	je .Lchar_backslash
	cmp al, '"'
	je .Lchar_dquote
	and rax, 255
	mov rdi, fmt_char_simple
	mov rsi, rax
	jmp .Lemit

.Lchar_whitespace:
	cmp al, 0
	je .Lchar_null
	cmp al, 7
	je .Lchar_bell
	cmp al, 8
	je .Lchar_backspace
	cmp al, 9
	je .Lchar_tab
	cmp al, 10
	je .Lchar_newline
	cmp al, 12
	je .Lchar_formfeed
	cmp al, 13
	je .Lchar_return
	cmp al, 27
	je .Lchar_escape
	and rax, 255
	cmp al, ' '
	je .Lchar_space
	mov rdi, fmt_char_hex
	mov rsi, rax
	jmp .Lemit	

.Lchar_backslash:
	mov rdi, fmt_char_backslash
	jmp .Lemit

.Lchar_dquote:
	mov rdi, fmt_char_dquote
	jmp .Lemit

.Lchar_null:
	mov rdi, fmt_char_null
	jmp .Lemit

.Lchar_bell:
	mov rdi, fmt_char_bell
	jmp .Lemit

.Lchar_backspace:
	mov rdi, fmt_char_backspace
	jmp .Lemit

.Lchar_tab:
	mov rdi, fmt_char_tab
	jmp .Lemit

.Lchar_newline:
	mov rdi, fmt_char_newline
	jmp .Lemit

.Lchar_formfeed:
	mov rdi, fmt_char_formfeed
	jmp .Lemit

.Lchar_return:
	mov rdi, fmt_char_return
	jmp .Lemit

.Lchar_escape:
	mov rdi, fmt_char_escape
	jmp .Lemit

.Lchar_space:
	mov rdi, fmt_char_space
	jmp .Lemit

.Lclosure:
	mov rsi, qword rdi
	mov rdi, fmt_closure
	mov rdx, SOB_CLOSURE_ENV(rsi)
	mov rcx, SOB_CLOSURE_CODE(rsi)
	jmp .Lemit

.Lsymbol:
	mov rdi, qword [rdi + 1] ; sob_string
	mov rsi, 1		 ; size = 1 byte
	mov rdx, qword [rdi + 1] ; length
	lea rdi, [rdi + 1 + 8]	 ; actual characters
	mov rcx, qword [stdout]	 ; FILE *
	call fwrite
	jmp .Lend
	
.Lpair:
	push rdi
	mov rdi, fmt_lparen
	mov rax, 0
        ENTER
	call printf
        LEAVE
	mov rdi, qword [rsp] 	; pair
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi 		; pair
	mov rdi, SOB_PAIR_CDR(rdi)
.Lcdr:
	mov al, byte [rdi]
	cmp al, T_nil
	je .Lcdr_nil
	cmp al, T_pair
	je .Lcdr_pair
	push rdi
	mov rdi, fmt_dotted_pair
	mov rax, 0
	ENTER
	call printf
	LEAVE
	pop rdi
	call print_sexpr
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_nil:
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_pair:
	push rdi
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi
	mov rdi, SOB_PAIR_CDR(rdi)
	jmp .Lcdr

.Lvector:
	mov rax, qword [rdi + 1] ; length
	cmp rax, 0
	je .Lvector_empty
	push rdi
	mov rdi, fmt_vector
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	push qword [rdi + 1]
	push 1
	mov rdi, qword [rdi + 1 + 8] ; v[0]
	call print_sexpr
.Lvector_loop:
	; [rsp] index
	; [rsp + 8*1] limit
	; [rsp + 8*2] vector
	mov rax, qword [rsp]
	cmp rax, qword [rsp + 8*1]
	je .Lvector_end
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rax, qword [rsp]
	mov rbx, qword [rsp + 8*2]
	mov rdi, qword [rbx + 1 + 8 + 8 * rax] ; v[i]
	call print_sexpr
	inc qword [rsp]
	jmp .Lvector_loop

.Lvector_end:
	add rsp, 8*3
	mov rdi, fmt_rparen
	jmp .Lemit	

.Lvector_empty:
	mov rdi, fmt_empty_vector
	jmp .Lemit

.Lreal:
	push qword [rdi + 1]
	movsd xmm0, qword [rsp]
	add rsp, 8*1
	mov rdi, fmt_real
	mov rax, 1
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lrational:
	mov rsi, qword [rdi + 1]
	mov rdx, qword [rdi + 1 + 8]
	cmp rsi, 0
	je .Lrat_zero
	cmp rdx, 1
	je .Lrat_int
	mov rdi, fmt_fraction
	jmp .Lemit

.Lrat_zero:
	mov rdi, fmt_zero
	jmp .Lemit

.Lrat_int:
	mov rdi, fmt_int
	jmp .Lemit

.Lstring:
	lea rax, [rdi + 1 + 8]
	push rax
	push qword [rdi + 1]
	mov rdi, fmt_dquote
	mov rax, 0
	ENTER
	call printf
	LEAVE
.Lstring_loop:
	; qword [rsp]: limit
	; qword [rsp + 8*1]: char *
	cmp qword [rsp], 0
	je .Lstring_end
	mov rax, qword [rsp + 8*1]
	mov al, byte [rax]
	and rax, 255
	cmp al, 7
        je .Lstring_char_7
        cmp al, 8
        je .Lstring_char_8
        cmp al, 9
        je .Lstring_char_9
        cmp al, 10
        je .Lstring_char_10
        cmp al, 11
        je .Lstring_char_11
        cmp al, 12
        je .Lstring_char_12
        cmp al, 13
        je .Lstring_char_13
        cmp al, 34
        je .Lstring_char_34
        cmp al, 92              ; \
        je .Lstring_char_92
        cmp al, ' '
        jl .Lstring_char_hex
        mov rdi, fmt_string_char
        mov rsi, rax
.Lstring_char_emit:
        mov rax, 0
        ENTER
        call printf
        LEAVE
        dec qword [rsp]
        inc qword [rsp + 8*1]
        jmp .Lstring_loop

.Lstring_char_7:
        mov rdi, fmt_string_char_7
        jmp .Lstring_char_emit

.Lstring_char_8:
        mov rdi, fmt_string_char_8
        jmp .Lstring_char_emit
        
.Lstring_char_9:
        mov rdi, fmt_string_char_9
        jmp .Lstring_char_emit

.Lstring_char_10:
        mov rdi, fmt_string_char_10
        jmp .Lstring_char_emit

.Lstring_char_11:
        mov rdi, fmt_string_char_11
        jmp .Lstring_char_emit

.Lstring_char_12:
        mov rdi, fmt_string_char_12
        jmp .Lstring_char_emit

.Lstring_char_13:
        mov rdi, fmt_string_char_13
        jmp .Lstring_char_emit

.Lstring_char_34:
        mov rdi, fmt_string_char_34
        jmp .Lstring_char_emit

.Lstring_char_92:
        mov rdi, fmt_string_char_92
        jmp .Lstring_char_emit

.Lstring_char_hex:
        mov rdi, fmt_string_char_hex
        mov rsi, rax
        jmp .Lstring_char_emit        

.Lstring_end:
	add rsp, 8 * 2
	mov rdi, fmt_dquote
	jmp .Lemit

.Lunknown_sexpr_type:
	mov rsi, fmt_unknown_sexpr_error
	and rax, 255
	mov rdx, rax
	mov rcx, rdi
	mov rdi, qword [stderr]
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -1
	call exit

.Lemit:
	mov rax, 0
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lend:
	LEAVE
	ret

;;; rdi: address of free variable
;;; rsi: address of code-pointer
bind_primitive:
        ENTER
        push rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        pop rdi
        mov byte [rax], T_closure
        mov SOB_CLOSURE_ENV(rax), 0 ; dummy, lexical environment
        mov SOB_CLOSURE_CODE(rax), rsi ; code pointer
        mov qword [rdi], rax
        LEAVE
        ret

;;; PLEASE IMPLEMENT THIS PROCEDURE
L_code_ptr_bin_apply:
        enter 0,0
        ; loop over the list and push all its members
        mov rsi, 0
        mov rbx, COUNT
        dec rbx
        add rbx, 4
        shl rbx, 3
        add rbx, rbp
        mov rbx, [rbx] ; rbx = [rbp + 8 * (4 + (COUNT-1))]
L_bin_apply_list_loop_start: ; start pushing list to stack
        cmp byte [rbx], T_nil
        je L_bin_apply_list_loop_end
        inc rsi
        push SOB_PAIR_CAR(rbx)
        mov rbx, SOB_PAIR_CDR(rbx)
        jmp L_bin_apply_list_loop_start
L_bin_apply_list_loop_end: ; end pushing list to stack
        ; flip the list on the stack
        mov rbx, 0 ; index
L_bin_apply_list_flip_start:
        mov rcx, rsi
        dec rcx
        sub rcx, rbx ; rcx is the higher 
        sub rcx, rbx
        cmp rcx, 0
        jle L_bin_apply_list_flip_end
        add rcx, rbx ; rcx is the relative higher. rbx is the relative lower
        mov rdi, rbx
        shl rdi, 3
        add rdi, rsp ; rdi is the absolute higher
        mov rax, [rdi] ; rdi = [rsp + 8*rsi] ->  rax is the absolute higher value
        shl rcx, 3
        add rcx, rsp ; rcx = rsp + 8*(length-1-index) -> rcx is the absolute lower
        push rbx ; save rbx
        mov rbx, [rcx]
        mov [rdi], rbx ; [rsp + 8*rsi] = [rsp + 8*(length-1-index)]
        mov [rcx], rax ; [rsp + 8*(length-1-index)] = [rsp + 8*rsi]
        pop rbx ; restore rbx
        inc rbx
        jmp L_bin_apply_list_flip_start
L_bin_apply_list_flip_end:
        ; push all the rest of the arguments
        mov rcx, COUNT
        sub rcx, 2
L_bin_apply_args_loop_start: ; start pushing the rest of args
        cmp rcx, 0
        je L_bin_apply_args_loop_end
        inc rsi ; for counting number of args
        mov rbx, rcx
        add rbx, 4
        shl rbx, 3
        add rbx, rbp
        mov rbx, [rbx] ; rbx = [rbp + 8 * (4 + rcx)]
        push rbx
        dec rcx
        jmp L_bin_apply_args_loop_start
L_bin_apply_args_loop_end:
        ; push number of arguments
        push rsi
        ; push lex env
        mov rax, PARAM(0)
        push SOB_CLOSURE_ENV(rax)
        ; push ret add
        push RET_ADDR
        ; fix the stack
        ; loop over the stack and move it to the top of the previos stack
        mov rdx, rsi

        mov rdi, COUNT 
        add rdi, 3 ; rdi = COUNT + 3 = COUNT + (num_of_args, lex, ret)
        shl rdi, 3
        add rdi, rbp

        mov rbp, OLD_RDP
        mov rsi, 0
L_bin_apply_fix_stack_start:
        mov rcx, rdx
        add rcx, 3
        cmp rsi, rcx
        je L_bin_apply_fix_stack_end
        mov rcx, rdx 
        add rcx, 2 
        sub rcx, rsi 
        shl rcx, 3
        add rcx, rsp ; rcx is the address to move.
        mov rbx, rsi
        shl rbx, 3
        neg rbx
        add rbx, rdi ; rbx is the address to move to.
        mov rcx, [rcx]
        mov [rbx], rcx
        inc rsi
        jmp L_bin_apply_fix_stack_start
L_bin_apply_fix_stack_end:
        ; fix rsp
        mov rbx, rdx
        add rbx, 2
        shl rbx, 3
        neg rbx
        add rbx, rdi
        mov rsp, rbx
        mov rbx, SOB_CLOSURE_CODE(rax)
        jmp rbx
	
L_code_ptr_is_null:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_nil
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_pair:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_pair
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_void:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_void
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_char
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_string:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_string
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_symbol:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_symbol
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_vector:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_vector
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_closure:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_closure
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_real
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_rational:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_boolean:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_boolean
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_number:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_number
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_collection:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_collection
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_cons:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_pair
        mov rbx, PARAM(0)
        mov SOB_PAIR_CAR(rax), rbx
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_display_sexpr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rdi, PARAM(0)
        call print_sexpr
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_write_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, SOB_CHAR_VALUE(rax)
        and rax, 255
        mov rdi, fmt_char
        mov rsi, rax
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_car:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CAR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_cdr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CDR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_string_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_string(rax)
        mov rdi, SOB_STRING_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_vector_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_vector(rax)
        mov rdi, SOB_VECTOR_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_real_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rbx, PARAM(0)
        assert_real(rbx)
        movsd xmm0, qword [rbx + 1]
        cvttsd2si rdi, xmm0
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_exit:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        mov rax, 0
        call exit

L_code_ptr_integer_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_rational_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        push qword [rax + 1 + 8]
        cvtsi2sd xmm1, qword [rsp]
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_char_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, byte [rax + 1]
        and rax, 255
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_integer_to_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        mov rbx, qword [rax + 1]
        cmp rbx, 0
        jle L_error_integer_range
        cmp rbx, 256
        jge L_error_integer_range
        mov rdi, (1 + 1)
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_trng:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        rdrand rdi
        shr rdi, 1
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(0)

L_code_ptr_is_zero:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        je .L_rational
        cmp byte [rax], T_real
        je .L_real
        jmp L_error_incorrect_type
.L_rational:
        cmp qword [rax + 1], 0
        je .L_zero
        jmp .L_not_zero
.L_real:
        pxor xmm0, xmm0
        push qword [rax + 1]
        movsd xmm1, qword [rsp]
        ucomisd xmm0, xmm1
        je .L_zero
.L_not_zero:
        mov rax, sob_boolean_false
        jmp .L_end
.L_zero:
        mov rax, sob_boolean_true
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        cmp qword [rax + 1 + 8], 1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_raw_bin_add_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        addsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        subsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        mulsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_div_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        pxor xmm2, xmm2
        ucomisd xmm1, xmm2
        je L_error_division_by_zero
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_add_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        add rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        sub rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_bin_div_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        cmp qword [r9 + 1], 0
        je L_error_division_by_zero
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
normalize_rational:
        push rsi
        push rdi
        call gcd
        mov rbx, rax
        pop rax
        cqo
        idiv rbx
        mov r8, rax
        pop rax
        cqo
        idiv rbx
        mov r9, rax
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], r9
        mov qword [rax + 1 + 8], r8
        ret

iabs:
        mov rax, rdi
        cmp rax, 0
        jl .Lneg
        ret
.Lneg:
        neg rax
        ret

gcd:
        call iabs
        mov rbx, rax
        mov rdi, rsi
        call iabs
        cmp rax, 0
        jne .L0
        xchg rax, rbx
.L0:
        cmp rbx, 0
        je .L1
        cqo
        div rbx
        mov rax, rdx
        xchg rax, rbx
        jmp .L0
.L1:
        ret

L_code_ptr_error:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_symbol(rsi)
        mov rsi, PARAM(1)
        assert_string(rsi)
        mov rdi, fmt_scheme_error_part_1
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rdi, PARAM(0)
        call print_sexpr
        mov rdi, fmt_scheme_error_part_2
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, PARAM(1)       ; sob_string
        mov rsi, 1              ; size = 1 byte
        mov rdx, qword [rax + 1] ; length
        lea rdi, [rax + 1 + 8]   ; actual characters
        mov rcx, qword [stdout]  ; FILE*
        call fwrite
        mov rdi, fmt_scheme_error_part_3
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, -9
        call exit

L_code_ptr_raw_less_than_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jae .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_less_than_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rsi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jge .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_equal_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_equal_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rdi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_quotient:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_remainder:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rdx
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_car:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CAR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_cdr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_string_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov bl, byte [rdi + 1 + 8 + 1 * rcx]
        mov rdi, 2
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, [rdi + 1 + 8 + 8 * rcx]
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        mov qword [rdi + 1 + 8 + 8 * rcx], rax
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_string_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        assert_char(rax)
        mov al, byte [rax + 1]
        mov byte [rdi + 1 + 8 + 1 * rcx], al
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_make_vector:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        lea rdi, [1 + 8 + 8 * rcx]
        call malloc
        mov byte [rax], T_vector
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov qword [rax + 1 + 8 + 8 * r8], rdx
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_make_string:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        assert_char(rdx)
        mov dl, byte [rdx + 1]
        lea rdi, [1 + 8 + 1 * rcx]
        call malloc
        mov byte [rax], T_string
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov byte [rax + 1 + 8 + 1 * r8], dl
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_numerator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_denominator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1 + 8]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_eq:
	ENTER
	cmp COUNT, 2
	jne L_error_arg_count_2
	mov rdi, PARAM(0)
	mov rsi, PARAM(1)
	cmp rdi, rsi
	je .L_eq_true
	mov dl, byte [rdi]
	cmp dl, byte [rsi]
	jne .L_eq_false
	cmp dl, T_char
	je .L_char
	cmp dl, T_symbol
	je .L_symbol
	cmp dl, T_real
	je .L_real
	cmp dl, T_rational
	je .L_rational
	jmp .L_eq_false
.L_rational:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
	jne .L_eq_false
	mov rax, qword [rsi + 1 + 8]
	cmp rax, qword [rdi + 1 + 8]
	jne .L_eq_false
	jmp .L_eq_true
.L_real:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_symbol:
	; never reached, because symbols are static!
	; but I'm keeping it in case, I'll ever change
	; the implementation
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_char:
	mov bl, byte [rsi + 1]
	cmp bl, byte [rdi + 1]
	jne .L_eq_false
.L_eq_true:
	mov rax, sob_boolean_true
	jmp .L_eq_exit
.L_eq_false:
	mov rax, sob_boolean_false
.L_eq_exit:
	LEAVE
	ret AND_KILL_FRAME(2)

make_real:
        ENTER
        mov rdi, (1 + 8)
        call malloc
        mov byte [rax], T_real
        movsd qword [rax + 1], xmm0
        LEAVE
        ret
        
make_integer:
        ENTER
        mov rsi, rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], rsi
        mov qword [rax + 1 + 8], 1
        LEAVE
        ret
        
L_error_integer_range:
        mov rdi, qword [stderr]
        mov rsi, fmt_integer_range
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -5
        call exit

L_error_arg_count_0:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_0
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_1:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_1
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_2:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_2
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_12:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_12
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_3:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_3
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_apply_no_list:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_apply_no_list
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -4
        call exit  

L_error_incorrect_type:
        mov rdi, qword [stderr]
        mov rsi, fmt_type
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -4
        call exit

L_error_division_by_zero:
        mov rdi, qword [stderr]
        mov rsi, fmt_division_by_zero
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -8
        call exit

section .data
fmt_char:
        db `%c\0`
fmt_arg_count_0:
        db `!!! Expecting zero arguments. Found %d\n\0`
fmt_arg_count_1:
        db `!!! Expecting one argument. Found %d\n\0`
fmt_arg_count_12:
        db `!!! Expecting one required and one optional argument. Found %d\n\0`
fmt_arg_count_2:
        db `!!! Expecting two arguments. Found %d\n\0`
fmt_arg_count_3:
        db `!!! Expecting three arguments. Found %d\n\0`
fmt_arg_apply_no_list:
        db `!!! The last argument in apply should be a proper list\n\0`
fmt_type:
        db `!!! Function passed incorrect type\n\0`
fmt_integer_range:
        db `!!! Incorrect integer range\n\0`
fmt_division_by_zero:
        db `!!! Division by zero\n\0`
fmt_scheme_error_part_1:
        db `\n!!! The procedure \0`
fmt_scheme_error_part_2:
        db ` asked to terminate the program\n`
        db `    with the following message:\n\n\0`
fmt_scheme_error_part_3:
        db `\n\nGoodbye!\n\n\0`