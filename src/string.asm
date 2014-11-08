; --------------------------------------------
; Title:   string
; Author:  Elliot
; Date:    17/05/2012
; Version: 
; --------------------------------------------

_tempStringBuffer: 	DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

;
; A - pointer to memory
; B - word to set the memory too
; C - length of set
:memset

	; save used registers
	SET PUSH, X
	SET PUSH, Y
	SET PUSH, I
	
	; disable interupts
	IAQ 1
	IAG I
	
	; disable queueing if we are going to be a while
	IFG C, 256
	IAS 0
	
	; move the stack pointer to the memory area
	SET X, C
	SET Y, SP	
	SET SP, A
	ADD SP, X
	
.memset_loop_big_chunks
	
	IFL X, 32
	SET PC, .memset_loop_small_chunks
	
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B	
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B	
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B	
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B	
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B	
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B	
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	
	SUB X, 32	
	SET PC, .memset_loop_big_chunks	
	
.memset_loop_small_chunks
	
	IFL X, 8
	SET PC, .memset_loop_tail
	
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B
	SET PUSH, B	
	
	SUB X, 8	
	SET PC, .memset_loop_small_chunks		
	
.memset_loop_tail

	IFE X, 0
	SET PC, .memset_return
	
	SET PUSH, B
	SUB X, 1	
	SET PC, .memset_loop_tail	
	
.memset_return
	
	; restore stack
	SET SP, Y
	
	; restore interupts
	IAS I	
	IAQ 0	
	
	; restore registers	
	SET I, POP
	SET Y, POP
	SET X, POP
	
	SET PC, POP
	
	
;
; A - pointer to destination memory
; B - pointer to source memory
; C - length of copy
:memcpy

	; save used registers
	SET PUSH, X
	SET PUSH, Y
	SET PUSH, Z
	SET PUSH, I
	
	; disable interupts
	IAQ 1
	IAG I
	
	; disable queueing if we are going to be a while
	IFG C, 256
	IAS 0
	
	; move the stack pointer to the memory area
	SET X, C
	SET Y, SP	
	SET Z, B
	ADD Z, C
	SET SP, A
	ADD SP, X
	
.memcpy_loop_big_chunks
	
	IFL X, 32
	SET PC, .memcpy_loop_small_chunks
	
	SUB Z, 32
	SET PUSH, [Z+31]
	SET PUSH, [Z+30]
	SET PUSH, [Z+29]
	SET PUSH, [Z+28]
	SET PUSH, [Z+27]
	SET PUSH, [Z+26]
	SET PUSH, [Z+25]
	SET PUSH, [Z+24]
	SET PUSH, [Z+23]
	SET PUSH, [Z+22]
	SET PUSH, [Z+21]
	SET PUSH, [Z+20]
	SET PUSH, [Z+19]
	SET PUSH, [Z+18]
	SET PUSH, [Z+17]
	SET PUSH, [Z+16]
	SET PUSH, [Z+15]
	SET PUSH, [Z+14]
	SET PUSH, [Z+13]
	SET PUSH, [Z+12]
	SET PUSH, [Z+11]
	SET PUSH, [Z+10]
	SET PUSH, [Z+9]
	SET PUSH, [Z+8]
	SET PUSH, [Z+7]
	SET PUSH, [Z+6]
	SET PUSH, [Z+5]
	SET PUSH, [Z+4]
	SET PUSH, [Z+3]
	SET PUSH, [Z+2]
	SET PUSH, [Z+1]
	SET PUSH, [Z]
	
	SUB X, 32	
	SET PC, .memcpy_loop_big_chunks	
	
.memcpy_loop_small_chunks
	
	IFL X, 8
	SET PC, .memcpy_loop_tail
	
	SUB B, 8
	SET PUSH, [Z+7]
	SET PUSH, [Z+6]
	SET PUSH, [Z+5]
	SET PUSH, [Z+4]
	SET PUSH, [Z+3]
	SET PUSH, [Z+2]
	SET PUSH, [Z+1]
	SET PUSH, [Z]
	
	SUB X, 8	
	SET PC, .memcpy_loop_small_chunks		
	
.memcpy_loop_tail

	IFE X, 0
	SET PC, .memcpy_return
	
	SUB B, 1
	SET PUSH, [Z]
	SUB X, 1	
	SET PC, .memcpy_loop_tail	
	
.memcpy_return
	
	; restore stack
	SET SP, Y
	
	; restore interupts
	IAS I	
	IAQ 0	
	
	
	; restore registers	
	SET I, POP
	SET Z, POP
	SET Y, POP
	SET X, POP
	
	SET PC, POP
	

; A destination
; B source
:strcpy

	SET PUSH, X
	SET PUSH, Y
	
	SET X, A
	SET Y, B

.strcpy_loop

	IFE [Y], 0
	SET PC, .strcpy_return
	SET [X], [Y]
	ADD X, 1
	ADD Y, 1
	SET PC, .strcpy_loop
	
.strcpy_return
	
	; restore registers	
	SET Y, POP
	SET X, POP
	
	SET PC, POP	
