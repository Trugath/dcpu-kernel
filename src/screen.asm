;
;
;

:_screenPrintColour		DAT 0xf000
:_screenHardwareCount	DAT 0
:_screenHardwareID		DAT -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
:_screenHardwareMemory  DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

;  inputs: None
; outputs: None
:initScreen

	; Save used registers
	SET PUSH, A
	SET PUSH, B
	SET PUSH, C
	SET PUSH, X
	SET PUSH, Y
	SET PUSH, I

	; get the hardware id of the first screen
	HWN I				; set I to number of devices
._initScreenLoop
	SUB I, 1			; first device is <number of devices> - 1
	HWQ I				; query the device
	IFE I, -1			; device -1 means run out of devices
	SET PC, ._initScreenLoopEnd	; no screen is attached?
	IFE A, 0xf615			; check first part of the hardware id
	IFE B, 0x7349			; check second part of the hardware id
	SET PC, ._initScreenLoopEnd	; found one
	SET PC, ._initScreenLoop	; if it doesn't match screen, check the next device

._initScreenLoopEnd

	; if the hardware id is -1 then we have no screen, so skip setup
	IFE I, -1
	SET PC, ._initScreenReturn

	; set the screen id
	SET A, _screenHardwareID
	ADD A, [_screenHardwareCount]
	SET [A], I

	; set the screen memory
	SET A, _screenHardwareMemory  
	ADD A, [_screenHardwareCount]
	SET [A], 0x8000

	; setup the screen with default video ram at 0x8000
	SET A, 0
	SET B, 0x8000
	HWI I

	; next screen
	ADD [_screenHardwareCount], 1
	SET PC, ._initScreenLoop

._initScreenReturn

	; restore used registers
	SET I, POP
	SET Y, POP
	SET X, POP
	SET C, POP
	SET B, POP
	SET A, POP

	; return
	SET PC, POP


; helper function, useless overhead, but included for completness
;  inputs: None
; outputs: returns the number of screens in the A register
:getScreenCount

	SET A, [_screenHardwareCount]
	SET PC, POP

;
;  inputs: A - Screen ID, B - Memory location
; outputs: none
:setScreenMemory

	; no known screens? return
	IFE [_screenHardwareCount], 0
	SET PC, POP

	; Save used registers
	SET PUSH, C
	
	; is the requested screen known?
	SET C, [_screenHardwareCount]
	SUB C, 1
	IFG A, C
	SET PC, ._setScreenMemoryReturn

	; adjust the screen ID to the hardware ID
	ADD A, _screenHardwareID
	SET C, [A]	

	; setup the screen with requested video memory (B set correctly)
	SET A, 0
	HWI C

._setScreenMemoryReturn

	; restore used registers
	SET C, POP

	; return
	SET PC, POP

; helper function
;
;  inputs: A - ScreenID
; outputs: B - Memory Location
:getScreenMemory

	; default to 0
	SET B, 0

	; no known screens? return
	IFE [_screenHardwareCount], 0
	SET PC, POP

	; Save used registers
	SET PUSH, C
	
	; is the requested screen known?
	SET C, [_screenHardwareCount]
	SUB C, 1
	IFG A, C
	SET PC, ._getScreenMemoryReturn

	; get the memory location
	SET C, _screenHardwareMemory  
	ADD C, A
	SET B, [C]

._getScreenMemoryReturn

	; restore used registers
	SET C, POP

	; return
	SET PC, POP

;
; A - ScreenID
; B - String location
:print

	; save string location
	SET PUSH, C
	SET PUSH, X
	
	SET C, B
	SET X, [_screenPrintColour]

	; get the memory location to B
	JSR getScreenMemory
	
.print_loop

	IFE [C], 0
	SET PC, .print_return
	
	SET [B], [C]
	BOR [B], X
	ADD B, 1
	ADD C, 1
	SET PC, .print_loop
	
.print_return	
	
	SET X, POP
	SET C, POP
	SET PC, POP
	