	; clear the odd start of the heap
	SET B, _heap
	MOD B, 16
	SET A, _heap
	SUB A, B
	ADD A, 16
	SET B, _heap
	
_clearmemorysmallloophead:
	SET [B],	0
	ADD B, 1
	IFN B, A
	SET PC, _clearmemorysmallloophead		
	
	;clear the word aligned part of the heap
	
	SET B, SP
	MOD B, 16
	SET C, SP
	SUB C, B
	
_clearmemorybigloop:	
	SET [A], 	0
	SET [A+1], 	0
	SET [A+2], 	0
	SET [A+3], 	0
	SET [A+4], 	0
	SET [A+5], 	0
	SET [A+6], 	0
	SET [A+7], 	0	
	SET [A+8], 	0
	SET [A+9], 	0
	SET [A+10], 0
	SET [A+11], 0
	SET [A+12], 0
	SET [A+13], 0
	SET [A+14], 0
	SET [A+15], 0		
	ADD A, 16
	IFG C, A
	SET PC, _clearmemorybigloop	
	
	; clear out the end of the heap
	SET [A],	0
	
_clearmemorysmalllooptail:
	ADD A, 1
	SET [A],	0	
	IFN A, SP
	SET PC, _clearmemorysmalllooptail		