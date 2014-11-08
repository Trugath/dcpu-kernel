; --------------------------------------------
; Title:   main
; Author:  Elliot
; Date:    12/05/2012
; Version: 
; --------------------------------------------

	;this is the copy protection code and will be wiped post-boot
	SET A, _biscuit_OS_code_start
	SET B, heapfirst
	SUB B, _biscuit_OS_code_start
	JSR hash16ELF
	
	; checksum the release
	IFN B, 0x0C1B
	SET PC, _halt

	SET PC, _biscuit_init
	DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	
:_biscuit_OS_code_start

_bootmessage1: 		DAT "Booting", 0
_bootmessage2: 		DAT "Please Wait.", 0
_bootmessage3:		DAT "Memory Check    %"
_bootmessage5: 		DAT "Done", 0
_videoramPtr: 		DAT 0
_OSStackSize:		DAT 64

_biscuit_init:

	;remove copy protection
	SET A, 0
	SET B, 0
	SET C, _biscuit_OS_code_start
	JSR memset
	
	; clear registers
	SET A, 0
	SET B, 0
	SET C, 0
	SET X, 0
	SET Y, 0
	SET Z, 0
	SET I, 0
	SET J, 0
	SET SP, 0
	SET EX, 0
	IAS 0
	
	; init the clock hardware
	JSR initClock

	; set the interrupt handler
	IAS interruptHandler
	INT 0
	
	; init the screen hardware (this points all screens at 0x8000)
	JSR initScreen
	
	; clear memory
	SET A, heapfirst
	SET B, 0
	SET C, 0xffff
	SUB C, heapfirst
	SUB C, [_OSStackSize]
	JSR memset
	
	; setup the heap
	SET X, 0xffff
	SUB X, heapfirst
	SUB X, [_OSStackSize]	
	JSR heapsetup
	
	; allocate video ram
	SET X, 384
	JSR heapalloc
	SET [_videoramPtr], A
	
	; clear vram
	SET A, [_videoramPtr]
	SET B, 0
	SET C, 384
	JSR memset
	
	; point all the screens at this
	JSR getScreenCount
	SET B, [_videoramPtr]
._init_Graphics_loop
	IFE A, 0
	SET PC, ._init_Graphics_loop_end	
	SUB A, 1
	JSR setScreenMemory
._init_Graphics_loop_end		

; test math
	SET X, 16384
	JSR biscuit_math_isqrt
	
_halt:
	SET PC, _halt
