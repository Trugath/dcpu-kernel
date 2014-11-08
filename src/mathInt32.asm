;
; little-endian 32 bit integer math
;

; A - pointer to Value A, B - pointer to value B
; 
:uint32_add
	ADD [A], [B]
	ADD [A+1], EX
	ADD [A+1], [B+1]
	SET PC, POP