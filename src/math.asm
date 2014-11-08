;
; 16 bit integer math
;

; 16 bit Integer square root
;
;unsigned int isqrt( unsigned int x ) {
;   unsigned int a, y, b;
;
;   a = 0x4000;
;   y = 0;
;   while(a != 0) {              // Do 8 times.
;      b = y | a;
;      y = y >> 1;
;      if (x >= b) {
;         x = x - b;
;         y = y | a;
;      }
;      a = a >> 2;
;   }
;   return y;
;}

; Inputs - X number to be square rooted
; Outputs - X result
;
; 91-107 ops, 21 words in size
;
biscuit_math_isqrt:

	SET PUSH, A						; 1
	SET PUSH, B						; 1
	SET PUSH, Y						; 1

	SET A, 0x4000						; 2
	SET Y, 0						; 1

		SET B, Y					; 1
		BOR B, A					; 1
		SHR Y, 1					; 1
	
		IFL X, B					; 2
		ADD PC, 2					; 1
			SUB X, B				; 	1
			BOR Y, A				; 	1
		SHR A, 2					; 1

		IFN A, 0					; 2
		SUB PC, 10					; 1
								; 8 loops, +3 overhead 
								; ops = ( ( 7 to 9 ) + 3 ) * 8
		
	SET X, Y						; 1
	
	SET Y, POP						; 1
	SET B, POP						; 1
	SET A, POP						; 1

	; return
	SET PC, POP						; 1
	
; Inputs - X number to be square rooted
; Outputs - X result
;
; unrolled to save 24 ops of loop overhead
;
; 67 to 83 ops, 74 words in size
;
biscuit_math_isqrt_unrolled:

	SET PUSH, A						; 1
	SET PUSH, B						; 1
	SET PUSH, Y						; 1

	SET A, 0x4000						; 2
	SET Y, 0						; 1

	SET B, Y						; 1
	BOR B, A						; 1
	SHR Y, 1						; 1
		
	IFL X, B						; 2
	ADD PC, 2						; 1
		SUB X, B					; 	1
		BOR Y, A					; 	1
	SHR A, 2						; 1
		
	SET B, Y						; 1
	BOR B, A						; 1
	SHR Y, 1						; 1
		
	IFL X, B						; 2
	ADD PC, 2						; 1
		SUB X, B					; 	1
		BOR Y, A					; 	1
	SHR A, 2						; 1
		
	SET B, Y						; 1
	BOR B, A						; 1
	SHR Y, 1						; 1
		
	IFL X, B						; 2
	ADD PC, 2						; 1
		SUB X, B					; 	1
		BOR Y, A					; 	1
	SHR A, 2						; 1
		
	SET B, Y						; 1
	BOR B, A						; 1
	SHR Y, 1						; 1
		
	IFL X, B						; 2
	ADD PC, 2						; 1
		SUB X, B					; 	1
		BOR Y, A					; 	1
	SHR A, 2						; 1
		
	SET B, Y						; 1
	BOR B, A						; 1
	SHR Y, 1						; 1
		
	IFL X, B						; 2
	ADD PC, 2						; 1
		SUB X, B					; 	1
		BOR Y, A					; 	1
	SHR A, 2						; 1
		
	SET B, Y						; 1
	BOR B, A						; 1
	SHR Y, 1						; 1
		
	IFL X, B						; 2
	ADD PC, 2						; 1
		SUB X, B					; 	1
		BOR Y, A					; 	1
								
	SET B, Y						; 1
	BOR B, A						; 1
	SHR Y, 1						; 1
		
	IFL X, B						; 2
	ADD PC, 2						; 1
		SUB X, B					; 	1
		BOR Y, A					; 	1
	SHR A, 2						; 1
		
	SET B, Y						; 1
	BOR B, A						; 1
	SHR Y, 1						; 1
		
	IFL X, B						; 2
	ADD PC, 2						; 1
		SUB X, B					; 	1
		BOR Y, A					; 	1
	SHR A, 2						; 1
		
	SET X, Y						; 1
	
	SET Y, POP						; 1
	SET B, POP						; 1
	SET A, POP						; 1

	; return
	SET PC, POP						; 1