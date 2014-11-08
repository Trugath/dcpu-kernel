; --------------------------------------------
; Title:   string
; Author:  Elliot
; Date:    17/05/2012
; Version: 
; --------------------------------------------

:_interruptHandlerjumpTable
	DAT .nullHandler
	DAT .clockHandler

:_interruptHandlerCount DAT 1

; used to calculate missed ticks
:_lastClockTick DAT 0

; 64 bit little endian
:_tickCount 	DAT 0, 0, 0, 0

:interruptHandler
	
	; invalid interrupt filter
	IFG A, [_interruptHandlerCount]
	RFI 0
	
	; save registers
	SET PUSH, B
	
	; jump table
	SET B, _interruptHandlerjumpTable
	ADD B, A
	JSR [B]
	
.interruptHandlerReturn
	SET B, POP
	RFI 0

.nullHandler
	SET PC, POP	
	
; handler for the clock interupt
.clockHandler

	SET PUSH, C
	
	; get elapsed ticks in C register
	JSR getTickCount
	SUB C, [_lastClockTick]
	ADD [_lastClockTick], C
	
	; increment the 64bit tick counter ( 32 bit was 2 years ish, so i bammed it up a notch (or two) )
	ADD [_tickCount], C
	ADD [_tickCount+1], EX
	ADD [_tickCount+2], EX
	ADD [_tickCount+3], EX
	
	SET C, POP
	
	SET PC, POP