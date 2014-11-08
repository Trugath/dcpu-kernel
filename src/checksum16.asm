;
; 16 bit checksum
;

;
; hash 1, ELF hash varient
;
; Inputs: 	A = pointer, B = data length
; outputs: 	B = checksum
:hash16ELF

	; save used registers
	SET PUSH, C
	SET PUSH, X
	SET PUSH, Y
	SET PUSH, Z
	SET PUSH, I

	;
	; *C = A
	; X = 0
	;
	SET C, A
	SET X, 0

	;
	; I = 0
	;
	SET I, 0
._hash16ELF_loop	
	
	;
	; X = ( X << 4 ) + [C]
	;
	SHL X, 4
	ADD X, [C]

	;
	; Y = X & 0xf000
	;
	SET Y, X
	AND Y, 0xf000	

	;
	; if ( Y != 0 )
	;
	IFE Y, 0
	SET PC, ._hash16ELF_loop_jmp

	; {
	;	X ^= Y >> 12
	; }
	SET Z, Y
	SHR Z, 12
	XOR X, Z	

._hash16ELF_loop_jmp

	;
	; X &= ~Y;
	;
	SET Z, Y
	XOR Z, 0xffff
	AND X, Z

	;
	; ++I, ++C
	;
	ADD I, 1
	ADD C, 1

	;
	; until ( I >= B )
	;
	IFL I, B
	SET PC, ._hash16ELF_loop

	; return BS as result
	SET B, X

	; restore registers
	SET I, POP
	SET Z, POP
	SET Y, POP
	SET X, POP
	SET C, POP
	SET PC, POP