;
; 8.8 fixed point math
;
;
; 0000000100000000b * 0000000100000000b = 1 0000000000000000b
; 1 * 1 = 1 
; ( 0000000100000000b * 0000000100000000b ) >> 8 = 0000000100000000b
; multiplies need a 8 shift right ( / 256 )
;
; 0000000100000000b / 0000000100000000b = 1
; 1 / 1 = 1 
; ( 0000000100000000b / 0000000100000000b ) << 8 = 0000000100000000b 
; divides need a 8 shift left ( * 256)


; Inputs: A - first 8.8, B - second 8.8
; outputs: A - result
;
:mathFixed16_MLI
	
	SET PUSH, C

	MLI A, B 	; multiply two values
	SET C, EX	; take the overflow into C
	SHL C, 8	; the overflow is an integer, so make it 8.8
	SHR A, 8	; the A register is the fraction, make it 8.8
	ADD A, C	; add them together

	SET C, POP
	SET PC, POP

; Inputs: A - first 8.8, B - second 8.8
; outputs: A - result
;
:mathFixed16_DVI
	
	SET PUSH, C

	DVI A, B	; divide the two valies
	SET C, EX	; take the underflow into C
	SHR C, 8	; the underflow is fractional part
	SHL A, 8	; A is the integer part
	ADD A, C	; add together

	SET C, POP
	SET PC, POP