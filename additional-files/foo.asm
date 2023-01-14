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
	db T_rational	; 1
	dq 1, 1
	db T_string	; "*"
	dq 1
	db 0x2A
	db T_symbol	; *
	dq L_constants + 145
	db T_string	; "/"
	dq 1
	db 0x2F
	db T_symbol	; /
	dq L_constants + 164
	db T_string	; "generic-comparator"
	dq 18
	db 0x67, 0x65, 0x6E, 0x65, 0x72, 0x69, 0x63, 0x2D
	db 0x63, 0x6F, 0x6D, 0x70, 0x61, 0x72, 0x61, 0x74
	db 0x6F, 0x72
	db T_symbol	; generic-comparator
	dq L_constants + 183
	db T_string	; "all the arguments m...
	dq 33
	db 0x61, 0x6C, 0x6C, 0x20, 0x74, 0x68, 0x65, 0x20
	db 0x61, 0x72, 0x67, 0x75, 0x6D, 0x65, 0x6E, 0x74
	db 0x73, 0x20, 0x6D, 0x75, 0x73, 0x74, 0x20, 0x62
	db 0x65, 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72
	db 0x73
	db T_string	; "make-list"
	dq 9
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74
	db T_symbol	; make-list
	dq L_constants + 261
	db T_string	; "Usage: (make-list l...
	dq 45
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74, 0x20, 0x6C, 0x65, 0x6E, 0x67, 0x74, 0x68
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x69, 0x6E, 0x69, 0x74, 0x2D
	db 0x63, 0x68, 0x61, 0x72, 0x29
	db T_char, 0x41	; #\A
	db T_char, 0x5A	; #\Z
	db T_char, 0x61	; #\a
	db T_char, 0x7A	; #\z
	db T_string	; "make-vector"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72
	db T_symbol	; make-vector
	dq L_constants + 350
	db T_string	; "Usage: (make-vector...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_string	; "make-string"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67
	db T_symbol	; make-string
	dq L_constants + 431
	db T_string	; "Usage: (make-string...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_rational	; 2
	dq 2, 1
	db T_rational	; 10
	dq 10, 1

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
free_var_56:	; location of caar
	resq 1
free_var_57:	; location of cadr
	resq 1
free_var_58:	; location of cdar
	resq 1
free_var_59:	; location of cddr
	resq 1
free_var_60:	; location of caaar
	resq 1
free_var_61:	; location of caadr
	resq 1
free_var_62:	; location of cadar
	resq 1
free_var_63:	; location of caddr
	resq 1
free_var_64:	; location of cdaar
	resq 1
free_var_65:	; location of cdadr
	resq 1
free_var_66:	; location of cddar
	resq 1
free_var_67:	; location of cdddr
	resq 1
free_var_68:	; location of caaaar
	resq 1
free_var_69:	; location of caaadr
	resq 1
free_var_70:	; location of caadar
	resq 1
free_var_71:	; location of caaddr
	resq 1
free_var_72:	; location of cadaar
	resq 1
free_var_73:	; location of cadadr
	resq 1
free_var_74:	; location of caddar
	resq 1
free_var_75:	; location of cadddr
	resq 1
free_var_76:	; location of cdaaar
	resq 1
free_var_77:	; location of cdaadr
	resq 1
free_var_78:	; location of cdadar
	resq 1
free_var_79:	; location of cdaddr
	resq 1
free_var_80:	; location of cddaar
	resq 1
free_var_81:	; location of cddadr
	resq 1
free_var_82:	; location of cdddar
	resq 1
free_var_83:	; location of cddddr
	resq 1
free_var_84:	; location of list?
	resq 1
free_var_85:	; location of list
	resq 1
free_var_86:	; location of not
	resq 1
free_var_87:	; location of fraction?
	resq 1
free_var_88:	; location of list*
	resq 1
free_var_89:	; location of apply
	resq 1
free_var_90:	; location of ormap
	resq 1
free_var_91:	; location of map
	resq 1
free_var_92:	; location of andmap
	resq 1
free_var_93:	; location of reverse
	resq 1
free_var_94:	; location of append
	resq 1
free_var_95:	; location of fold-left
	resq 1
free_var_96:	; location of fold-right
	resq 1
free_var_97:	; location of +
	resq 1
free_var_98:	; location of -
	resq 1
free_var_99:	; location of *
	resq 1
free_var_100:	; location of /
	resq 1
free_var_101:	; location of fact
	resq 1
free_var_102:	; location of <
	resq 1
free_var_103:	; location of <=
	resq 1
free_var_104:	; location of >
	resq 1
free_var_105:	; location of >=
	resq 1
free_var_106:	; location of =
	resq 1
free_var_107:	; location of make-list
	resq 1
free_var_108:	; location of char<?
	resq 1
free_var_109:	; location of char<=?
	resq 1
free_var_110:	; location of char=?
	resq 1
free_var_111:	; location of char>?
	resq 1
free_var_112:	; location of char>=?
	resq 1
free_var_113:	; location of char-downcase
	resq 1
free_var_114:	; location of char-upcase
	resq 1
free_var_115:	; location of char-ci<?
	resq 1
free_var_116:	; location of char-ci<=?
	resq 1
free_var_117:	; location of char-ci=?
	resq 1
free_var_118:	; location of char-ci>?
	resq 1
free_var_119:	; location of char-ci>=?
	resq 1
free_var_120:	; location of string-downcase
	resq 1
free_var_121:	; location of string-upcase
	resq 1
free_var_122:	; location of list->string
	resq 1
free_var_123:	; location of string->list
	resq 1
free_var_124:	; location of string<?
	resq 1
free_var_125:	; location of string<=?
	resq 1
free_var_126:	; location of string=?
	resq 1
free_var_127:	; location of string>=?
	resq 1
free_var_128:	; location of string>?
	resq 1
free_var_129:	; location of string-ci<?
	resq 1
free_var_130:	; location of string-ci<=?
	resq 1
free_var_131:	; location of string-ci=?
	resq 1
free_var_132:	; location of string-ci>=?
	resq 1
free_var_133:	; location of string-ci>?
	resq 1
free_var_134:	; location of length
	resq 1
free_var_135:	; location of list->vector
	resq 1
free_var_136:	; location of vector
	resq 1
free_var_137:	; location of vector->list
	resq 1
free_var_138:	; location of random
	resq 1
free_var_139:	; location of positive?
	resq 1
free_var_140:	; location of negative?
	resq 1
free_var_141:	; location of even?
	resq 1
free_var_142:	; location of odd?
	resq 1
free_var_143:	; location of abs
	resq 1
free_var_144:	; location of equal?
	resq 1
free_var_145:	; location of assoc
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
.L_lambda_simple_env_loop_4f29:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f29
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f29
.L_lambda_simple_env_end_4f29:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f29:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f29
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f29
.L_lambda_simple_params_end_4f29:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f29
	jmp .L_lambda_simple_end_4f29
.L_lambda_simple_code_4f29:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f29
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f29:
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
	mov rax, qword [free_var_16]
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
.L_tc_recycle_frame_loop_5c9d:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5c9d
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
	jmp .L_tc_recycle_frame_loop_5c9d
.L_tc_recycle_frame_done_5c9d:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f29:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f2a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f2a
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f2a
.L_lambda_simple_env_end_4f2a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f2a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f2a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f2a
.L_lambda_simple_params_end_4f2a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f2a
	jmp .L_lambda_simple_end_4f2a
.L_lambda_simple_code_4f2a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f2a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f2a:
	enter 0, 0
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
	push 1
	mov rax, qword [free_var_16]
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
.L_tc_recycle_frame_loop_5c9e:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5c9e
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
	jmp .L_tc_recycle_frame_loop_5c9e
.L_tc_recycle_frame_done_5c9e:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f2a:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f2b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f2b
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f2b
.L_lambda_simple_env_end_4f2b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f2b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f2b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f2b
.L_lambda_simple_params_end_4f2b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f2b
	jmp .L_lambda_simple_end_4f2b
.L_lambda_simple_code_4f2b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f2b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f2b:
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
	mov rax, qword [free_var_17]
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
.L_tc_recycle_frame_loop_5c9f:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5c9f
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
	jmp .L_tc_recycle_frame_loop_5c9f
.L_tc_recycle_frame_done_5c9f:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f2b:	; new closure is in rax
	mov qword [free_var_58], rax
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
.L_lambda_simple_env_loop_4f2c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f2c
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f2c
.L_lambda_simple_env_end_4f2c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f2c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f2c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f2c
.L_lambda_simple_params_end_4f2c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f2c
	jmp .L_lambda_simple_end_4f2c
.L_lambda_simple_code_4f2c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f2c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f2c:
	enter 0, 0
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
	push 1
	mov rax, qword [free_var_17]
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
.L_tc_recycle_frame_loop_5ca0:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca0
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
	jmp .L_tc_recycle_frame_loop_5ca0
.L_tc_recycle_frame_done_5ca0:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f2c:	; new closure is in rax
	mov qword [free_var_59], rax
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
.L_lambda_simple_env_loop_4f2d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f2d
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f2d
.L_lambda_simple_env_end_4f2d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f2d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f2d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f2d
.L_lambda_simple_params_end_4f2d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f2d
	jmp .L_lambda_simple_end_4f2d
.L_lambda_simple_code_4f2d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f2d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f2d:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_16]
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
.L_tc_recycle_frame_loop_5ca1:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca1
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
	jmp .L_tc_recycle_frame_loop_5ca1
.L_tc_recycle_frame_done_5ca1:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f2d:	; new closure is in rax
	mov qword [free_var_60], rax
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
.L_lambda_simple_env_loop_4f2e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f2e
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f2e
.L_lambda_simple_env_end_4f2e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f2e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f2e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f2e
.L_lambda_simple_params_end_4f2e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f2e
	jmp .L_lambda_simple_end_4f2e
.L_lambda_simple_code_4f2e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f2e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f2e:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_16]
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
.L_tc_recycle_frame_loop_5ca2:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca2
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
	jmp .L_tc_recycle_frame_loop_5ca2
.L_tc_recycle_frame_done_5ca2:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f2e:	; new closure is in rax
	mov qword [free_var_61], rax
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
.L_lambda_simple_env_loop_4f2f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f2f
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f2f
.L_lambda_simple_env_end_4f2f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f2f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f2f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f2f
.L_lambda_simple_params_end_4f2f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f2f
	jmp .L_lambda_simple_end_4f2f
.L_lambda_simple_code_4f2f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f2f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f2f:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_16]
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
.L_tc_recycle_frame_loop_5ca3:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca3
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
	jmp .L_tc_recycle_frame_loop_5ca3
.L_tc_recycle_frame_done_5ca3:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f2f:	; new closure is in rax
	mov qword [free_var_62], rax
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
.L_lambda_simple_env_loop_4f30:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f30
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f30
.L_lambda_simple_env_end_4f30:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f30:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f30
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f30
.L_lambda_simple_params_end_4f30:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f30
	jmp .L_lambda_simple_end_4f30
.L_lambda_simple_code_4f30:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f30
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f30:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_16]
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
.L_tc_recycle_frame_loop_5ca4:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca4
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
	jmp .L_tc_recycle_frame_loop_5ca4
.L_tc_recycle_frame_done_5ca4:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f30:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f31:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f31
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f31
.L_lambda_simple_env_end_4f31:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f31:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f31
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f31
.L_lambda_simple_params_end_4f31:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f31
	jmp .L_lambda_simple_end_4f31
.L_lambda_simple_code_4f31:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f31
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f31:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_17]
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
.L_tc_recycle_frame_loop_5ca5:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca5
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
	jmp .L_tc_recycle_frame_loop_5ca5
.L_tc_recycle_frame_done_5ca5:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f31:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f32:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f32
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f32
.L_lambda_simple_env_end_4f32:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f32:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f32
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f32
.L_lambda_simple_params_end_4f32:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f32
	jmp .L_lambda_simple_end_4f32
.L_lambda_simple_code_4f32:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f32
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f32:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_17]
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
.L_tc_recycle_frame_loop_5ca6:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca6
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
	jmp .L_tc_recycle_frame_loop_5ca6
.L_tc_recycle_frame_done_5ca6:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f32:	; new closure is in rax
	mov qword [free_var_65], rax
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
.L_lambda_simple_env_loop_4f33:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f33
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f33
.L_lambda_simple_env_end_4f33:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f33:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f33
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f33
.L_lambda_simple_params_end_4f33:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f33
	jmp .L_lambda_simple_end_4f33
.L_lambda_simple_code_4f33:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f33
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f33:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_17]
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
.L_tc_recycle_frame_loop_5ca7:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca7
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
	jmp .L_tc_recycle_frame_loop_5ca7
.L_tc_recycle_frame_done_5ca7:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f33:	; new closure is in rax
	mov qword [free_var_66], rax
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
.L_lambda_simple_env_loop_4f34:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f34
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f34
.L_lambda_simple_env_end_4f34:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f34:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f34
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f34
.L_lambda_simple_params_end_4f34:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f34
	jmp .L_lambda_simple_end_4f34
.L_lambda_simple_code_4f34:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f34
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f34:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_17]
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
.L_tc_recycle_frame_loop_5ca8:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca8
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
	jmp .L_tc_recycle_frame_loop_5ca8
.L_tc_recycle_frame_done_5ca8:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f34:	; new closure is in rax
	mov qword [free_var_67], rax
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
.L_lambda_simple_env_loop_4f35:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f35
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f35
.L_lambda_simple_env_end_4f35:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f35:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f35
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f35
.L_lambda_simple_params_end_4f35:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f35
	jmp .L_lambda_simple_end_4f35
.L_lambda_simple_code_4f35:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f35
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f35:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
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
.L_tc_recycle_frame_loop_5ca9:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ca9
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
	jmp .L_tc_recycle_frame_loop_5ca9
.L_tc_recycle_frame_done_5ca9:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f35:	; new closure is in rax
	mov qword [free_var_68], rax
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
.L_lambda_simple_env_loop_4f36:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f36
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f36
.L_lambda_simple_env_end_4f36:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f36:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f36
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f36
.L_lambda_simple_params_end_4f36:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f36
	jmp .L_lambda_simple_end_4f36
.L_lambda_simple_code_4f36:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f36
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f36:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
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
.L_tc_recycle_frame_loop_5caa:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5caa
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
	jmp .L_tc_recycle_frame_loop_5caa
.L_tc_recycle_frame_done_5caa:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f36:	; new closure is in rax
	mov qword [free_var_69], rax
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
.L_lambda_simple_env_loop_4f37:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f37
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f37
.L_lambda_simple_env_end_4f37:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f37:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f37
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f37
.L_lambda_simple_params_end_4f37:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f37
	jmp .L_lambda_simple_end_4f37
.L_lambda_simple_code_4f37:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f37
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f37:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
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
.L_tc_recycle_frame_loop_5cab:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cab
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
	jmp .L_tc_recycle_frame_loop_5cab
.L_tc_recycle_frame_done_5cab:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f37:	; new closure is in rax
	mov qword [free_var_70], rax
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
.L_lambda_simple_env_loop_4f38:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f38
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f38
.L_lambda_simple_env_end_4f38:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f38:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f38
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f38
.L_lambda_simple_params_end_4f38:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f38
	jmp .L_lambda_simple_end_4f38
.L_lambda_simple_code_4f38:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f38
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f38:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
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
.L_tc_recycle_frame_loop_5cac:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cac
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
	jmp .L_tc_recycle_frame_loop_5cac
.L_tc_recycle_frame_done_5cac:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f38:	; new closure is in rax
	mov qword [free_var_71], rax
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
.L_lambda_simple_env_loop_4f39:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f39
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f39
.L_lambda_simple_env_end_4f39:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f39:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f39
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f39
.L_lambda_simple_params_end_4f39:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f39
	jmp .L_lambda_simple_end_4f39
.L_lambda_simple_code_4f39:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f39
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f39:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_57]
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
.L_tc_recycle_frame_loop_5cad:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cad
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
	jmp .L_tc_recycle_frame_loop_5cad
.L_tc_recycle_frame_done_5cad:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f39:	; new closure is in rax
	mov qword [free_var_72], rax
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
.L_lambda_simple_env_loop_4f3a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f3a
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f3a
.L_lambda_simple_env_end_4f3a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f3a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f3a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f3a
.L_lambda_simple_params_end_4f3a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f3a
	jmp .L_lambda_simple_end_4f3a
.L_lambda_simple_code_4f3a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f3a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f3a:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_57]
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
.L_tc_recycle_frame_loop_5cae:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cae
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
	jmp .L_tc_recycle_frame_loop_5cae
.L_tc_recycle_frame_done_5cae:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f3a:	; new closure is in rax
	mov qword [free_var_73], rax
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
.L_lambda_simple_env_loop_4f3b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f3b
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f3b
.L_lambda_simple_env_end_4f3b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f3b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f3b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f3b
.L_lambda_simple_params_end_4f3b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f3b
	jmp .L_lambda_simple_end_4f3b
.L_lambda_simple_code_4f3b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f3b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f3b:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_57]
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
.L_tc_recycle_frame_loop_5caf:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5caf
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
	jmp .L_tc_recycle_frame_loop_5caf
.L_tc_recycle_frame_done_5caf:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f3b:	; new closure is in rax
	mov qword [free_var_74], rax
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
.L_lambda_simple_env_loop_4f3c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f3c
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f3c
.L_lambda_simple_env_end_4f3c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f3c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f3c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f3c
.L_lambda_simple_params_end_4f3c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f3c
	jmp .L_lambda_simple_end_4f3c
.L_lambda_simple_code_4f3c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f3c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f3c:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_57]
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
.L_tc_recycle_frame_loop_5cb0:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb0
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
	jmp .L_tc_recycle_frame_loop_5cb0
.L_tc_recycle_frame_done_5cb0:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f3c:	; new closure is in rax
	mov qword [free_var_75], rax
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
.L_lambda_simple_env_loop_4f3d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f3d
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f3d
.L_lambda_simple_env_end_4f3d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f3d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f3d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f3d
.L_lambda_simple_params_end_4f3d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f3d
	jmp .L_lambda_simple_end_4f3d
.L_lambda_simple_code_4f3d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f3d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f3d:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_58]
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
.L_tc_recycle_frame_loop_5cb1:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb1
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
	jmp .L_tc_recycle_frame_loop_5cb1
.L_tc_recycle_frame_done_5cb1:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f3d:	; new closure is in rax
	mov qword [free_var_76], rax
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
.L_lambda_simple_env_loop_4f3e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f3e
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f3e
.L_lambda_simple_env_end_4f3e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f3e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f3e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f3e
.L_lambda_simple_params_end_4f3e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f3e
	jmp .L_lambda_simple_end_4f3e
.L_lambda_simple_code_4f3e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f3e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f3e:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_58]
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
.L_tc_recycle_frame_loop_5cb2:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb2
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
	jmp .L_tc_recycle_frame_loop_5cb2
.L_tc_recycle_frame_done_5cb2:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f3e:	; new closure is in rax
	mov qword [free_var_77], rax
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
.L_lambda_simple_env_loop_4f3f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f3f
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f3f
.L_lambda_simple_env_end_4f3f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f3f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f3f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f3f
.L_lambda_simple_params_end_4f3f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f3f
	jmp .L_lambda_simple_end_4f3f
.L_lambda_simple_code_4f3f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f3f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f3f:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_58]
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
.L_tc_recycle_frame_loop_5cb3:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb3
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
	jmp .L_tc_recycle_frame_loop_5cb3
.L_tc_recycle_frame_done_5cb3:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f3f:	; new closure is in rax
	mov qword [free_var_78], rax
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
.L_lambda_simple_env_loop_4f40:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f40
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f40
.L_lambda_simple_env_end_4f40:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f40:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f40
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f40
.L_lambda_simple_params_end_4f40:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f40
	jmp .L_lambda_simple_end_4f40
.L_lambda_simple_code_4f40:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f40
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f40:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_58]
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
.L_tc_recycle_frame_loop_5cb4:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb4
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
	jmp .L_tc_recycle_frame_loop_5cb4
.L_tc_recycle_frame_done_5cb4:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f40:	; new closure is in rax
	mov qword [free_var_79], rax
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
.L_lambda_simple_env_loop_4f41:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f41
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f41
.L_lambda_simple_env_end_4f41:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f41:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f41
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f41
.L_lambda_simple_params_end_4f41:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f41
	jmp .L_lambda_simple_end_4f41
.L_lambda_simple_code_4f41:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f41
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f41:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_59]
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
.L_tc_recycle_frame_loop_5cb5:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb5
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
	jmp .L_tc_recycle_frame_loop_5cb5
.L_tc_recycle_frame_done_5cb5:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f41:	; new closure is in rax
	mov qword [free_var_80], rax
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
.L_lambda_simple_env_loop_4f42:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f42
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f42
.L_lambda_simple_env_end_4f42:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f42:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f42
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f42
.L_lambda_simple_params_end_4f42:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f42
	jmp .L_lambda_simple_end_4f42
.L_lambda_simple_code_4f42:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f42
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f42:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_59]
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
.L_tc_recycle_frame_loop_5cb6:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb6
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
	jmp .L_tc_recycle_frame_loop_5cb6
.L_tc_recycle_frame_done_5cb6:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f42:	; new closure is in rax
	mov qword [free_var_81], rax
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
.L_lambda_simple_env_loop_4f43:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f43
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f43
.L_lambda_simple_env_end_4f43:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f43:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f43
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f43
.L_lambda_simple_params_end_4f43:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f43
	jmp .L_lambda_simple_end_4f43
.L_lambda_simple_code_4f43:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f43
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f43:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_59]
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
.L_tc_recycle_frame_loop_5cb7:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb7
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
	jmp .L_tc_recycle_frame_loop_5cb7
.L_tc_recycle_frame_done_5cb7:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f43:	; new closure is in rax
	mov qword [free_var_82], rax
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
.L_lambda_simple_env_loop_4f44:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f44
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f44
.L_lambda_simple_env_end_4f44:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f44:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f44
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f44
.L_lambda_simple_params_end_4f44:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f44
	jmp .L_lambda_simple_end_4f44
.L_lambda_simple_code_4f44:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f44
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f44:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_59]
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
.L_tc_recycle_frame_loop_5cb8:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb8
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
	jmp .L_tc_recycle_frame_loop_5cb8
.L_tc_recycle_frame_done_5cb8:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f44:	; new closure is in rax
	mov qword [free_var_83], rax
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
.L_lambda_simple_env_loop_4f45:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f45
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f45
.L_lambda_simple_env_end_4f45:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f45:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f45
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f45
.L_lambda_simple_params_end_4f45:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f45
	jmp .L_lambda_simple_end_4f45
.L_lambda_simple_code_4f45:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f45
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f45:
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
	jne .L_or_end_0614
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_567c
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
	push 1
	mov rax, qword [free_var_84]
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
.L_tc_recycle_frame_loop_5cb9:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cb9
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
	jmp .L_tc_recycle_frame_loop_5cb9
.L_tc_recycle_frame_done_5cb9:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_567c
	.L_if_else_567c:
	lea rax, [2 + L_constants]
	.L_if_end_567c:
.L_or_end_0614:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f45:	; new closure is in rax
	mov qword [free_var_84], rax
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
.L_lambda_opt_env_loop_0c85:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0c85
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c85
.L_lambda_opt_env_end_0c85:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c85:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0c85
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c85
.L_lambda_opt_params_end_0c85:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c85
	jmp .L_lambda_opt_end_0c85
.L_lambda_opt_code_0c85:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c85
.L_lambda_opt_arity_check_exact_0c85:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c85:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_0c85
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c85
.L_lambda_opt_stack_enlarge_loop_exit_0c85:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_0c85
.L_lambda_opt_arity_check_more_0c85:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c85:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c85
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
	jmp .L_lambda_opt_list_create_loop_0c85
.L_lambda_opt_list_create_loop_exit_0c85:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c85:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_0c85
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
	jmp .L_lambda_opt_stack_shrink_loop_0c85
.L_lambda_opt_stack_shrink_loop_exit_0c85:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_0c85:
	enter 0, 0
	mov rax, PARAM(0)
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_0c85:	; new closure is in rax
	mov qword [free_var_85], rax
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
.L_lambda_simple_env_loop_4f46:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f46
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f46
.L_lambda_simple_env_end_4f46:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f46:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f46
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f46
.L_lambda_simple_params_end_4f46:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f46
	jmp .L_lambda_simple_end_4f46
.L_lambda_simple_code_4f46:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f46
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f46:
	enter 0, 0
	mov rax, PARAM(0)
	cmp rax, sob_boolean_false
	je .L_if_else_567d
	lea rax, [2 + L_constants]
	jmp .L_if_end_567d
	.L_if_else_567d:
	lea rax, [3 + L_constants]
	.L_if_end_567d:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f46:	; new closure is in rax
	mov qword [free_var_86], rax
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
.L_lambda_simple_env_loop_4f47:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f47
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f47
.L_lambda_simple_env_end_4f47:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f47:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f47
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f47
.L_lambda_simple_params_end_4f47:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f47
	jmp .L_lambda_simple_end_4f47
.L_lambda_simple_code_4f47:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f47
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f47:
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
	je .L_if_else_567e
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_28]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_86]
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
.L_tc_recycle_frame_loop_5cba:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cba
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
	jmp .L_tc_recycle_frame_loop_5cba
.L_tc_recycle_frame_done_5cba:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_567e
	.L_if_else_567e:
	lea rax, [2 + L_constants]
	.L_if_end_567e:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f47:	; new closure is in rax
	mov qword [free_var_87], rax
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
.L_lambda_simple_env_loop_4f48:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f48
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f48
.L_lambda_simple_env_end_4f48:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f48:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f48
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f48
.L_lambda_simple_params_end_4f48:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f48
	jmp .L_lambda_simple_end_4f48
.L_lambda_simple_code_4f48:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f48
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f48:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f49:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f49
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f49
.L_lambda_simple_env_end_4f49:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f49:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f49
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f49
.L_lambda_simple_params_end_4f49:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f49
	jmp .L_lambda_simple_end_4f49
.L_lambda_simple_code_4f49:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f49
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f49:
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
	je .L_if_else_567f
	mov rax, PARAM(0)
	jmp .L_if_end_567f
	.L_if_else_567f:
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
.L_tc_recycle_frame_loop_5cbb:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cbb
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
	jmp .L_tc_recycle_frame_loop_5cbb
.L_tc_recycle_frame_done_5cbb:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_567f:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f49:	; new closure is in rax
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
.L_lambda_opt_env_loop_0c86:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c86
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c86
.L_lambda_opt_env_end_0c86:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c86:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c86
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c86
.L_lambda_opt_params_end_0c86:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c86
	jmp .L_lambda_opt_end_0c86
.L_lambda_opt_code_0c86:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c86
.L_lambda_opt_arity_check_exact_0c86:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c86:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c86
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c86
.L_lambda_opt_stack_enlarge_loop_exit_0c86:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c86
.L_lambda_opt_arity_check_more_0c86:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c86:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c86
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
	jmp .L_lambda_opt_list_create_loop_0c86
.L_lambda_opt_list_create_loop_exit_0c86:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c86:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c86
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
	jmp .L_lambda_opt_stack_shrink_loop_0c86
.L_lambda_opt_stack_shrink_loop_exit_0c86:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c86:
	enter 0, 0
	mov rax, PARAM(1)
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
.L_tc_recycle_frame_loop_5cbc:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cbc
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
	jmp .L_tc_recycle_frame_loop_5cbc
.L_tc_recycle_frame_done_5cbc:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c86:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f48:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_88], rax
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
.L_lambda_simple_env_loop_4f4a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f4a
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f4a
.L_lambda_simple_env_end_4f4a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f4a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f4a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f4a
.L_lambda_simple_params_end_4f4a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f4a
	jmp .L_lambda_simple_end_4f4a
.L_lambda_simple_code_4f4a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f4a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f4a:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f4b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f4b
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f4b
.L_lambda_simple_env_end_4f4b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f4b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f4b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f4b
.L_lambda_simple_params_end_4f4b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f4b
	jmp .L_lambda_simple_end_4f4b
.L_lambda_simple_code_4f4b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f4b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f4b:
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
	je .L_if_else_5680
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
.L_tc_recycle_frame_loop_5cbd:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cbd
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
	jmp .L_tc_recycle_frame_loop_5cbd
.L_tc_recycle_frame_done_5cbd:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5680
	.L_if_else_5680:
	mov rax, PARAM(0)
	.L_if_end_5680:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f4b:	; new closure is in rax
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
.L_lambda_opt_env_loop_0c87:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c87
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c87
.L_lambda_opt_env_end_0c87:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c87:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c87
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c87
.L_lambda_opt_params_end_0c87:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c87
	jmp .L_lambda_opt_end_0c87
.L_lambda_opt_code_0c87:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c87
.L_lambda_opt_arity_check_exact_0c87:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c87:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c87
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c87
.L_lambda_opt_stack_enlarge_loop_exit_0c87:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c87
.L_lambda_opt_arity_check_more_0c87:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c87:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c87
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
	jmp .L_lambda_opt_list_create_loop_0c87
.L_lambda_opt_list_create_loop_exit_0c87:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c87:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c87
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
	jmp .L_lambda_opt_stack_shrink_loop_0c87
.L_lambda_opt_stack_shrink_loop_exit_0c87:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c87:
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
.L_tc_recycle_frame_loop_5cbe:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cbe
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
	jmp .L_tc_recycle_frame_loop_5cbe
.L_tc_recycle_frame_done_5cbe:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c87:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f4a:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_89], rax
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
.L_lambda_opt_env_loop_0c88:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0c88
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c88
.L_lambda_opt_env_end_0c88:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c88:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0c88
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c88
.L_lambda_opt_params_end_0c88:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c88
	jmp .L_lambda_opt_end_0c88
.L_lambda_opt_code_0c88:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c88
.L_lambda_opt_arity_check_exact_0c88:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c88:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c88
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c88
.L_lambda_opt_stack_enlarge_loop_exit_0c88:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c88
.L_lambda_opt_arity_check_more_0c88:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c88:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c88
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
	jmp .L_lambda_opt_list_create_loop_0c88
.L_lambda_opt_list_create_loop_exit_0c88:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c88:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c88
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
	jmp .L_lambda_opt_stack_shrink_loop_0c88
.L_lambda_opt_stack_shrink_loop_exit_0c88:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c88:
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
.L_lambda_simple_env_loop_4f4c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f4c
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f4c
.L_lambda_simple_env_end_4f4c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f4c:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f4c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f4c
.L_lambda_simple_params_end_4f4c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f4c
	jmp .L_lambda_simple_end_4f4c
.L_lambda_simple_code_4f4c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f4c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f4c:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f4d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f4d
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f4d
.L_lambda_simple_env_end_4f4d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f4d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f4d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f4d
.L_lambda_simple_params_end_4f4d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f4d
	jmp .L_lambda_simple_end_4f4d
.L_lambda_simple_code_4f4d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f4d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f4d:
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
	je .L_if_else_5681
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
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
	mov rax, qword [free_var_89]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	jne .L_or_end_0615
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
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
.L_tc_recycle_frame_loop_5cc0:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cc0
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
	jmp .L_tc_recycle_frame_loop_5cc0
.L_tc_recycle_frame_done_5cc0:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
.L_or_end_0615:
	jmp .L_if_end_5681
	.L_if_else_5681:
	lea rax, [2 + L_constants]
	.L_if_end_5681:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f4d:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cc1:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cc1
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
	jmp .L_tc_recycle_frame_loop_5cc1
.L_tc_recycle_frame_done_5cc1:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f4c:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cbf:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cbf
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
	jmp .L_tc_recycle_frame_loop_5cbf
.L_tc_recycle_frame_done_5cbf:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c88:	; new closure is in rax
	mov qword [free_var_90], rax
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
.L_lambda_opt_env_loop_0c89:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0c89
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c89
.L_lambda_opt_env_end_0c89:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c89:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0c89
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c89
.L_lambda_opt_params_end_0c89:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c89
	jmp .L_lambda_opt_end_0c89
.L_lambda_opt_code_0c89:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c89
.L_lambda_opt_arity_check_exact_0c89:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c89:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c89
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c89
.L_lambda_opt_stack_enlarge_loop_exit_0c89:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c89
.L_lambda_opt_arity_check_more_0c89:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c89:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c89
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
	jmp .L_lambda_opt_list_create_loop_0c89
.L_lambda_opt_list_create_loop_exit_0c89:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c89:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c89
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
	jmp .L_lambda_opt_stack_shrink_loop_0c89
.L_lambda_opt_stack_shrink_loop_exit_0c89:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c89:
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
.L_lambda_simple_env_loop_4f4e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f4e
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f4e
.L_lambda_simple_env_end_4f4e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f4e:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f4e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f4e
.L_lambda_simple_params_end_4f4e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f4e
	jmp .L_lambda_simple_end_4f4e
.L_lambda_simple_code_4f4e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f4e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f4e:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f4f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f4f
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f4f
.L_lambda_simple_env_end_4f4f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f4f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f4f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f4f
.L_lambda_simple_params_end_4f4f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f4f
	jmp .L_lambda_simple_end_4f4f
.L_lambda_simple_code_4f4f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f4f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f4f:
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
	jne .L_or_end_0616
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
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
	mov rax, qword [free_var_89]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_5682
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
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
.L_tc_recycle_frame_loop_5cc3:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cc3
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
	jmp .L_tc_recycle_frame_loop_5cc3
.L_tc_recycle_frame_done_5cc3:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5682
	.L_if_else_5682:
	lea rax, [2 + L_constants]
	.L_if_end_5682:
.L_or_end_0616:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f4f:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cc4:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cc4
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
	jmp .L_tc_recycle_frame_loop_5cc4
.L_tc_recycle_frame_done_5cc4:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f4e:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cc2:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cc2
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
	jmp .L_tc_recycle_frame_loop_5cc2
.L_tc_recycle_frame_done_5cc2:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c89:	; new closure is in rax
	mov qword [free_var_92], rax
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
.L_lambda_simple_env_loop_4f50:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f50
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f50
.L_lambda_simple_env_end_4f50:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f50:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f50
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f50
.L_lambda_simple_params_end_4f50:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f50
	jmp .L_lambda_simple_end_4f50
.L_lambda_simple_code_4f50:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f50
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f50:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f51:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f51
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f51
.L_lambda_simple_env_end_4f51:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f51:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f51
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f51
.L_lambda_simple_params_end_4f51:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f51
	jmp .L_lambda_simple_end_4f51
.L_lambda_simple_code_4f51:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f51
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f51:
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
	je .L_if_else_5683
	lea rax, [1 + L_constants]
	jmp .L_if_end_5683
	.L_if_else_5683:
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
.L_tc_recycle_frame_loop_5cc5:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cc5
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
	jmp .L_tc_recycle_frame_loop_5cc5
.L_tc_recycle_frame_done_5cc5:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5683:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f51:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f52:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f52
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f52
.L_lambda_simple_env_end_4f52:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f52:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f52
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f52
.L_lambda_simple_params_end_4f52:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f52
	jmp .L_lambda_simple_end_4f52
.L_lambda_simple_code_4f52:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f52
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f52:
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
	je .L_if_else_5684
	lea rax, [1 + L_constants]
	jmp .L_if_end_5684
	.L_if_else_5684:
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
	mov rax, qword [free_var_89]
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
.L_tc_recycle_frame_loop_5cc6:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cc6
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
	jmp .L_tc_recycle_frame_loop_5cc6
.L_tc_recycle_frame_done_5cc6:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5684:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f52:	; new closure is in rax
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
.L_lambda_opt_env_loop_0c8a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c8a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c8a
.L_lambda_opt_env_end_0c8a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c8a:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_0c8a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c8a
.L_lambda_opt_params_end_0c8a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c8a
	jmp .L_lambda_opt_end_0c8a
.L_lambda_opt_code_0c8a:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c8a
.L_lambda_opt_arity_check_exact_0c8a:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c8a:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c8a
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c8a
.L_lambda_opt_stack_enlarge_loop_exit_0c8a:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c8a
.L_lambda_opt_arity_check_more_0c8a:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c8a:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c8a
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
	jmp .L_lambda_opt_list_create_loop_0c8a
.L_lambda_opt_list_create_loop_exit_0c8a:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c8a:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c8a
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
	jmp .L_lambda_opt_stack_shrink_loop_0c8a
.L_lambda_opt_stack_shrink_loop_exit_0c8a:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c8a:
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
	je .L_if_else_5685
	lea rax, [1 + L_constants]
	jmp .L_if_end_5685
	.L_if_else_5685:
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
.L_tc_recycle_frame_loop_5cc7:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cc7
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
	jmp .L_tc_recycle_frame_loop_5cc7
.L_tc_recycle_frame_done_5cc7:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5685:
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c8a:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f50:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_91], rax
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
.L_lambda_simple_env_loop_4f53:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f53
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f53
.L_lambda_simple_env_end_4f53:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f53:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f53
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f53
.L_lambda_simple_params_end_4f53:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f53
	jmp .L_lambda_simple_end_4f53
.L_lambda_simple_code_4f53:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f53
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f53:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f54:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f54
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f54
.L_lambda_simple_env_end_4f54:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f54:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f54
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f54
.L_lambda_simple_params_end_4f54:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f54
	jmp .L_lambda_simple_end_4f54
.L_lambda_simple_code_4f54:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f54
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f54:
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
	je .L_if_else_5686
	mov rax, PARAM(1)
	jmp .L_if_end_5686
	.L_if_else_5686:
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
.L_tc_recycle_frame_loop_5cc8:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cc8
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
	jmp .L_tc_recycle_frame_loop_5cc8
.L_tc_recycle_frame_done_5cc8:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5686:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f54:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f55:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f55
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f55
.L_lambda_simple_env_end_4f55:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f55:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f55
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f55
.L_lambda_simple_params_end_4f55:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f55
	jmp .L_lambda_simple_end_4f55
.L_lambda_simple_code_4f55:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f55
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f55:
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
.L_tc_recycle_frame_loop_5cc9:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cc9
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
	jmp .L_tc_recycle_frame_loop_5cc9
.L_tc_recycle_frame_done_5cc9:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f55:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f53:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_93], rax
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
.L_lambda_simple_env_loop_4f56:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f56
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f56
.L_lambda_simple_env_end_4f56:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f56:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f56
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f56
.L_lambda_simple_params_end_4f56:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f56
	jmp .L_lambda_simple_end_4f56
.L_lambda_simple_code_4f56:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f56
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f56:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f57:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f57
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f57
.L_lambda_simple_env_end_4f57:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f57:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f57
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f57
.L_lambda_simple_params_end_4f57:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f57
	jmp .L_lambda_simple_end_4f57
.L_lambda_simple_code_4f57:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f57
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f57:
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
	je .L_if_else_5687
	mov rax, PARAM(0)
	jmp .L_if_end_5687
	.L_if_else_5687:
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
.L_tc_recycle_frame_loop_5cca:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cca
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
	jmp .L_tc_recycle_frame_loop_5cca
.L_tc_recycle_frame_done_5cca:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5687:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f57:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f58:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f58
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f58
.L_lambda_simple_env_end_4f58:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f58:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f58
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f58
.L_lambda_simple_params_end_4f58:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f58
	jmp .L_lambda_simple_end_4f58
.L_lambda_simple_code_4f58:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f58
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f58:
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
	je .L_if_else_5688
	mov rax, PARAM(1)
	jmp .L_if_end_5688
	.L_if_else_5688:
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
.L_tc_recycle_frame_loop_5ccb:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ccb
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
	jmp .L_tc_recycle_frame_loop_5ccb
.L_tc_recycle_frame_done_5ccb:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5688:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f58:	; new closure is in rax
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
.L_lambda_opt_env_loop_0c8b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c8b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c8b
.L_lambda_opt_env_end_0c8b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c8b:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_0c8b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c8b
.L_lambda_opt_params_end_0c8b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c8b
	jmp .L_lambda_opt_end_0c8b
.L_lambda_opt_code_0c8b:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c8b
.L_lambda_opt_arity_check_exact_0c8b:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c8b:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_0c8b
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c8b
.L_lambda_opt_stack_enlarge_loop_exit_0c8b:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_0c8b
.L_lambda_opt_arity_check_more_0c8b:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c8b:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c8b
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
	jmp .L_lambda_opt_list_create_loop_0c8b
.L_lambda_opt_list_create_loop_exit_0c8b:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c8b:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_0c8b
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
	jmp .L_lambda_opt_stack_shrink_loop_0c8b
.L_lambda_opt_stack_shrink_loop_exit_0c8b:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_0c8b:
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
	je .L_if_else_5689
	lea rax, [1 + L_constants]
	jmp .L_if_end_5689
	.L_if_else_5689:
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
.L_tc_recycle_frame_loop_5ccc:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ccc
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
	jmp .L_tc_recycle_frame_loop_5ccc
.L_tc_recycle_frame_done_5ccc:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5689:
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_0c8b:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f56:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_94], rax
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
.L_lambda_simple_env_loop_4f59:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f59
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f59
.L_lambda_simple_env_end_4f59:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f59:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f59
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f59
.L_lambda_simple_params_end_4f59:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f59
	jmp .L_lambda_simple_end_4f59
.L_lambda_simple_code_4f59:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f59
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f59:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f5a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f5a
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f5a
.L_lambda_simple_env_end_4f5a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f5a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f5a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f5a
.L_lambda_simple_params_end_4f5a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f5a
	jmp .L_lambda_simple_end_4f5a
.L_lambda_simple_code_4f5a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_4f5a
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f5a:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_568a
	mov rax, PARAM(1)
	jmp .L_if_end_568a
	.L_if_else_568a:
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
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
	mov rax, qword [free_var_91]
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
	mov rax, qword [free_var_89]
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
.L_tc_recycle_frame_loop_5ccd:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_5ccd
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
	jmp .L_tc_recycle_frame_loop_5ccd
.L_tc_recycle_frame_done_5ccd:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_568a:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_4f5a:	; new closure is in rax
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
.L_lambda_opt_env_loop_0c8c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c8c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c8c
.L_lambda_opt_env_end_0c8c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c8c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c8c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c8c
.L_lambda_opt_params_end_0c8c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c8c
	jmp .L_lambda_opt_end_0c8c
.L_lambda_opt_code_0c8c:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 2 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c8c
.L_lambda_opt_arity_check_exact_0c8c:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c8c:	 ; stack loop enlarge start
	cmp rsi, 5
	je .L_lambda_opt_stack_enlarge_loop_exit_0c8c
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c8c
.L_lambda_opt_stack_enlarge_loop_exit_0c8c:	 ; end of stack enlarge loop
	mov qword [rsp + 5*8], sob_nil
	mov qword [rsp + 2*8], 3
	jmp .L_lambda_opt_stack_adjusted_0c8c
.L_lambda_opt_arity_check_more_0c8c:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c8c:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c8c
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
	jmp .L_lambda_opt_list_create_loop_0c8c
.L_lambda_opt_list_create_loop_exit_0c8c:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c8c:	; start of stack shrink loop
	cmp rsi, 5
	je .L_lambda_opt_stack_shrink_loop_exit_0c8c
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
	jmp .L_lambda_opt_stack_shrink_loop_0c8c
.L_lambda_opt_stack_shrink_loop_exit_0c8c:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 3
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 3
.L_lambda_opt_stack_adjusted_0c8c:
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
.L_tc_recycle_frame_loop_5cce:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_5cce
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
	jmp .L_tc_recycle_frame_loop_5cce
.L_tc_recycle_frame_done_5cce:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(3)
.L_lambda_opt_end_0c8c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f59:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_95], rax
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
.L_lambda_simple_env_loop_4f5b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f5b
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f5b
.L_lambda_simple_env_end_4f5b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f5b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f5b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f5b
.L_lambda_simple_params_end_4f5b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f5b
	jmp .L_lambda_simple_end_4f5b
.L_lambda_simple_code_4f5b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f5b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f5b:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f5c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f5c
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f5c
.L_lambda_simple_env_end_4f5c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f5c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f5c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f5c
.L_lambda_simple_params_end_4f5c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f5c
	jmp .L_lambda_simple_end_4f5c
.L_lambda_simple_code_4f5c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_4f5c
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f5c:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_568b
	mov rax, PARAM(1)
	jmp .L_if_end_568b
	.L_if_else_568b:
	lea rax, [1 + L_constants]
	push rax
	mov rax, PARAM(2)
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
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
	mov rax, qword [free_var_91]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_94]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_89]
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
.L_tc_recycle_frame_loop_5ccf:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ccf
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
	jmp .L_tc_recycle_frame_loop_5ccf
.L_tc_recycle_frame_done_5ccf:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_568b:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_4f5c:	; new closure is in rax
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
.L_lambda_opt_env_loop_0c8d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c8d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c8d
.L_lambda_opt_env_end_0c8d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c8d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c8d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c8d
.L_lambda_opt_params_end_0c8d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c8d
	jmp .L_lambda_opt_end_0c8d
.L_lambda_opt_code_0c8d:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 2 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c8d
.L_lambda_opt_arity_check_exact_0c8d:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c8d:	 ; stack loop enlarge start
	cmp rsi, 5
	je .L_lambda_opt_stack_enlarge_loop_exit_0c8d
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c8d
.L_lambda_opt_stack_enlarge_loop_exit_0c8d:	 ; end of stack enlarge loop
	mov qword [rsp + 5*8], sob_nil
	mov qword [rsp + 2*8], 3
	jmp .L_lambda_opt_stack_adjusted_0c8d
.L_lambda_opt_arity_check_more_0c8d:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c8d:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c8d
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
	jmp .L_lambda_opt_list_create_loop_0c8d
.L_lambda_opt_list_create_loop_exit_0c8d:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c8d:	; start of stack shrink loop
	cmp rsi, 5
	je .L_lambda_opt_stack_shrink_loop_exit_0c8d
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
	jmp .L_lambda_opt_stack_shrink_loop_0c8d
.L_lambda_opt_stack_shrink_loop_exit_0c8d:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 3
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 3
.L_lambda_opt_stack_adjusted_0c8d:
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
.L_tc_recycle_frame_loop_5cd0:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_5cd0
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
	jmp .L_tc_recycle_frame_loop_5cd0
.L_tc_recycle_frame_done_5cd0:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(3)
.L_lambda_opt_end_0c8d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f5b:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_96], rax
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
.L_lambda_simple_env_loop_4f5d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f5d
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f5d
.L_lambda_simple_env_end_4f5d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f5d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f5d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f5d
.L_lambda_simple_params_end_4f5d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f5d
	jmp .L_lambda_simple_end_4f5d
.L_lambda_simple_code_4f5d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_4f5d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f5d:
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
.L_tc_recycle_frame_loop_5cd1:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cd1
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
	jmp .L_tc_recycle_frame_loop_5cd1
.L_tc_recycle_frame_done_5cd1:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_4f5d:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f5e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f5e
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f5e
.L_lambda_simple_env_end_4f5e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f5e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f5e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f5e
.L_lambda_simple_params_end_4f5e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f5e
	jmp .L_lambda_simple_end_4f5e
.L_lambda_simple_code_4f5e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f5e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f5e:
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
.L_lambda_simple_env_loop_4f5f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f5f
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f5f
.L_lambda_simple_env_end_4f5f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f5f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f5f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f5f
.L_lambda_simple_params_end_4f5f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f5f
	jmp .L_lambda_simple_end_4f5f
.L_lambda_simple_code_4f5f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f5f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f5f:
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
	je .L_if_else_568c
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
	je .L_if_else_568d
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
.L_tc_recycle_frame_loop_5cd3:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cd3
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
	jmp .L_tc_recycle_frame_loop_5cd3
.L_tc_recycle_frame_done_5cd3:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_568d
	.L_if_else_568d:
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
	je .L_if_else_568e
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
.L_tc_recycle_frame_loop_5cd4:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cd4
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
	jmp .L_tc_recycle_frame_loop_5cd4
.L_tc_recycle_frame_done_5cd4:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_568e
	.L_if_else_568e:
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
.L_tc_recycle_frame_loop_5cd5:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cd5
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
	jmp .L_tc_recycle_frame_loop_5cd5
.L_tc_recycle_frame_done_5cd5:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_568e:
	.L_if_end_568d:
	jmp .L_if_end_568c
	.L_if_else_568c:
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
	je .L_if_else_568f
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
	je .L_if_else_5690
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
.L_tc_recycle_frame_loop_5cd6:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cd6
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
	jmp .L_tc_recycle_frame_loop_5cd6
.L_tc_recycle_frame_done_5cd6:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5690
	.L_if_else_5690:
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
	je .L_if_else_5691
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
.L_tc_recycle_frame_loop_5cd7:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cd7
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
	jmp .L_tc_recycle_frame_loop_5cd7
.L_tc_recycle_frame_done_5cd7:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5691
	.L_if_else_5691:
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
.L_tc_recycle_frame_loop_5cd8:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cd8
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
	jmp .L_tc_recycle_frame_loop_5cd8
.L_tc_recycle_frame_done_5cd8:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5691:
	.L_if_end_5690:
	jmp .L_if_end_568f
	.L_if_else_568f:
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
.L_tc_recycle_frame_loop_5cd9:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cd9
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
	jmp .L_tc_recycle_frame_loop_5cd9
.L_tc_recycle_frame_done_5cd9:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_568f:
	.L_if_end_568c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f5f:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f60:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f60
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f60
.L_lambda_simple_env_end_4f60:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f60:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f60
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f60
.L_lambda_simple_params_end_4f60:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f60
	jmp .L_lambda_simple_end_4f60
.L_lambda_simple_code_4f60:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f60
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f60:
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
.L_lambda_opt_env_loop_0c8e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0c8e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c8e
.L_lambda_opt_env_end_0c8e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c8e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c8e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c8e
.L_lambda_opt_params_end_0c8e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c8e
	jmp .L_lambda_opt_end_0c8e
.L_lambda_opt_code_0c8e:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c8e
.L_lambda_opt_arity_check_exact_0c8e:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c8e:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_0c8e
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c8e
.L_lambda_opt_stack_enlarge_loop_exit_0c8e:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_0c8e
.L_lambda_opt_arity_check_more_0c8e:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c8e:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c8e
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
	jmp .L_lambda_opt_list_create_loop_0c8e
.L_lambda_opt_list_create_loop_exit_0c8e:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c8e:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_0c8e
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
	jmp .L_lambda_opt_stack_shrink_loop_0c8e
.L_lambda_opt_stack_shrink_loop_exit_0c8e:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_0c8e:
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
	mov rax, qword [free_var_95]
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
.L_tc_recycle_frame_loop_5cda:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_5cda
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
	jmp .L_tc_recycle_frame_loop_5cda
.L_tc_recycle_frame_done_5cda:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_0c8e:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f60:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cd2:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cd2
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
	jmp .L_tc_recycle_frame_loop_5cd2
.L_tc_recycle_frame_done_5cd2:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f5e:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_97], rax
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
.L_lambda_simple_env_loop_4f61:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f61
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f61
.L_lambda_simple_env_end_4f61:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f61:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f61
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f61
.L_lambda_simple_params_end_4f61:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f61
	jmp .L_lambda_simple_end_4f61
.L_lambda_simple_code_4f61:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_4f61
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f61:
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
.L_tc_recycle_frame_loop_5cdb:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cdb
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
	jmp .L_tc_recycle_frame_loop_5cdb
.L_tc_recycle_frame_done_5cdb:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_4f61:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f62:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f62
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f62
.L_lambda_simple_env_end_4f62:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f62:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f62
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f62
.L_lambda_simple_params_end_4f62:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f62
	jmp .L_lambda_simple_end_4f62
.L_lambda_simple_code_4f62:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f62
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f62:
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
.L_lambda_simple_env_loop_4f63:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f63
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f63
.L_lambda_simple_env_end_4f63:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f63:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f63
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f63
.L_lambda_simple_params_end_4f63:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f63
	jmp .L_lambda_simple_end_4f63
.L_lambda_simple_code_4f63:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f63
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f63:
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
	je .L_if_else_5692
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
	je .L_if_else_5693
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
.L_tc_recycle_frame_loop_5cdd:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cdd
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
	jmp .L_tc_recycle_frame_loop_5cdd
.L_tc_recycle_frame_done_5cdd:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5693
	.L_if_else_5693:
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
	je .L_if_else_5694
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
.L_tc_recycle_frame_loop_5cde:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cde
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
	jmp .L_tc_recycle_frame_loop_5cde
.L_tc_recycle_frame_done_5cde:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5694
	.L_if_else_5694:
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
.L_tc_recycle_frame_loop_5cdf:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cdf
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
	jmp .L_tc_recycle_frame_loop_5cdf
.L_tc_recycle_frame_done_5cdf:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5694:
	.L_if_end_5693:
	jmp .L_if_end_5692
	.L_if_else_5692:
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
	je .L_if_else_5695
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
	je .L_if_else_5696
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
.L_tc_recycle_frame_loop_5ce0:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ce0
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
	jmp .L_tc_recycle_frame_loop_5ce0
.L_tc_recycle_frame_done_5ce0:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5696
	.L_if_else_5696:
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
	je .L_if_else_5697
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
.L_tc_recycle_frame_loop_5ce1:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ce1
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
	jmp .L_tc_recycle_frame_loop_5ce1
.L_tc_recycle_frame_done_5ce1:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5697
	.L_if_else_5697:
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
.L_tc_recycle_frame_loop_5ce2:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5ce2
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
	jmp .L_tc_recycle_frame_loop_5ce2
.L_tc_recycle_frame_done_5ce2:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5697:
	.L_if_end_5696:
	jmp .L_if_end_5695
	.L_if_else_5695:
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
.L_tc_recycle_frame_loop_5ce3:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5ce3
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
	jmp .L_tc_recycle_frame_loop_5ce3
.L_tc_recycle_frame_done_5ce3:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5695:
	.L_if_end_5692:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f63:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f64:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f64
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f64
.L_lambda_simple_env_end_4f64:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f64:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f64
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f64
.L_lambda_simple_params_end_4f64:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f64
	jmp .L_lambda_simple_end_4f64
.L_lambda_simple_code_4f64:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f64
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f64:
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
.L_lambda_opt_env_loop_0c8f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0c8f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c8f
.L_lambda_opt_env_end_0c8f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c8f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c8f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c8f
.L_lambda_opt_params_end_0c8f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c8f
	jmp .L_lambda_opt_end_0c8f
.L_lambda_opt_code_0c8f:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c8f
.L_lambda_opt_arity_check_exact_0c8f:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c8f:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c8f
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c8f
.L_lambda_opt_stack_enlarge_loop_exit_0c8f:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c8f
.L_lambda_opt_arity_check_more_0c8f:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c8f:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c8f
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
	jmp .L_lambda_opt_list_create_loop_0c8f
.L_lambda_opt_list_create_loop_exit_0c8f:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c8f:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c8f
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
	jmp .L_lambda_opt_stack_shrink_loop_0c8f
.L_lambda_opt_stack_shrink_loop_exit_0c8f:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c8f:
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
	je .L_if_else_5698
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
.L_tc_recycle_frame_loop_5ce4:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ce4
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
	jmp .L_tc_recycle_frame_loop_5ce4
.L_tc_recycle_frame_done_5ce4:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_5698
	.L_if_else_5698:
	mov rax, PARAM(1)
	push rax
	lea rax, [32 + L_constants]
	push rax
	mov rax, qword [free_var_97]
	push rax
	push 3
	mov rax, qword [free_var_95]
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
.L_lambda_simple_env_loop_4f65:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4f65
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f65
.L_lambda_simple_env_end_4f65:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f65:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f65
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f65
.L_lambda_simple_params_end_4f65:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f65
	jmp .L_lambda_simple_end_4f65
.L_lambda_simple_code_4f65:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f65
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f65:
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
.L_tc_recycle_frame_loop_5ce6:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ce6
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
	jmp .L_tc_recycle_frame_loop_5ce6
.L_tc_recycle_frame_done_5ce6:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f65:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5ce5:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ce5
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
	jmp .L_tc_recycle_frame_loop_5ce5
.L_tc_recycle_frame_done_5ce5:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_5698:
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c8f:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f64:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cdc:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cdc
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
	jmp .L_tc_recycle_frame_loop_5cdc
.L_tc_recycle_frame_done_5cdc:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f62:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_98], rax
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
.L_lambda_simple_env_loop_4f66:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f66
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f66
.L_lambda_simple_env_end_4f66:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f66:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f66
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f66
.L_lambda_simple_params_end_4f66:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f66
	jmp .L_lambda_simple_end_4f66
.L_lambda_simple_code_4f66:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_4f66
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f66:
	enter 0, 0
	lea rax, [68 + L_constants]
	push rax
	lea rax, [155 + L_constants]
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
.L_tc_recycle_frame_loop_5ce7:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ce7
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
	jmp .L_tc_recycle_frame_loop_5ce7
.L_tc_recycle_frame_done_5ce7:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_4f66:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f67:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f67
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f67
.L_lambda_simple_env_end_4f67:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f67:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f67
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f67
.L_lambda_simple_params_end_4f67:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f67
	jmp .L_lambda_simple_end_4f67
.L_lambda_simple_code_4f67:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f67
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f67:
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
.L_lambda_simple_env_loop_4f68:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f68
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f68
.L_lambda_simple_env_end_4f68:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f68:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f68
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f68
.L_lambda_simple_params_end_4f68:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f68
	jmp .L_lambda_simple_end_4f68
.L_lambda_simple_code_4f68:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f68
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f68:
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
	je .L_if_else_5699
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
	je .L_if_else_569a
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_36]
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
.L_tc_recycle_frame_loop_5ce9:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ce9
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
	jmp .L_tc_recycle_frame_loop_5ce9
.L_tc_recycle_frame_done_5ce9:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_569a
	.L_if_else_569a:
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
	je .L_if_else_569b
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
	mov rax, qword [free_var_32]
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
.L_tc_recycle_frame_loop_5cea:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cea
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
	jmp .L_tc_recycle_frame_loop_5cea
.L_tc_recycle_frame_done_5cea:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_569b
	.L_if_else_569b:
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
.L_tc_recycle_frame_loop_5ceb:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5ceb
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
	jmp .L_tc_recycle_frame_loop_5ceb
.L_tc_recycle_frame_done_5ceb:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_569b:
	.L_if_end_569a:
	jmp .L_if_end_5699
	.L_if_else_5699:
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
	je .L_if_else_569c
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
	je .L_if_else_569d
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
	mov rax, qword [free_var_32]
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
.L_tc_recycle_frame_loop_5cec:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cec
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
	jmp .L_tc_recycle_frame_loop_5cec
.L_tc_recycle_frame_done_5cec:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_569d
	.L_if_else_569d:
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
	je .L_if_else_569e
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_32]
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
.L_tc_recycle_frame_loop_5ced:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5ced
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
	jmp .L_tc_recycle_frame_loop_5ced
.L_tc_recycle_frame_done_5ced:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_569e
	.L_if_else_569e:
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
.L_tc_recycle_frame_loop_5cee:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cee
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
	jmp .L_tc_recycle_frame_loop_5cee
.L_tc_recycle_frame_done_5cee:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_569e:
	.L_if_end_569d:
	jmp .L_if_end_569c
	.L_if_else_569c:
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
.L_tc_recycle_frame_loop_5cef:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cef
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
	jmp .L_tc_recycle_frame_loop_5cef
.L_tc_recycle_frame_done_5cef:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_569c:
	.L_if_end_5699:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f68:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f69:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f69
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f69
.L_lambda_simple_env_end_4f69:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f69:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f69
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f69
.L_lambda_simple_params_end_4f69:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f69
	jmp .L_lambda_simple_end_4f69
.L_lambda_simple_code_4f69:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f69
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f69:
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
.L_lambda_opt_env_loop_0c90:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0c90
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c90
.L_lambda_opt_env_end_0c90:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c90:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c90
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c90
.L_lambda_opt_params_end_0c90:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c90
	jmp .L_lambda_opt_end_0c90
.L_lambda_opt_code_0c90:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c90
.L_lambda_opt_arity_check_exact_0c90:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c90:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_0c90
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c90
.L_lambda_opt_stack_enlarge_loop_exit_0c90:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_0c90
.L_lambda_opt_arity_check_more_0c90:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c90:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c90
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
	jmp .L_lambda_opt_list_create_loop_0c90
.L_lambda_opt_list_create_loop_exit_0c90:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c90:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_0c90
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
	jmp .L_lambda_opt_stack_shrink_loop_0c90
.L_lambda_opt_stack_shrink_loop_exit_0c90:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_0c90:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 3
	mov rax, qword [free_var_95]
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
.L_tc_recycle_frame_loop_5cf0:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_5cf0
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
	jmp .L_tc_recycle_frame_loop_5cf0
.L_tc_recycle_frame_done_5cf0:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_0c90:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f69:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5ce8:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5ce8
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
	jmp .L_tc_recycle_frame_loop_5ce8
.L_tc_recycle_frame_done_5ce8:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f67:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_99], rax
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
.L_lambda_simple_env_loop_4f6a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f6a
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f6a
.L_lambda_simple_env_end_4f6a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f6a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f6a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f6a
.L_lambda_simple_params_end_4f6a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f6a
	jmp .L_lambda_simple_end_4f6a
.L_lambda_simple_code_4f6a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_4f6a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f6a:
	enter 0, 0
	lea rax, [68 + L_constants]
	push rax
	lea rax, [174 + L_constants]
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
.L_tc_recycle_frame_loop_5cf1:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cf1
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
	jmp .L_tc_recycle_frame_loop_5cf1
.L_tc_recycle_frame_done_5cf1:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_4f6a:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f6b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f6b
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f6b
.L_lambda_simple_env_end_4f6b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f6b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f6b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f6b
.L_lambda_simple_params_end_4f6b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f6b
	jmp .L_lambda_simple_end_4f6b
.L_lambda_simple_code_4f6b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f6b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f6b:
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
.L_lambda_simple_env_loop_4f6c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f6c
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f6c
.L_lambda_simple_env_end_4f6c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f6c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f6c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f6c
.L_lambda_simple_params_end_4f6c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f6c
	jmp .L_lambda_simple_end_4f6c
.L_lambda_simple_code_4f6c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f6c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f6c:
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
	je .L_if_else_569f
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
	je .L_if_else_56a0
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_37]
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
.L_tc_recycle_frame_loop_5cf3:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cf3
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
	jmp .L_tc_recycle_frame_loop_5cf3
.L_tc_recycle_frame_done_5cf3:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56a0
	.L_if_else_56a0:
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
	je .L_if_else_56a1
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
	mov rax, qword [free_var_33]
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
.L_tc_recycle_frame_loop_5cf4:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cf4
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
	jmp .L_tc_recycle_frame_loop_5cf4
.L_tc_recycle_frame_done_5cf4:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56a1
	.L_if_else_56a1:
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
.L_tc_recycle_frame_loop_5cf5:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cf5
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
	jmp .L_tc_recycle_frame_loop_5cf5
.L_tc_recycle_frame_done_5cf5:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56a1:
	.L_if_end_56a0:
	jmp .L_if_end_569f
	.L_if_else_569f:
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
	je .L_if_else_56a2
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
	je .L_if_else_56a3
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
	mov rax, qword [free_var_33]
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
.L_tc_recycle_frame_loop_5cf6:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cf6
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
	jmp .L_tc_recycle_frame_loop_5cf6
.L_tc_recycle_frame_done_5cf6:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56a3
	.L_if_else_56a3:
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
	je .L_if_else_56a4
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_33]
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
.L_tc_recycle_frame_loop_5cf7:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cf7
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
	jmp .L_tc_recycle_frame_loop_5cf7
.L_tc_recycle_frame_done_5cf7:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56a4
	.L_if_else_56a4:
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
.L_tc_recycle_frame_loop_5cf8:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cf8
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
	jmp .L_tc_recycle_frame_loop_5cf8
.L_tc_recycle_frame_done_5cf8:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56a4:
	.L_if_end_56a3:
	jmp .L_if_end_56a2
	.L_if_else_56a2:
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
.L_tc_recycle_frame_loop_5cf9:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5cf9
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
	jmp .L_tc_recycle_frame_loop_5cf9
.L_tc_recycle_frame_done_5cf9:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56a2:
	.L_if_end_569f:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f6c:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f6d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f6d
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f6d
.L_lambda_simple_env_end_4f6d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f6d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f6d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f6d
.L_lambda_simple_params_end_4f6d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f6d
	jmp .L_lambda_simple_end_4f6d
.L_lambda_simple_code_4f6d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f6d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f6d:
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
.L_lambda_opt_env_loop_0c91:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0c91
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c91
.L_lambda_opt_env_end_0c91:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c91:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c91
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c91
.L_lambda_opt_params_end_0c91:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c91
	jmp .L_lambda_opt_end_0c91
.L_lambda_opt_code_0c91:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c91
.L_lambda_opt_arity_check_exact_0c91:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c91:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c91
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c91
.L_lambda_opt_stack_enlarge_loop_exit_0c91:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c91
.L_lambda_opt_arity_check_more_0c91:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c91:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c91
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
	jmp .L_lambda_opt_list_create_loop_0c91
.L_lambda_opt_list_create_loop_exit_0c91:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c91:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c91
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
	jmp .L_lambda_opt_stack_shrink_loop_0c91
.L_lambda_opt_stack_shrink_loop_exit_0c91:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c91:
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
	je .L_if_else_56a5
	mov rax, PARAM(0)
	push rax
	lea rax, [128 + L_constants]
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
.L_tc_recycle_frame_loop_5cfa:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cfa
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
	jmp .L_tc_recycle_frame_loop_5cfa
.L_tc_recycle_frame_done_5cfa:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56a5
	.L_if_else_56a5:
	mov rax, PARAM(1)
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, qword [free_var_99]
	push rax
	push 3
	mov rax, qword [free_var_95]
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
.L_lambda_simple_env_loop_4f6e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4f6e
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f6e
.L_lambda_simple_env_end_4f6e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f6e:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f6e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f6e
.L_lambda_simple_params_end_4f6e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f6e
	jmp .L_lambda_simple_end_4f6e
.L_lambda_simple_code_4f6e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f6e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f6e:
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
.L_tc_recycle_frame_loop_5cfc:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cfc
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
	jmp .L_tc_recycle_frame_loop_5cfc
.L_tc_recycle_frame_done_5cfc:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f6e:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cfb:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cfb
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
	jmp .L_tc_recycle_frame_loop_5cfb
.L_tc_recycle_frame_done_5cfb:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56a5:
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c91:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f6d:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cf2:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cf2
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
	jmp .L_tc_recycle_frame_loop_5cf2
.L_tc_recycle_frame_done_5cf2:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f6b:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_100], rax
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
.L_lambda_simple_env_loop_4f6f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f6f
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f6f
.L_lambda_simple_env_end_4f6f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f6f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f6f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f6f
.L_lambda_simple_params_end_4f6f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f6f
	jmp .L_lambda_simple_end_4f6f
.L_lambda_simple_code_4f6f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f6f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f6f:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56a6
	lea rax, [128 + L_constants]
	jmp .L_if_end_56a6
	.L_if_else_56a6:
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_101]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_99]
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
.L_tc_recycle_frame_loop_5cfd:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cfd
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
	jmp .L_tc_recycle_frame_loop_5cfd
.L_tc_recycle_frame_done_5cfd:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56a6:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f6f:	; new closure is in rax
	mov qword [free_var_101], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_102], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_103], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_104], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_105], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_106], rax
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
.L_lambda_simple_env_loop_4f70:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f70
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f70
.L_lambda_simple_env_end_4f70:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f70:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f70
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f70
.L_lambda_simple_params_end_4f70:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f70
	jmp .L_lambda_simple_end_4f70
.L_lambda_simple_code_4f70:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_4f70
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f70:
	enter 0, 0
	lea rax, [219 + L_constants]
	push rax
	lea rax, [210 + L_constants]
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
.L_tc_recycle_frame_loop_5cfe:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5cfe
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
	jmp .L_tc_recycle_frame_loop_5cfe
.L_tc_recycle_frame_done_5cfe:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_4f70:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f71:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f71
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f71
.L_lambda_simple_env_end_4f71:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f71:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f71
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f71
.L_lambda_simple_params_end_4f71:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f71
	jmp .L_lambda_simple_end_4f71
.L_lambda_simple_code_4f71:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f71
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f71:
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
.L_lambda_simple_env_loop_4f72:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f72
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f72
.L_lambda_simple_env_end_4f72:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f72:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f72
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f72
.L_lambda_simple_params_end_4f72:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f72
	jmp .L_lambda_simple_end_4f72
.L_lambda_simple_code_4f72:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f72
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f72:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f73:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f73
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f73
.L_lambda_simple_env_end_4f73:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f73:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f73
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f73
.L_lambda_simple_params_end_4f73:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f73
	jmp .L_lambda_simple_end_4f73
.L_lambda_simple_code_4f73:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f73
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f73:
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
	je .L_if_else_56a7
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
	je .L_if_else_56a8
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
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
.L_tc_recycle_frame_loop_5d00:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d00
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
	jmp .L_tc_recycle_frame_loop_5d00
.L_tc_recycle_frame_done_5d00:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56a8
	.L_if_else_56a8:
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
	je .L_if_else_56a9
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
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
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
.L_tc_recycle_frame_loop_5d01:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d01
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
	jmp .L_tc_recycle_frame_loop_5d01
.L_tc_recycle_frame_done_5d01:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56a9
	.L_if_else_56a9:
	push 0
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
.L_tc_recycle_frame_loop_5d02:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5d02
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
	jmp .L_tc_recycle_frame_loop_5d02
.L_tc_recycle_frame_done_5d02:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56a9:
	.L_if_end_56a8:
	jmp .L_if_end_56a7
	.L_if_else_56a7:
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
	je .L_if_else_56aa
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
	je .L_if_else_56ab
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
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
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
.L_tc_recycle_frame_loop_5d03:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d03
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
	jmp .L_tc_recycle_frame_loop_5d03
.L_tc_recycle_frame_done_5d03:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56ab
	.L_if_else_56ab:
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
	je .L_if_else_56ac
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
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
.L_tc_recycle_frame_loop_5d04:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d04
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
	jmp .L_tc_recycle_frame_loop_5d04
.L_tc_recycle_frame_done_5d04:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56ac
	.L_if_else_56ac:
	push 0
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
.L_tc_recycle_frame_loop_5d05:	 ; start recycle frame loop
	cmp rsi, 3
	je .L_tc_recycle_frame_done_5d05
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
	jmp .L_tc_recycle_frame_loop_5d05
.L_tc_recycle_frame_done_5d05:	 ; end recycle frame loop
	mov rbx, 2
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56ac:
	.L_if_end_56ab:
	jmp .L_if_end_56aa
	.L_if_else_56aa:
	lea rax, [0 + L_constants]
	.L_if_end_56aa:
	.L_if_end_56a7:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f73:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f72:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f74:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f74
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f74
.L_lambda_simple_env_end_4f74:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f74:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f74
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f74
.L_lambda_simple_params_end_4f74:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f74
	jmp .L_lambda_simple_end_4f74
.L_lambda_simple_code_4f74:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f74
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f74:
	enter 0, 0
	mov rax, qword [free_var_39]
	push rax
	mov rax, qword [free_var_40]
	push rax
	push 2
	mov rax, PARAM(0)
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
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f75:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f75
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f75
.L_lambda_simple_env_end_4f75:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f75:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f75
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f75
.L_lambda_simple_params_end_4f75:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f75
	jmp .L_lambda_simple_end_4f75
.L_lambda_simple_code_4f75:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f75
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f75:
	enter 0, 0
	mov rax, qword [free_var_41]
	push rax
	mov rax, qword [free_var_42]
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
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
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f76:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4f76
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f76
.L_lambda_simple_env_end_4f76:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f76:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f76
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f76
.L_lambda_simple_params_end_4f76:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f76
	jmp .L_lambda_simple_end_4f76
.L_lambda_simple_code_4f76:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f76
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f76:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f77:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_4f77
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f77
.L_lambda_simple_env_end_4f77:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f77:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f77
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f77
.L_lambda_simple_params_end_4f77:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f77
	jmp .L_lambda_simple_end_4f77
.L_lambda_simple_code_4f77:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f77
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f77:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_86]
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
.L_tc_recycle_frame_loop_5d09:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d09
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
	jmp .L_tc_recycle_frame_loop_5d09
.L_tc_recycle_frame_done_5d09:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f77:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f78:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_4f78
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f78
.L_lambda_simple_env_end_4f78:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f78:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f78
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f78
.L_lambda_simple_params_end_4f78:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f78
	jmp .L_lambda_simple_end_4f78
.L_lambda_simple_code_4f78:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f78
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f78:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f79:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_4f79
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f79
.L_lambda_simple_env_end_4f79:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f79:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f79
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f79
.L_lambda_simple_params_end_4f79:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f79
	jmp .L_lambda_simple_end_4f79
.L_lambda_simple_code_4f79:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f79
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f79:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*2]
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
.L_tc_recycle_frame_loop_5d0b:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d0b
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
	jmp .L_tc_recycle_frame_loop_5d0b
.L_tc_recycle_frame_done_5d0b:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f79:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f7a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_4f7a
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f7a
.L_lambda_simple_env_end_4f7a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f7a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f7a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f7a
.L_lambda_simple_params_end_4f7a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f7a
	jmp .L_lambda_simple_end_4f7a
.L_lambda_simple_code_4f7a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f7a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f7a:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f7b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_4f7b
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f7b
.L_lambda_simple_env_end_4f7b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f7b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f7b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f7b
.L_lambda_simple_params_end_4f7b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f7b
	jmp .L_lambda_simple_end_4f7b
.L_lambda_simple_code_4f7b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f7b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f7b:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_86]
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
.L_tc_recycle_frame_loop_5d0d:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d0d
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
	jmp .L_tc_recycle_frame_loop_5d0d
.L_tc_recycle_frame_done_5d0d:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f7b:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f7c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_4f7c
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f7c
.L_lambda_simple_env_end_4f7c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f7c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f7c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f7c
.L_lambda_simple_params_end_4f7c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f7c
	jmp .L_lambda_simple_end_4f7c
.L_lambda_simple_code_4f7c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f7c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f7c:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f7d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_4f7d
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f7d
.L_lambda_simple_env_end_4f7d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f7d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f7d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f7d
.L_lambda_simple_params_end_4f7d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f7d
	jmp .L_lambda_simple_end_4f7d
.L_lambda_simple_code_4f7d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f7d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f7d:
	enter 0, 0
	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 9	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f7e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 8
	je .L_lambda_simple_env_end_4f7e
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f7e
.L_lambda_simple_env_end_4f7e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f7e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f7e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f7e
.L_lambda_simple_params_end_4f7e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f7e
	jmp .L_lambda_simple_end_4f7e
.L_lambda_simple_code_4f7e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f7e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f7e:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f7f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_simple_env_end_4f7f
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f7f
.L_lambda_simple_env_end_4f7f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f7f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f7f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f7f
.L_lambda_simple_params_end_4f7f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f7f
	jmp .L_lambda_simple_end_4f7f
.L_lambda_simple_code_4f7f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f7f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f7f:
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
	jne .L_or_end_0617
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
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56ad
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
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_5d10:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d10
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
	jmp .L_tc_recycle_frame_loop_5d10
.L_tc_recycle_frame_done_5d10:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56ad
	.L_if_else_56ad:
	lea rax, [2 + L_constants]
	.L_if_end_56ad:
.L_or_end_0617:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f7f:	; new closure is in rax
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
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0c92:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_opt_env_end_0c92
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c92
.L_lambda_opt_env_end_0c92:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c92:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c92
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c92
.L_lambda_opt_params_end_0c92:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c92
	jmp .L_lambda_opt_end_0c92
.L_lambda_opt_code_0c92:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c92
.L_lambda_opt_arity_check_exact_0c92:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c92:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c92
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c92
.L_lambda_opt_stack_enlarge_loop_exit_0c92:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c92
.L_lambda_opt_arity_check_more_0c92:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c92:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c92
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
	jmp .L_lambda_opt_list_create_loop_0c92
.L_lambda_opt_list_create_loop_exit_0c92:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c92:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c92
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
	jmp .L_lambda_opt_stack_shrink_loop_0c92
.L_lambda_opt_stack_shrink_loop_exit_0c92:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c92:
	enter 0, 0
	mov rax, PARAM(1)
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
.L_tc_recycle_frame_loop_5d11:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d11
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
	jmp .L_tc_recycle_frame_loop_5d11
.L_tc_recycle_frame_done_5d11:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c92:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f7e:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d0f:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d0f
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
	jmp .L_tc_recycle_frame_loop_5d0f
.L_tc_recycle_frame_done_5d0f:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f7d:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f80:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_4f80
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f80
.L_lambda_simple_env_end_4f80:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f80:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f80
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f80
.L_lambda_simple_params_end_4f80:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f80
	jmp .L_lambda_simple_end_4f80
.L_lambda_simple_code_4f80:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f80
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f80:
	enter 0, 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*4]
	mov rax, qword [rax + 8*0]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_102], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_103], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_104], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*2]
	mov rax, qword [rax + 8*0]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_105], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*3]
	mov rax, qword [rax + 8*0]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_106], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f80:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d0e:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d0e
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
	jmp .L_tc_recycle_frame_loop_5d0e
.L_tc_recycle_frame_done_5d0e:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f7c:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d0c:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d0c
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
	jmp .L_tc_recycle_frame_loop_5d0c
.L_tc_recycle_frame_done_5d0c:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f7a:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d0a:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d0a
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
	jmp .L_tc_recycle_frame_loop_5d0a
.L_tc_recycle_frame_done_5d0a:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f78:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d08:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d08
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
	jmp .L_tc_recycle_frame_loop_5d08
.L_tc_recycle_frame_done_5d08:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f76:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d07:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d07
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
	jmp .L_tc_recycle_frame_loop_5d07
.L_tc_recycle_frame_done_5d07:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f75:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d06:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d06
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
	jmp .L_tc_recycle_frame_loop_5d06
.L_tc_recycle_frame_done_5d06:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f74:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5cff:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5cff
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
	jmp .L_tc_recycle_frame_loop_5cff
.L_tc_recycle_frame_done_5cff:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f71:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

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
.L_lambda_simple_env_loop_4f81:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f81
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f81
.L_lambda_simple_env_end_4f81:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f81:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f81
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f81
.L_lambda_simple_params_end_4f81:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f81
	jmp .L_lambda_simple_end_4f81
.L_lambda_simple_code_4f81:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f81
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f81:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f82:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f82
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f82
.L_lambda_simple_env_end_4f82:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f82:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f82
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f82
.L_lambda_simple_params_end_4f82:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f82
	jmp .L_lambda_simple_end_4f82
.L_lambda_simple_code_4f82:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f82
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f82:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56ae
	lea rax, [1 + L_constants]
	jmp .L_if_end_56ae
	.L_if_else_56ae:
	mov rax, PARAM(1)
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_98]
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
	mov rax, PARAM(1)
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
.L_tc_recycle_frame_loop_5d12:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d12
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
	jmp .L_tc_recycle_frame_loop_5d12
.L_tc_recycle_frame_done_5d12:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56ae:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f82:	; new closure is in rax
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
.L_lambda_opt_env_loop_0c93:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c93
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c93
.L_lambda_opt_env_end_0c93:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c93:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c93
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c93
.L_lambda_opt_params_end_0c93:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c93
	jmp .L_lambda_opt_end_0c93
.L_lambda_opt_code_0c93:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c93
.L_lambda_opt_arity_check_exact_0c93:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c93:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c93
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c93
.L_lambda_opt_stack_enlarge_loop_exit_0c93:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c93
.L_lambda_opt_arity_check_more_0c93:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c93:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c93
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
	jmp .L_lambda_opt_list_create_loop_0c93
.L_lambda_opt_list_create_loop_exit_0c93:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c93:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c93
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
	jmp .L_lambda_opt_stack_shrink_loop_0c93
.L_lambda_opt_stack_shrink_loop_exit_0c93:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c93:
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
	je .L_if_else_56af
	lea rax, [4 + L_constants]
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
.L_tc_recycle_frame_loop_5d13:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d13
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
	jmp .L_tc_recycle_frame_loop_5d13
.L_tc_recycle_frame_done_5d13:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56af
	.L_if_else_56af:
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
	je .L_if_else_56b1
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
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56b2
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
	mov rax, qword [free_var_3]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56b2
	.L_if_else_56b2:
	lea rax, [2 + L_constants]
	.L_if_end_56b2:
	jmp .L_if_end_56b1
	.L_if_else_56b1:
	lea rax, [2 + L_constants]
	.L_if_end_56b1:
	cmp rax, sob_boolean_false
	je .L_if_else_56b0
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
.L_tc_recycle_frame_loop_5d14:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d14
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
	jmp .L_tc_recycle_frame_loop_5d14
.L_tc_recycle_frame_done_5d14:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56b0
	.L_if_else_56b0:
	lea rax, [288 + L_constants]
	push rax
	lea rax, [279 + L_constants]
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
.L_tc_recycle_frame_loop_5d15:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d15
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
	jmp .L_tc_recycle_frame_loop_5d15
.L_tc_recycle_frame_done_5d15:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56b0:
	.L_if_end_56af:
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c93:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f81:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_107], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_112], rax
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
.L_lambda_simple_env_loop_4f83:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f83
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f83
.L_lambda_simple_env_end_4f83:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f83:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f83
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f83
.L_lambda_simple_params_end_4f83:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f83
	jmp .L_lambda_simple_end_4f83
.L_lambda_simple_code_4f83:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f83
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f83:
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
.L_lambda_opt_env_loop_0c94:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c94
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c94
.L_lambda_opt_env_end_0c94:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c94:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c94
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c94
.L_lambda_opt_params_end_0c94:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c94
	jmp .L_lambda_opt_end_0c94
.L_lambda_opt_code_0c94:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c94
.L_lambda_opt_arity_check_exact_0c94:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c94:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_0c94
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c94
.L_lambda_opt_stack_enlarge_loop_exit_0c94:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_0c94
.L_lambda_opt_arity_check_more_0c94:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c94:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c94
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
	jmp .L_lambda_opt_list_create_loop_0c94
.L_lambda_opt_list_create_loop_exit_0c94:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c94:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_0c94
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
	jmp .L_lambda_opt_stack_shrink_loop_0c94
.L_lambda_opt_stack_shrink_loop_exit_0c94:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_0c94:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	mov rax, qword [free_var_24]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 2
	mov rax, qword [free_var_89]
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
.L_tc_recycle_frame_loop_5d16:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d16
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
	jmp .L_tc_recycle_frame_loop_5d16
.L_tc_recycle_frame_done_5d16:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_0c94:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f83:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f84:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f84
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f84
.L_lambda_simple_env_end_4f84:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f84:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f84
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f84
.L_lambda_simple_params_end_4f84:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f84
	jmp .L_lambda_simple_end_4f84
.L_lambda_simple_code_4f84:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f84
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f84:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_112], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f84:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_113], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_114], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [342 + L_constants]
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	lea rax, [346 + L_constants]
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_98]
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
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f85:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f85
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f85
.L_lambda_simple_env_end_4f85:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f85:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f85
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f85
.L_lambda_simple_params_end_4f85:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f85
	jmp .L_lambda_simple_end_4f85
.L_lambda_simple_code_4f85:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f85
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f85:
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
.L_lambda_simple_env_loop_4f86:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f86
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f86
.L_lambda_simple_env_end_4f86:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f86:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f86
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f86
.L_lambda_simple_params_end_4f86:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f86
	jmp .L_lambda_simple_end_4f86
.L_lambda_simple_code_4f86:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f86
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f86:
	enter 0, 0
	lea rax, [344 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	lea rax, [342 + L_constants]
	push rax
	push 3
	mov rax, qword [free_var_109]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56b3
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_25]
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
.L_tc_recycle_frame_loop_5d17:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d17
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
	jmp .L_tc_recycle_frame_loop_5d17
.L_tc_recycle_frame_done_5d17:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56b3
	.L_if_else_56b3:
	mov rax, PARAM(0)
	.L_if_end_56b3:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f86:	; new closure is in rax
	mov qword [free_var_113], rax
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
.L_lambda_simple_env_loop_4f87:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f87
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f87
.L_lambda_simple_env_end_4f87:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f87:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f87
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f87
.L_lambda_simple_params_end_4f87:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f87
	jmp .L_lambda_simple_end_4f87
.L_lambda_simple_code_4f87:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f87
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f87:
	enter 0, 0
	lea rax, [348 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	lea rax, [346 + L_constants]
	push rax
	push 3
	mov rax, qword [free_var_109]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56b4
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_25]
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
.L_tc_recycle_frame_loop_5d18:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d18
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
	jmp .L_tc_recycle_frame_loop_5d18
.L_tc_recycle_frame_done_5d18:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56b4
	.L_if_else_56b4:
	mov rax, PARAM(0)
	.L_if_end_56b4:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f87:	; new closure is in rax
	mov qword [free_var_114], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f85:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_119], rax
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
.L_lambda_simple_env_loop_4f88:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f88
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f88
.L_lambda_simple_env_end_4f88:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f88:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f88
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f88
.L_lambda_simple_params_end_4f88:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f88
	jmp .L_lambda_simple_end_4f88
.L_lambda_simple_code_4f88:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f88
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f88:
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
.L_lambda_opt_env_loop_0c95:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c95
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c95
.L_lambda_opt_env_end_0c95:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c95:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c95
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c95
.L_lambda_opt_params_end_0c95:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c95
	jmp .L_lambda_opt_end_0c95
.L_lambda_opt_code_0c95:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c95
.L_lambda_opt_arity_check_exact_0c95:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c95:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_0c95
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c95
.L_lambda_opt_stack_enlarge_loop_exit_0c95:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_0c95
.L_lambda_opt_arity_check_more_0c95:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c95:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c95
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
	jmp .L_lambda_opt_list_create_loop_0c95
.L_lambda_opt_list_create_loop_exit_0c95:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c95:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_0c95
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
	jmp .L_lambda_opt_stack_shrink_loop_0c95
.L_lambda_opt_stack_shrink_loop_exit_0c95:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_0c95:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
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
.L_lambda_simple_env_loop_4f89:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f89
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f89
.L_lambda_simple_env_end_4f89:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f89:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f89
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f89
.L_lambda_simple_params_end_4f89:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f89
	jmp .L_lambda_simple_end_4f89
.L_lambda_simple_code_4f89:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f89
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f89:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_113]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_24]
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
.L_tc_recycle_frame_loop_5d1a:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d1a
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
	jmp .L_tc_recycle_frame_loop_5d1a
.L_tc_recycle_frame_done_5d1a:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f89:	; new closure is in rax
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 2
	mov rax, qword [free_var_89]
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
.L_tc_recycle_frame_loop_5d19:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d19
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
	jmp .L_tc_recycle_frame_loop_5d19
.L_tc_recycle_frame_done_5d19:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_0c95:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f88:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f8a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f8a
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f8a
.L_lambda_simple_env_end_4f8a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f8a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f8a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f8a
.L_lambda_simple_params_end_4f8a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f8a
	jmp .L_lambda_simple_end_4f8a
.L_lambda_simple_code_4f8a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f8a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f8a:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_119], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f8a:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_121], rax
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
.L_lambda_simple_env_loop_4f8b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f8b
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f8b
.L_lambda_simple_env_end_4f8b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f8b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f8b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f8b
.L_lambda_simple_params_end_4f8b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f8b
	jmp .L_lambda_simple_end_4f8b
.L_lambda_simple_code_4f8b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f8b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f8b:
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
.L_lambda_simple_env_loop_4f8c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f8c
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f8c
.L_lambda_simple_env_end_4f8c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f8c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f8c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f8c
.L_lambda_simple_params_end_4f8c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f8c
	jmp .L_lambda_simple_end_4f8c
.L_lambda_simple_code_4f8c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f8c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f8c:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_123]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_122]
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
.L_tc_recycle_frame_loop_5d1b:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d1b
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
	jmp .L_tc_recycle_frame_loop_5d1b
.L_tc_recycle_frame_done_5d1b:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f8c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f8b:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f8d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f8d
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f8d
.L_lambda_simple_env_end_4f8d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f8d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f8d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f8d
.L_lambda_simple_params_end_4f8d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f8d
	jmp .L_lambda_simple_end_4f8d
.L_lambda_simple_code_4f8d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f8d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f8d:
	enter 0, 0
	mov rax, qword [free_var_113]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rax, qword [free_var_114]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_121], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f8d:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_131], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_132], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	lea rax, [0 + L_constants]
	mov qword [free_var_133], rax
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
.L_lambda_simple_env_loop_4f8e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f8e
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f8e
.L_lambda_simple_env_end_4f8e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f8e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f8e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f8e
.L_lambda_simple_params_end_4f8e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f8e
	jmp .L_lambda_simple_end_4f8e
.L_lambda_simple_code_4f8e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f8e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f8e:
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
.L_lambda_simple_env_loop_4f8f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f8f
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f8f
.L_lambda_simple_env_end_4f8f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f8f:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f8f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f8f
.L_lambda_simple_params_end_4f8f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f8f
	jmp .L_lambda_simple_end_4f8f
.L_lambda_simple_code_4f8f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f8f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f8f:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f90:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f90
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f90
.L_lambda_simple_env_end_4f90:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f90:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f90
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f90
.L_lambda_simple_params_end_4f90:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f90
	jmp .L_lambda_simple_end_4f90
.L_lambda_simple_code_4f90:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_4f90
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f90:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56b5
	mov rax, PARAM(4)
	push rax
	mov rax, PARAM(2)
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56b5
	.L_if_else_56b5:
	lea rax, [2 + L_constants]
	.L_if_end_56b5:
	cmp rax, sob_boolean_false
	jne .L_or_end_0618
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56b6
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(3)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	jne .L_or_end_0619
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(3)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*1]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56b7
	mov rax, PARAM(4)
	push rax
	mov rax, PARAM(3)
	push rax
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(1)
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 5
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
.L_tc_recycle_frame_loop_5d1d:	 ; start recycle frame loop
	cmp rsi, 8
	je .L_tc_recycle_frame_done_5d1d
	mov rcx, 7
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
	jmp .L_tc_recycle_frame_loop_5d1d
.L_tc_recycle_frame_done_5d1d:	 ; end recycle frame loop
	mov rbx, 7
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56b7
	.L_if_else_56b7:
	lea rax, [2 + L_constants]
	.L_if_end_56b7:
.L_or_end_0619:
	jmp .L_if_end_56b6
	.L_if_else_56b6:
	lea rax, [2 + L_constants]
	.L_if_end_56b6:
.L_or_end_0618:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_4f90:	; new closure is in rax
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
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f91:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f91
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f91
.L_lambda_simple_env_end_4f91:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f91:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f91
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f91
.L_lambda_simple_params_end_4f91:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f91
	jmp .L_lambda_simple_end_4f91
.L_lambda_simple_code_4f91:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f91
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f91:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
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
.L_lambda_simple_env_loop_4f92:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4f92
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f92
.L_lambda_simple_env_end_4f92:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f92:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f92
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f92
.L_lambda_simple_params_end_4f92:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f92
	jmp .L_lambda_simple_end_4f92
.L_lambda_simple_code_4f92:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f92
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f92:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_103]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56b8
	mov rax, PARAM(1)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	lea rax, [32 + L_constants]
	push rax
	push 5
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
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
.L_tc_recycle_frame_loop_5d20:	 ; start recycle frame loop
	cmp rsi, 8
	je .L_tc_recycle_frame_done_5d20
	mov rcx, 7
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
	jmp .L_tc_recycle_frame_loop_5d20
.L_tc_recycle_frame_done_5d20:	 ; end recycle frame loop
	mov rbx, 7
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56b8
	.L_if_else_56b8:
	mov rax, PARAM(0)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	lea rax, [32 + L_constants]
	push rax
	push 5
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
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
.L_tc_recycle_frame_loop_5d21:	 ; start recycle frame loop
	cmp rsi, 8
	je .L_tc_recycle_frame_done_5d21
	mov rcx, 7
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
	jmp .L_tc_recycle_frame_loop_5d21
.L_tc_recycle_frame_done_5d21:	 ; end recycle frame loop
	mov rbx, 7
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56b8:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f92:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d1f:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d1f
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
	jmp .L_tc_recycle_frame_loop_5d1f
.L_tc_recycle_frame_done_5d1f:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f91:	; new closure is in rax
	push rax
	push 1
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
.L_lambda_simple_env_loop_4f93:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f93
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f93
.L_lambda_simple_env_end_4f93:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f93:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f93
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f93
.L_lambda_simple_params_end_4f93:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f93
	jmp .L_lambda_simple_end_4f93
.L_lambda_simple_code_4f93:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f93
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f93:
	enter 0, 0
	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f94:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4f94
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f94
.L_lambda_simple_env_end_4f94:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f94:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f94
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f94
.L_lambda_simple_params_end_4f94:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f94
	jmp .L_lambda_simple_end_4f94
.L_lambda_simple_code_4f94:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f94
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f94:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f95:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_4f95
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f95
.L_lambda_simple_env_end_4f95:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f95:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f95
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f95
.L_lambda_simple_params_end_4f95:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f95
	jmp .L_lambda_simple_end_4f95
.L_lambda_simple_code_4f95:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f95
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f95:
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
	jne .L_or_end_061a
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
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56b9
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
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_5d23:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d23
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
	jmp .L_tc_recycle_frame_loop_5d23
.L_tc_recycle_frame_done_5d23:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56b9
	.L_if_else_56b9:
	lea rax, [2 + L_constants]
	.L_if_end_56b9:
.L_or_end_061a:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f95:	; new closure is in rax
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
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0c96:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0c96
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c96
.L_lambda_opt_env_end_0c96:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c96:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c96
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c96
.L_lambda_opt_params_end_0c96:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c96
	jmp .L_lambda_opt_end_0c96
.L_lambda_opt_code_0c96:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c96
.L_lambda_opt_arity_check_exact_0c96:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c96:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c96
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c96
.L_lambda_opt_stack_enlarge_loop_exit_0c96:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c96
.L_lambda_opt_arity_check_more_0c96:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c96:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c96
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
	jmp .L_lambda_opt_list_create_loop_0c96
.L_lambda_opt_list_create_loop_exit_0c96:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c96:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c96
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
	jmp .L_lambda_opt_stack_shrink_loop_0c96
.L_lambda_opt_stack_shrink_loop_exit_0c96:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c96:
	enter 0, 0
	mov rax, PARAM(1)
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
.L_tc_recycle_frame_loop_5d24:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d24
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
	jmp .L_tc_recycle_frame_loop_5d24
.L_tc_recycle_frame_done_5d24:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c96:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f94:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d22:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d22
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
	jmp .L_tc_recycle_frame_loop_5d22
.L_tc_recycle_frame_done_5d22:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f93:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d1e:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d1e
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
	jmp .L_tc_recycle_frame_loop_5d1e
.L_tc_recycle_frame_done_5d1e:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f8f:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d1c:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d1c
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
	jmp .L_tc_recycle_frame_loop_5d1c
.L_tc_recycle_frame_done_5d1c:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f8e:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f96:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f96
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f96
.L_lambda_simple_env_end_4f96:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f96:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f96
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f96
.L_lambda_simple_params_end_4f96:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f96
	jmp .L_lambda_simple_end_4f96
.L_lambda_simple_code_4f96:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f96
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f96:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_115]
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_133], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f96:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

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
.L_lambda_simple_env_loop_4f97:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f97
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f97
.L_lambda_simple_env_end_4f97:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f97:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f97
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f97
.L_lambda_simple_params_end_4f97:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f97
	jmp .L_lambda_simple_end_4f97
.L_lambda_simple_code_4f97:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f97
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f97:
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
.L_lambda_simple_env_loop_4f98:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4f98
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f98
.L_lambda_simple_env_end_4f98:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f98:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f98
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f98
.L_lambda_simple_params_end_4f98:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f98
	jmp .L_lambda_simple_end_4f98
.L_lambda_simple_code_4f98:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f98
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f98:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4f99:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f99
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f99
.L_lambda_simple_env_end_4f99:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f99:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f99
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f99
.L_lambda_simple_params_end_4f99:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f99
	jmp .L_lambda_simple_end_4f99
.L_lambda_simple_code_4f99:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_4f99
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f99:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	jne .L_or_end_061b
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(3)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	jne .L_or_end_061b
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56ba
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(3)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*1]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56bb
	mov rax, PARAM(4)
	push rax
	mov rax, PARAM(3)
	push rax
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(1)
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 5
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
.L_tc_recycle_frame_loop_5d26:	 ; start recycle frame loop
	cmp rsi, 8
	je .L_tc_recycle_frame_done_5d26
	mov rcx, 7
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
	jmp .L_tc_recycle_frame_loop_5d26
.L_tc_recycle_frame_done_5d26:	 ; end recycle frame loop
	mov rbx, 7
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56bb
	.L_if_else_56bb:
	lea rax, [2 + L_constants]
	.L_if_end_56bb:
	jmp .L_if_end_56ba
	.L_if_else_56ba:
	lea rax, [2 + L_constants]
	.L_if_end_56ba:
.L_or_end_061b:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_4f99:	; new closure is in rax
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
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f9a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f9a
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f9a
.L_lambda_simple_env_end_4f9a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f9a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f9a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f9a
.L_lambda_simple_params_end_4f9a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f9a
	jmp .L_lambda_simple_end_4f9a
.L_lambda_simple_code_4f9a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f9a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f9a:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
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
.L_lambda_simple_env_loop_4f9b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4f9b
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f9b
.L_lambda_simple_env_end_4f9b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f9b:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4f9b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f9b
.L_lambda_simple_params_end_4f9b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f9b
	jmp .L_lambda_simple_end_4f9b
.L_lambda_simple_code_4f9b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f9b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f9b:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_103]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56bc
	mov rax, PARAM(1)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	lea rax, [32 + L_constants]
	push rax
	push 5
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
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
.L_tc_recycle_frame_loop_5d29:	 ; start recycle frame loop
	cmp rsi, 8
	je .L_tc_recycle_frame_done_5d29
	mov rcx, 7
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
	jmp .L_tc_recycle_frame_loop_5d29
.L_tc_recycle_frame_done_5d29:	 ; end recycle frame loop
	mov rbx, 7
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56bc
	.L_if_else_56bc:
	mov rax, PARAM(0)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	lea rax, [32 + L_constants]
	push rax
	push 5
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
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
.L_tc_recycle_frame_loop_5d2a:	 ; start recycle frame loop
	cmp rsi, 8
	je .L_tc_recycle_frame_done_5d2a
	mov rcx, 7
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
	jmp .L_tc_recycle_frame_loop_5d2a
.L_tc_recycle_frame_done_5d2a:	 ; end recycle frame loop
	mov rbx, 7
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56bc:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f9b:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d28:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d28
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
	jmp .L_tc_recycle_frame_loop_5d28
.L_tc_recycle_frame_done_5d28:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f9a:	; new closure is in rax
	push rax
	push 1
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
.L_lambda_simple_env_loop_4f9c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4f9c
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f9c
.L_lambda_simple_env_end_4f9c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f9c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f9c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f9c
.L_lambda_simple_params_end_4f9c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f9c
	jmp .L_lambda_simple_end_4f9c
.L_lambda_simple_code_4f9c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f9c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f9c:
	enter 0, 0
	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f9d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4f9d
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f9d
.L_lambda_simple_env_end_4f9d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f9d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f9d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f9d
.L_lambda_simple_params_end_4f9d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f9d
	jmp .L_lambda_simple_end_4f9d
.L_lambda_simple_code_4f9d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f9d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f9d:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4f9e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_4f9e
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f9e
.L_lambda_simple_env_end_4f9e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f9e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4f9e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f9e
.L_lambda_simple_params_end_4f9e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f9e
	jmp .L_lambda_simple_end_4f9e
.L_lambda_simple_code_4f9e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4f9e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f9e:
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
	jne .L_or_end_061c
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
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56bd
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
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_5d2c:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d2c
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
	jmp .L_tc_recycle_frame_loop_5d2c
.L_tc_recycle_frame_done_5d2c:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56bd
	.L_if_else_56bd:
	lea rax, [2 + L_constants]
	.L_if_end_56bd:
.L_or_end_061c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f9e:	; new closure is in rax
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
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0c97:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0c97
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c97
.L_lambda_opt_env_end_0c97:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c97:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c97
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c97
.L_lambda_opt_params_end_0c97:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c97
	jmp .L_lambda_opt_end_0c97
.L_lambda_opt_code_0c97:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c97
.L_lambda_opt_arity_check_exact_0c97:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c97:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c97
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c97
.L_lambda_opt_stack_enlarge_loop_exit_0c97:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c97
.L_lambda_opt_arity_check_more_0c97:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c97:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c97
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
	jmp .L_lambda_opt_list_create_loop_0c97
.L_lambda_opt_list_create_loop_exit_0c97:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c97:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c97
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
	jmp .L_lambda_opt_stack_shrink_loop_0c97
.L_lambda_opt_stack_shrink_loop_exit_0c97:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c97:
	enter 0, 0
	mov rax, PARAM(1)
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
.L_tc_recycle_frame_loop_5d2d:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d2d
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
	jmp .L_tc_recycle_frame_loop_5d2d
.L_tc_recycle_frame_done_5d2d:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c97:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f9d:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d2b:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d2b
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
	jmp .L_tc_recycle_frame_loop_5d2b
.L_tc_recycle_frame_done_5d2b:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f9c:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d27:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d27
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
	jmp .L_tc_recycle_frame_loop_5d27
.L_tc_recycle_frame_done_5d27:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f98:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d25:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d25
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
	jmp .L_tc_recycle_frame_loop_5d25
.L_tc_recycle_frame_done_5d25:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4f97:	; new closure is in rax
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
.L_lambda_simple_env_loop_4f9f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4f9f
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4f9f
.L_lambda_simple_env_end_4f9f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4f9f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4f9f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4f9f
.L_lambda_simple_params_end_4f9f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4f9f
	jmp .L_lambda_simple_end_4f9f
.L_lambda_simple_code_4f9f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4f9f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4f9f:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_132], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4f9f:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

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
.L_lambda_simple_env_loop_4fa0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fa0
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa0
.L_lambda_simple_env_end_4fa0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fa0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa0
.L_lambda_simple_params_end_4fa0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa0
	jmp .L_lambda_simple_end_4fa0
.L_lambda_simple_code_4fa0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fa0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa0:
	enter 0, 0
	lea rax, [23 + L_constants]
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
.L_lambda_simple_env_loop_4fa1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fa1
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa1
.L_lambda_simple_env_end_4fa1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa1:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fa1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa1
.L_lambda_simple_params_end_4fa1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa1
	jmp .L_lambda_simple_end_4fa1
.L_lambda_simple_code_4fa1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fa1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa1:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4fa2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4fa2
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa2
.L_lambda_simple_env_end_4fa2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa2:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fa2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa2
.L_lambda_simple_params_end_4fa2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa2
	jmp .L_lambda_simple_end_4fa2
.L_lambda_simple_code_4fa2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 4
	je .L_lambda_simple_arity_check_ok_4fa2
	push qword [rsp + 8 * 2]
	push 4
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa2:
	enter 0, 0
	mov rax, PARAM(3)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	jne .L_or_end_061d
	mov rax, PARAM(3)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56be
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(2)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56bf
	mov rax, PARAM(3)
	push rax
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(1)
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 4
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
.L_tc_recycle_frame_loop_5d2f:	 ; start recycle frame loop
	cmp rsi, 7
	je .L_tc_recycle_frame_done_5d2f
	mov rcx, 6
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
	jmp .L_tc_recycle_frame_loop_5d2f
.L_tc_recycle_frame_done_5d2f:	 ; end recycle frame loop
	mov rbx, 6
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56bf
	.L_if_else_56bf:
	lea rax, [2 + L_constants]
	.L_if_end_56bf:
	jmp .L_if_end_56be
	.L_if_else_56be:
	lea rax, [2 + L_constants]
	.L_if_end_56be:
.L_or_end_061d:
	leave
	ret 8 * (2 + 4)
.L_lambda_simple_end_4fa2:	; new closure is in rax
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
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4fa3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4fa3
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa3
.L_lambda_simple_env_end_4fa3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa3:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fa3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa3
.L_lambda_simple_params_end_4fa3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa3
	jmp .L_lambda_simple_end_4fa3
.L_lambda_simple_code_4fa3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fa3
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa3:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
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
.L_lambda_simple_env_loop_4fa4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4fa4
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa4
.L_lambda_simple_env_end_4fa4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa4:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4fa4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa4
.L_lambda_simple_params_end_4fa4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa4
	jmp .L_lambda_simple_end_4fa4
.L_lambda_simple_code_4fa4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fa4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa4:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56c0
	mov rax, PARAM(0)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	lea rax, [32 + L_constants]
	push rax
	push 4
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
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
.L_tc_recycle_frame_loop_5d32:	 ; start recycle frame loop
	cmp rsi, 7
	je .L_tc_recycle_frame_done_5d32
	mov rcx, 6
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
	jmp .L_tc_recycle_frame_loop_5d32
.L_tc_recycle_frame_done_5d32:	 ; end recycle frame loop
	mov rbx, 6
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56c0
	.L_if_else_56c0:
	lea rax, [2 + L_constants]
	.L_if_end_56c0:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fa4:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d31:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d31
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
	jmp .L_tc_recycle_frame_loop_5d31
.L_tc_recycle_frame_done_5d31:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fa3:	; new closure is in rax
	push rax
	push 1
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
.L_lambda_simple_env_loop_4fa5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4fa5
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa5
.L_lambda_simple_env_end_4fa5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa5:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fa5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa5
.L_lambda_simple_params_end_4fa5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa5
	jmp .L_lambda_simple_end_4fa5
.L_lambda_simple_code_4fa5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fa5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa5:
	enter 0, 0
	lea rax, [23 + L_constants]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4fa6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4fa6
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa6
.L_lambda_simple_env_end_4fa6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fa6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa6
.L_lambda_simple_params_end_4fa6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa6
	jmp .L_lambda_simple_end_4fa6
.L_lambda_simple_code_4fa6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fa6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa6:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4fa7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_4fa7
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa7
.L_lambda_simple_env_end_4fa7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa7:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fa7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa7
.L_lambda_simple_params_end_4fa7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa7
	jmp .L_lambda_simple_end_4fa7
.L_lambda_simple_code_4fa7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fa7
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa7:
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
	jne .L_or_end_061e
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
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax + 8*0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56c1
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
	push RET_ADDR
	mov rdi, COUNT
	add rdi, 3
	shl rdi, 3
	add rdi, rbp
	mov rbp, OLD_RDP
	mov rsi, 0
.L_tc_recycle_frame_loop_5d34:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d34
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
	jmp .L_tc_recycle_frame_loop_5d34
.L_tc_recycle_frame_done_5d34:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56c1
	.L_if_else_56c1:
	lea rax, [2 + L_constants]
	.L_if_end_56c1:
.L_or_end_061e:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fa7:	; new closure is in rax
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
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0c98:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0c98
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c98
.L_lambda_opt_env_end_0c98:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c98:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c98
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c98
.L_lambda_opt_params_end_0c98:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c98
	jmp .L_lambda_opt_end_0c98
.L_lambda_opt_code_0c98:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c98
.L_lambda_opt_arity_check_exact_0c98:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c98:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c98
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c98
.L_lambda_opt_stack_enlarge_loop_exit_0c98:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c98
.L_lambda_opt_arity_check_more_0c98:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c98:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c98
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
	jmp .L_lambda_opt_list_create_loop_0c98
.L_lambda_opt_list_create_loop_exit_0c98:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c98:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c98
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
	jmp .L_lambda_opt_stack_shrink_loop_0c98
.L_lambda_opt_stack_shrink_loop_exit_0c98:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c98:
	enter 0, 0
	mov rax, PARAM(1)
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
.L_tc_recycle_frame_loop_5d35:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d35
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
	jmp .L_tc_recycle_frame_loop_5d35
.L_tc_recycle_frame_done_5d35:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c98:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fa6:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d33:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d33
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
	jmp .L_tc_recycle_frame_loop_5d33
.L_tc_recycle_frame_done_5d33:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fa5:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d30:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d30
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
	jmp .L_tc_recycle_frame_loop_5d30
.L_tc_recycle_frame_done_5d30:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fa1:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d2e:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d2e
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
	jmp .L_tc_recycle_frame_loop_5d2e
.L_tc_recycle_frame_done_5d2e:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fa0:	; new closure is in rax
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
.L_lambda_simple_env_loop_4fa8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fa8
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa8
.L_lambda_simple_env_end_4fa8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fa8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa8
.L_lambda_simple_params_end_4fa8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa8
	jmp .L_lambda_simple_end_4fa8
.L_lambda_simple_code_4fa8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fa8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa8:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	push 1
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_131], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fa8:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

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
.L_lambda_simple_env_loop_4fa9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fa9
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fa9
.L_lambda_simple_env_end_4fa9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fa9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fa9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fa9
.L_lambda_simple_params_end_4fa9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fa9
	jmp .L_lambda_simple_end_4fa9
.L_lambda_simple_code_4fa9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fa9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fa9:
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
	je .L_if_else_56c2
	lea rax, [32 + L_constants]
	jmp .L_if_end_56c2
	.L_if_else_56c2:
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
	push 1
	mov rax, qword [free_var_134]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	lea rax, [128 + L_constants]
	push rax
	push 2
	mov rax, qword [free_var_97]
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
.L_tc_recycle_frame_loop_5d36:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d36
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
	jmp .L_tc_recycle_frame_loop_5d36
.L_tc_recycle_frame_done_5d36:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56c2:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fa9:	; new closure is in rax
	mov qword [free_var_134], rax
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
.L_lambda_simple_env_loop_4faa:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4faa
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4faa
.L_lambda_simple_env_end_4faa:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4faa:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4faa
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4faa
.L_lambda_simple_params_end_4faa:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4faa
	jmp .L_lambda_simple_end_4faa
.L_lambda_simple_code_4faa:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4faa
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4faa:
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
	jne .L_or_end_061f
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56c3
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
	push 1
	mov rax, qword [free_var_84]
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
.L_tc_recycle_frame_loop_5d37:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d37
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
	jmp .L_tc_recycle_frame_loop_5d37
.L_tc_recycle_frame_done_5d37:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56c3
	.L_if_else_56c3:
	lea rax, [2 + L_constants]
	.L_if_end_56c3:
.L_or_end_061f:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4faa:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_51]
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
.L_lambda_simple_env_loop_4fab:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fab
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fab
.L_lambda_simple_env_end_4fab:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fab:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fab
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fab
.L_lambda_simple_params_end_4fab:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fab
	jmp .L_lambda_simple_end_4fab
.L_lambda_simple_code_4fab:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fab
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fab:
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
.L_lambda_opt_env_loop_0c99:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c99
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c99
.L_lambda_opt_env_end_0c99:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c99:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c99
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c99
.L_lambda_opt_params_end_0c99:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c99
	jmp .L_lambda_opt_end_0c99
.L_lambda_opt_code_0c99:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c99
.L_lambda_opt_arity_check_exact_0c99:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c99:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c99
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c99
.L_lambda_opt_stack_enlarge_loop_exit_0c99:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c99
.L_lambda_opt_arity_check_more_0c99:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c99:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c99
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
	jmp .L_lambda_opt_list_create_loop_0c99
.L_lambda_opt_list_create_loop_exit_0c99:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c99:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c99
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
	jmp .L_lambda_opt_stack_shrink_loop_0c99
.L_lambda_opt_stack_shrink_loop_exit_0c99:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c99:
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
	je .L_if_else_56c4
	lea rax, [0 + L_constants]
	jmp .L_if_end_56c4
	.L_if_else_56c4:
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
	je .L_if_else_56c6
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
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56c6
	.L_if_else_56c6:
	lea rax, [2 + L_constants]
	.L_if_end_56c6:
	cmp rax, sob_boolean_false
	je .L_if_else_56c5
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56c5
	.L_if_else_56c5:
	lea rax, [379 + L_constants]
	push rax
	lea rax, [370 + L_constants]
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	.L_if_end_56c5:
	.L_if_end_56c4:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4fac:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4fac
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fac
.L_lambda_simple_env_end_4fac:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fac:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4fac
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fac
.L_lambda_simple_params_end_4fac:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fac
	jmp .L_lambda_simple_end_4fac
.L_lambda_simple_code_4fac:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fac
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fac:
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
.L_tc_recycle_frame_loop_5d39:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d39
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
	jmp .L_tc_recycle_frame_loop_5d39
.L_tc_recycle_frame_done_5d39:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fac:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d38:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d38
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
	jmp .L_tc_recycle_frame_loop_5d38
.L_tc_recycle_frame_done_5d38:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c99:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fab:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_51], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_52]
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
.L_lambda_simple_env_loop_4fad:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fad
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fad
.L_lambda_simple_env_end_4fad:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fad:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fad
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fad
.L_lambda_simple_params_end_4fad:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fad
	jmp .L_lambda_simple_end_4fad
.L_lambda_simple_code_4fad:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fad
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fad:
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
.L_lambda_opt_env_loop_0c9a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0c9a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c9a
.L_lambda_opt_env_end_0c9a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c9a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0c9a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c9a
.L_lambda_opt_params_end_0c9a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c9a
	jmp .L_lambda_opt_end_0c9a
.L_lambda_opt_code_0c9a:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 1 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c9a
.L_lambda_opt_arity_check_exact_0c9a:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c9a:	 ; stack loop enlarge start
	cmp rsi, 4
	je .L_lambda_opt_stack_enlarge_loop_exit_0c9a
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c9a
.L_lambda_opt_stack_enlarge_loop_exit_0c9a:	 ; end of stack enlarge loop
	mov qword [rsp + 4*8], sob_nil
	mov qword [rsp + 2*8], 2
	jmp .L_lambda_opt_stack_adjusted_0c9a
.L_lambda_opt_arity_check_more_0c9a:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c9a:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c9a
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
	jmp .L_lambda_opt_list_create_loop_0c9a
.L_lambda_opt_list_create_loop_exit_0c9a:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c9a:	; start of stack shrink loop
	cmp rsi, 4
	je .L_lambda_opt_stack_shrink_loop_exit_0c9a
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
	jmp .L_lambda_opt_stack_shrink_loop_0c9a
.L_lambda_opt_stack_shrink_loop_exit_0c9a:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 2
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 2
.L_lambda_opt_stack_adjusted_0c9a:
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
	je .L_if_else_56c7
	lea rax, [4 + L_constants]
	jmp .L_if_end_56c7
	.L_if_else_56c7:
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
	je .L_if_else_56c9
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
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56c9
	.L_if_else_56c9:
	lea rax, [2 + L_constants]
	.L_if_end_56c9:
	cmp rax, sob_boolean_false
	je .L_if_else_56c8
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56c8
	.L_if_else_56c8:
	lea rax, [460 + L_constants]
	push rax
	lea rax, [451 + L_constants]
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	.L_if_end_56c8:
	.L_if_end_56c7:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4fae:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4fae
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fae
.L_lambda_simple_env_end_4fae:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fae:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4fae
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fae
.L_lambda_simple_params_end_4fae:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fae
	jmp .L_lambda_simple_end_4fae
.L_lambda_simple_code_4fae:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fae
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fae:
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
.L_tc_recycle_frame_loop_5d3b:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d3b
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
	jmp .L_tc_recycle_frame_loop_5d3b
.L_tc_recycle_frame_done_5d3b:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fae:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d3a:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d3a
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
	jmp .L_tc_recycle_frame_loop_5d3a
.L_tc_recycle_frame_done_5d3a:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(2)
.L_lambda_opt_end_0c9a:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fad:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_52], rax
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
.L_lambda_simple_env_loop_4faf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4faf
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4faf
.L_lambda_simple_env_end_4faf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4faf:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4faf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4faf
.L_lambda_simple_params_end_4faf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4faf
	jmp .L_lambda_simple_end_4faf
.L_lambda_simple_code_4faf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4faf
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4faf:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4fb0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fb0
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb0
.L_lambda_simple_env_end_4fb0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb0:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fb0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb0
.L_lambda_simple_params_end_4fb0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb0
	jmp .L_lambda_simple_end_4fb0
.L_lambda_simple_code_4fb0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fb0
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb0:
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
	je .L_if_else_56ca
	lea rax, [0 + L_constants]
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_51]
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
.L_tc_recycle_frame_loop_5d3c:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d3c
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
	jmp .L_tc_recycle_frame_loop_5d3c
.L_tc_recycle_frame_done_5d3c:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56ca
	.L_if_else_56ca:
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_97]
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
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4fb1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4fb1
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb1
.L_lambda_simple_env_end_4fb1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb1:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4fb1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb1
.L_lambda_simple_params_end_4fb1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb1
	jmp .L_lambda_simple_end_4fb1
.L_lambda_simple_code_4fb1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fb1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb1:
	enter 0, 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	mov rax, PARAM(0)
	push rax
	push 3
	mov rax, qword [free_var_49]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

	mov rax, PARAM(0)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fb1:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d3d:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d3d
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
	jmp .L_tc_recycle_frame_loop_5d3d
.L_tc_recycle_frame_done_5d3d:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56ca:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fb0:	; new closure is in rax
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
.L_lambda_simple_env_loop_4fb2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fb2
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb2
.L_lambda_simple_env_end_4fb2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb2:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fb2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb2
.L_lambda_simple_params_end_4fb2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb2
	jmp .L_lambda_simple_end_4fb2
.L_lambda_simple_code_4fb2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fb2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb2:
	enter 0, 0
	lea rax, [32 + L_constants]
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
.L_tc_recycle_frame_loop_5d3e:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d3e
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
	jmp .L_tc_recycle_frame_loop_5d3e
.L_tc_recycle_frame_done_5d3e:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fb2:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4faf:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_135], rax
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
.L_lambda_simple_env_loop_4fb3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fb3
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb3
.L_lambda_simple_env_end_4fb3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fb3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb3
.L_lambda_simple_params_end_4fb3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb3
	jmp .L_lambda_simple_end_4fb3
.L_lambda_simple_code_4fb3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fb3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb3:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4fb4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fb4
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb4
.L_lambda_simple_env_end_4fb4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb4:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fb4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb4
.L_lambda_simple_params_end_4fb4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb4
	jmp .L_lambda_simple_end_4fb4
.L_lambda_simple_code_4fb4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fb4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb4:
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
	je .L_if_else_56cb
	lea rax, [4 + L_constants]
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_52]
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
.L_tc_recycle_frame_loop_5d3f:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d3f
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
	jmp .L_tc_recycle_frame_loop_5d3f
.L_tc_recycle_frame_done_5d3f:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56cb
	.L_if_else_56cb:
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_97]
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
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4fb5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4fb5
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb5
.L_lambda_simple_env_end_4fb5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb5:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4fb5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb5
.L_lambda_simple_params_end_4fb5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb5
	jmp .L_lambda_simple_end_4fb5
.L_lambda_simple_code_4fb5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fb5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb5:
	enter 0, 0
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	push rax
	mov rax, PARAM(0)
	push rax
	push 3
	mov rax, qword [free_var_50]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx

	mov rax, PARAM(0)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fb5:	; new closure is in rax
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
.L_tc_recycle_frame_loop_5d40:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d40
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
	jmp .L_tc_recycle_frame_loop_5d40
.L_tc_recycle_frame_done_5d40:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56cb:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fb4:	; new closure is in rax
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
.L_lambda_simple_env_loop_4fb6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fb6
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb6
.L_lambda_simple_env_end_4fb6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fb6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb6
.L_lambda_simple_params_end_4fb6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb6
	jmp .L_lambda_simple_end_4fb6
.L_lambda_simple_code_4fb6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fb6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb6:
	enter 0, 0
	lea rax, [32 + L_constants]
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
.L_tc_recycle_frame_loop_5d41:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d41
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
	jmp .L_tc_recycle_frame_loop_5d41
.L_tc_recycle_frame_done_5d41:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fb6:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fb3:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_122], rax
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
.L_lambda_opt_env_loop_0c9b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0c9b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0c9b
.L_lambda_opt_env_end_0c9b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0c9b:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0c9b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0c9b
.L_lambda_opt_params_end_0c9b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0c9b
	jmp .L_lambda_opt_end_0c9b
.L_lambda_opt_code_0c9b:	; lambda-opt body
	mov rdi, qword [rsp + 8 * 2]
	mov rbx, rdi
	sub rbx, 0 ; rbx is the num of extra args
	cmp rbx, 0
	jg .L_lambda_opt_arity_check_more_0c9b
.L_lambda_opt_arity_check_exact_0c9b:	 ; if params in opt is exact
	sub rsp, 8
	mov rsi, 0 ; index
.L_lambda_opt_stack_enlarge_loop_0c9b:	 ; stack loop enlarge start
	cmp rsi, 3
	je .L_lambda_opt_stack_enlarge_loop_exit_0c9b
	mov rdi, rsi
	inc rdi
	shl rdi, 3
	add rdi, rsp
	mov rbx, rdi ; rbx = [rsp + 8 * (rsi + 1)]
	sub rbx, 8
	mov rdi, [rdi]
	mov [rbx], rdi ; [rsp + 8 * (rsi)] = [rsp + 8 * (rsi + 1)]
	inc rsi
	jmp .L_lambda_opt_stack_enlarge_loop_0c9b
.L_lambda_opt_stack_enlarge_loop_exit_0c9b:	 ; end of stack enlarge loop
	mov qword [rsp + 3*8], sob_nil
	mov qword [rsp + 2*8], 1
	jmp .L_lambda_opt_stack_adjusted_0c9b
.L_lambda_opt_arity_check_more_0c9b:	 ; if params in opt is more
	mov rax, sob_nil
	mov rsi, rbx ;index. rbx is the num of extra args
	dec rsi
.L_lambda_opt_list_create_loop_0c9b:	; start of list creation loop
	cmp rsi, -1
	je .L_lambda_opt_list_create_loop_exit_0c9b
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
	jmp .L_lambda_opt_list_create_loop_0c9b
.L_lambda_opt_list_create_loop_exit_0c9b:	; end of list creation loop
	mov rbx, qword [rsp + 8 * 2]
	add rbx, 2
	mov rdi, rbx
	shl rdi,3
	add rdi, rsp
	mov [rdi], rax
	mov rsi, 0 ;index
.L_lambda_opt_stack_shrink_loop_0c9b:	; start of stack shrink loop
	cmp rsi, 3
	je .L_lambda_opt_stack_shrink_loop_exit_0c9b
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
	jmp .L_lambda_opt_stack_shrink_loop_0c9b
.L_lambda_opt_stack_shrink_loop_exit_0c9b:	; end of stack shrink loop
	sub rbx, 2 ; rbx has number of args
	sub rbx, 1
	shl rbx, 3
	add rsp, rbx
	mov qword [rsp + 8 * 2], 1
.L_lambda_opt_stack_adjusted_0c9b:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_135]
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
.L_tc_recycle_frame_loop_5d42:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d42
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
	jmp .L_tc_recycle_frame_loop_5d42
.L_tc_recycle_frame_done_5d42:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret AND_KILL_FRAME(1)
.L_lambda_opt_end_0c9b:	; new closure is in rax
	mov qword [free_var_136], rax
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
.L_lambda_simple_env_loop_4fb7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fb7
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb7
.L_lambda_simple_env_end_4fb7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fb7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb7
.L_lambda_simple_params_end_4fb7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb7
	jmp .L_lambda_simple_end_4fb7
.L_lambda_simple_code_4fb7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fb7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb7:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4fb8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fb8
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb8
.L_lambda_simple_env_end_4fb8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb8:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fb8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb8
.L_lambda_simple_params_end_4fb8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb8
	jmp .L_lambda_simple_end_4fb8
.L_lambda_simple_code_4fb8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_4fb8
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb8:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56cc
	mov rax, PARAM(2)
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_97]
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
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_47]
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
.L_tc_recycle_frame_loop_5d43:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d43
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
	jmp .L_tc_recycle_frame_loop_5d43
.L_tc_recycle_frame_done_5d43:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56cc
	.L_if_else_56cc:
	lea rax, [1 + L_constants]
	.L_if_end_56cc:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_4fb8:	; new closure is in rax
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
.L_lambda_simple_env_loop_4fb9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fb9
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fb9
.L_lambda_simple_env_end_4fb9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fb9:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fb9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fb9
.L_lambda_simple_params_end_4fb9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fb9
	jmp .L_lambda_simple_end_4fb9
.L_lambda_simple_code_4fb9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fb9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fb9:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	lea rax, [32 + L_constants]
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
.L_tc_recycle_frame_loop_5d44:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_5d44
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
	jmp .L_tc_recycle_frame_loop_5d44
.L_tc_recycle_frame_done_5d44:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fb9:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fb7:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_123], rax
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
.L_lambda_simple_env_loop_4fba:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fba
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fba
.L_lambda_simple_env_end_4fba:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fba:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fba
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fba
.L_lambda_simple_params_end_4fba:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fba
	jmp .L_lambda_simple_end_4fba
.L_lambda_simple_code_4fba:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fba
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fba:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4fbb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fbb
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fbb
.L_lambda_simple_env_end_4fbb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fbb:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fbb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fbb
.L_lambda_simple_params_end_4fbb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fbb
	jmp .L_lambda_simple_end_4fbb
.L_lambda_simple_code_4fbb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_4fbb
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fbb:
	enter 0, 0
	mov rax, PARAM(2)
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56cd
	mov rax, PARAM(2)
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, qword [free_var_97]
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
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_48]
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
.L_tc_recycle_frame_loop_5d45:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d45
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
	jmp .L_tc_recycle_frame_loop_5d45
.L_tc_recycle_frame_done_5d45:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56cd
	.L_if_else_56cd:
	lea rax, [1 + L_constants]
	.L_if_end_56cd:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_4fbb:	; new closure is in rax
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
.L_lambda_simple_env_loop_4fbc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fbc
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fbc
.L_lambda_simple_env_end_4fbc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fbc:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4fbc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fbc
.L_lambda_simple_params_end_4fbc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fbc
	jmp .L_lambda_simple_end_4fbc
.L_lambda_simple_code_4fbc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fbc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fbc:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	lea rax, [32 + L_constants]
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
.L_tc_recycle_frame_loop_5d46:	 ; start recycle frame loop
	cmp rsi, 6
	je .L_tc_recycle_frame_done_5d46
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
	jmp .L_tc_recycle_frame_loop_5d46
.L_tc_recycle_frame_done_5d46:	 ; end recycle frame loop
	mov rbx, 5
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fbc:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fba:	; new closure is in rax
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	mov qword [free_var_137], rax
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
.L_lambda_simple_env_loop_4fbd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fbd
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fbd
.L_lambda_simple_env_end_4fbd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fbd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fbd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fbd
.L_lambda_simple_params_end_4fbd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fbd
	jmp .L_lambda_simple_end_4fbd
.L_lambda_simple_code_4fbd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fbd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fbd:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 0
	mov rax, qword [free_var_26]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_44]
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
.L_tc_recycle_frame_loop_5d47:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d47
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
	jmp .L_tc_recycle_frame_loop_5d47
.L_tc_recycle_frame_done_5d47:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fbd:	; new closure is in rax
	mov qword [free_var_138], rax
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
.L_lambda_simple_env_loop_4fbe:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fbe
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fbe
.L_lambda_simple_env_end_4fbe:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fbe:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fbe
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fbe
.L_lambda_simple_params_end_4fbe:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fbe
	jmp .L_lambda_simple_end_4fbe
.L_lambda_simple_code_4fbe:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fbe
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fbe:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	lea rax, [32 + L_constants]
	push rax
	push 2
	mov rax, qword [free_var_102]
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
.L_tc_recycle_frame_loop_5d48:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d48
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
	jmp .L_tc_recycle_frame_loop_5d48
.L_tc_recycle_frame_done_5d48:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fbe:	; new closure is in rax
	mov qword [free_var_139], rax
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
.L_lambda_simple_env_loop_4fbf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fbf
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fbf
.L_lambda_simple_env_end_4fbf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fbf:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fbf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fbf
.L_lambda_simple_params_end_4fbf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fbf
	jmp .L_lambda_simple_end_4fbf
.L_lambda_simple_code_4fbf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fbf
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fbf:
	enter 0, 0
	lea rax, [32 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_102]
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
.L_tc_recycle_frame_loop_5d49:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d49
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
	jmp .L_tc_recycle_frame_loop_5d49
.L_tc_recycle_frame_done_5d49:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fbf:	; new closure is in rax
	mov qword [free_var_140], rax
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
.L_lambda_simple_env_loop_4fc0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fc0
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fc0
.L_lambda_simple_env_end_4fc0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fc0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fc0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fc0
.L_lambda_simple_params_end_4fc0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fc0
	jmp .L_lambda_simple_end_4fc0
.L_lambda_simple_code_4fc0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fc0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fc0:
	enter 0, 0
	lea rax, [512 + L_constants]
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_44]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_27]
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
.L_tc_recycle_frame_loop_5d4a:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d4a
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
	jmp .L_tc_recycle_frame_loop_5d4a
.L_tc_recycle_frame_done_5d4a:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fc0:	; new closure is in rax
	mov qword [free_var_141], rax
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
.L_lambda_simple_env_loop_4fc1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fc1
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fc1
.L_lambda_simple_env_end_4fc1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fc1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fc1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fc1
.L_lambda_simple_params_end_4fc1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fc1
	jmp .L_lambda_simple_end_4fc1
.L_lambda_simple_code_4fc1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fc1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fc1:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_141]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 1
	mov rax, qword [free_var_86]
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
.L_tc_recycle_frame_loop_5d4b:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d4b
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
	jmp .L_tc_recycle_frame_loop_5d4b
.L_tc_recycle_frame_done_5d4b:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fc1:	; new closure is in rax
	mov qword [free_var_142], rax
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
.L_lambda_simple_env_loop_4fc2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fc2
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fc2
.L_lambda_simple_env_end_4fc2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fc2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fc2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fc2
.L_lambda_simple_params_end_4fc2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fc2
	jmp .L_lambda_simple_end_4fc2
.L_lambda_simple_code_4fc2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4fc2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fc2:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_140]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56ce
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_98]
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
.L_tc_recycle_frame_loop_5d4c:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d4c
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
	jmp .L_tc_recycle_frame_loop_5d4c
.L_tc_recycle_frame_done_5d4c:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56ce
	.L_if_else_56ce:
	mov rax, PARAM(0)
	.L_if_end_56ce:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4fc2:	; new closure is in rax
	mov qword [free_var_143], rax
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
.L_lambda_simple_env_loop_4fc3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fc3
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fc3
.L_lambda_simple_env_end_4fc3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fc3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fc3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fc3
.L_lambda_simple_params_end_4fc3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fc3
	jmp .L_lambda_simple_end_4fc3
.L_lambda_simple_code_4fc3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fc3
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fc3:
	enter 0, 0
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56d0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56d0
	.L_if_else_56d0:
	lea rax, [2 + L_constants]
	.L_if_end_56d0:
	cmp rax, sob_boolean_false
	je .L_if_else_56cf
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
	mov rax, qword [free_var_144]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56d1
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
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_144]
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
.L_tc_recycle_frame_loop_5d4d:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d4d
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
	jmp .L_tc_recycle_frame_loop_5d4d
.L_tc_recycle_frame_done_5d4d:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56d1
	.L_if_else_56d1:
	lea rax, [2 + L_constants]
	.L_if_end_56d1:
	jmp .L_if_end_56cf
	.L_if_else_56cf:
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56d3
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56d4
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56d4
	.L_if_else_56d4:
	lea rax, [2 + L_constants]
	.L_if_end_56d4:
	jmp .L_if_end_56d3
	.L_if_else_56d3:
	lea rax, [2 + L_constants]
	.L_if_end_56d3:
	cmp rax, sob_boolean_false
	je .L_if_else_56d2
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_137]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_137]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_144]
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
.L_tc_recycle_frame_loop_5d4e:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d4e
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
	jmp .L_tc_recycle_frame_loop_5d4e
.L_tc_recycle_frame_done_5d4e:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56d2
	.L_if_else_56d2:
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56d6
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56d7
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	jmp .L_if_end_56d7
	.L_if_else_56d7:
	lea rax, [2 + L_constants]
	.L_if_end_56d7:
	jmp .L_if_end_56d6
	.L_if_else_56d6:
	lea rax, [2 + L_constants]
	.L_if_end_56d6:
	cmp rax, sob_boolean_false
	je .L_if_else_56d5
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_126]
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
.L_tc_recycle_frame_loop_5d4f:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d4f
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
	jmp .L_tc_recycle_frame_loop_5d4f
.L_tc_recycle_frame_done_5d4f:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56d5
	.L_if_else_56d5:
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	push 2
	mov rax, qword [free_var_55]
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
.L_tc_recycle_frame_loop_5d50:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d50
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
	jmp .L_tc_recycle_frame_loop_5d50
.L_tc_recycle_frame_done_5d50:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56d5:
	.L_if_end_56d2:
	.L_if_end_56cf:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fc3:	; new closure is in rax
	mov qword [free_var_144], rax
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
.L_lambda_simple_env_loop_4fc4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fc4
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fc4
.L_lambda_simple_env_end_4fc4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fc4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fc4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fc4
.L_lambda_simple_params_end_4fc4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fc4
	jmp .L_lambda_simple_end_4fc4
.L_lambda_simple_code_4fc4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fc4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fc4:
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
	je .L_if_else_56d8
	lea rax, [2 + L_constants]
	jmp .L_if_end_56d8
	.L_if_else_56d8:
	mov rax, PARAM(0)
	push rax
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	push 2
	mov rax, qword [free_var_55]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56d9
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_16]
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
.L_tc_recycle_frame_loop_5d51:	 ; start recycle frame loop
	cmp rsi, 4
	je .L_tc_recycle_frame_done_5d51
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
	jmp .L_tc_recycle_frame_loop_5d51
.L_tc_recycle_frame_done_5d51:	 ; end recycle frame loop
	mov rbx, 3
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	jmp .L_if_end_56d9
	.L_if_else_56d9:
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
	mov rax, qword [free_var_145]
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
.L_tc_recycle_frame_loop_5d52:	 ; start recycle frame loop
	cmp rsi, 5
	je .L_tc_recycle_frame_done_5d52
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
	jmp .L_tc_recycle_frame_loop_5d52
.L_tc_recycle_frame_done_5d52:	 ; end recycle frame loop
	mov rbx, 4
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56d9:
	.L_if_end_56d8:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fc4:	; new closure is in rax
	mov qword [free_var_145], rax
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
.L_lambda_simple_env_loop_4fc5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4fc5
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fc5
.L_lambda_simple_env_end_4fc5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fc5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4fc5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fc5
.L_lambda_simple_params_end_4fc5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fc5
	jmp .L_lambda_simple_end_4fc5
.L_lambda_simple_code_4fc5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fc5
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fc5:
	enter 0, 0
	mov qword rdi, (1 + 8 + 8)
	call malloc
	mov qword [rbp + 8*(4 + 0)], rax
	mov rax, sob_void

	mov qword rdi, (1 + 8 + 8)
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
.L_lambda_simple_env_loop_4fc6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fc6
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fc6
.L_lambda_simple_env_end_4fc6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fc6:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4fc6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fc6
.L_lambda_simple_params_end_4fc6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fc6
	jmp .L_lambda_simple_end_4fc6
.L_lambda_simple_code_4fc6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fc6
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fc6:
	enter 0, 0
	mov rax, PARAM(1)
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	cmp rax, sob_boolean_false
	je .L_if_else_56da
	mov rax, PARAM(1)
	jmp .L_if_end_56da
	.L_if_else_56da:
	lea rax, [1 + L_constants]
	push rax
	mov rax, PARAM(1)
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*1]
	mov rax, qword [rax]
	push rax
	push 4
	mov rax, qword [free_var_89]
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
.L_tc_recycle_frame_loop_5d53:	 ; start recycle frame loop
	cmp rsi, 7
	je .L_tc_recycle_frame_done_5d53
	mov rcx, 6
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
	jmp .L_tc_recycle_frame_loop_5d53
.L_tc_recycle_frame_done_5d53:	 ; end recycle frame loop
	mov rbx, 6
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	.L_if_end_56da:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fc6:	; new closure is in rax
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
.L_lambda_simple_env_loop_4fc7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4fc7
	mov rcx, qword [rdi + 8 * rsi] 
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4fc7
.L_lambda_simple_env_end_4fc7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4fc7:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4fc7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4fc7
.L_lambda_simple_params_end_4fc7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4fc7
	jmp .L_lambda_simple_end_4fc7
.L_lambda_simple_code_4fc7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4fc7
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4fc7:
	enter 0, 0
	lea rax, [1 + L_constants]
	push rax
	lea rax, [128 + L_constants]
	push rax
	mov rax, PARAM(1)
	push rax
	push 2
	mov rax, PARAM(0)
	assert_closure(rax)
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	call rbx
	push rax
	mov rax, PARAM(0)
	push rax
	mov rax, qword [rbp + 8*2]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax + 8*0]
	mov rax, qword [rax]
	push rax
	push 4
	mov rax, qword [free_var_89]
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
.L_tc_recycle_frame_loop_5d54:	 ; start recycle frame loop
	cmp rsi, 7
	je .L_tc_recycle_frame_done_5d54
	mov rcx, 6
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
	jmp .L_tc_recycle_frame_loop_5d54
.L_tc_recycle_frame_done_5d54:	 ; end recycle frame loop
	mov rbx, 6
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fc7:	; new closure is in rax
	push rax
	mov rax, PARAM(1)
	pop qword [rax]
	mov rax, sob_void

	lea rax, [1 + L_constants]
	push rax
	lea rax, [529 + L_constants]
	push rax
	mov rax, qword [free_var_35]
	push rax
	mov rax, PARAM(0)
	mov rax, qword [rax]
	push rax
	push 4
	mov rax, qword [free_var_89]
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
.L_tc_recycle_frame_loop_5d55:	 ; start recycle frame loop
	cmp rsi, 7
	je .L_tc_recycle_frame_done_5d55
	mov rcx, 6
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
	jmp .L_tc_recycle_frame_loop_5d55
.L_tc_recycle_frame_done_5d55:	 ; end recycle frame loop
	mov rbx, 6
	shl rbx, 3
	neg rbx
	add rbx, rdi
	mov rsp, rbx
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4fc5:	; new closure is in rax
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