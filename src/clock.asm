;
;
;

:_clockHardwareID	DAT -1
:_clockFrequency	DAT 1

;  inputs: None
; outputs: None
:initClock

	; Save used registers
	SET PUSH, A
	SET PUSH, B
	SET PUSH, C
	SET PUSH, X
	SET PUSH, Y
	SET PUSH, I

	; get the hardware id of the clock
	HWN I		; set I to number of devices
._initClockLoop
	SUB I, 1			; first device is <number of devices> - 1
	HWQ I				; query the device
	IFE I, -1			; device -1 means run out of devices
	SET PC, ._initClockLoopEnd	; no clock is attached?
	IFE A, 0xb402			; check first part of the hardware id
	IFE B, 0x12d0			; check second part of the hardware id
	SET PC, ._initClockLoopEnd	; found one
	SET PC, ._initClockLoop		; if it doesn't match generic clock, check the next device

._initClockLoopEnd
	SET [_clockHardwareID], I

	; if the hardware id is -1 then we have no clock, so skip setup
	IFE I, -1
	SET PC, ._initClockReturn

	; start the clock with resolution 60 ticks/second
	SET A, 0
	SET B, [_clockFrequency]
	HWI [_clockHardwareID]
	
	; clock interrupt is 1
	SET A, 2
	SET B, 1
	HWI [_clockHardwareID]	

._initClockReturn

	; restore used registers
	SET I, POP
	SET Y, POP
	SET X, POP
	SET C, POP
	SET B, POP
	SET A, POP

	; return
	SET PC, POP

;  inputs: None
; outputs: None
:resetClock

	; not inited, or not attached
	IFE [_clockHardwareID], 0xffff
	SET PC, POP

	; save used registers
	SET PUSH, A
	SET PUSH, B

	; reset the clock
	SET A, 0
	SET B, [_clockFrequency]
	HWI [_clockHardwareID]

	; restore used registers	
	SET B, POP
	SET A, POP

	; return
	SET PC, POP


;  inputs: None
; outputs: C Register containing elapsed ticks

:getTickCount

	; default to 0
	SET C, 0

	; not inited, or not attached
	IFE [_clockHardwareID], 0xffff
	SET PC, POP

	; save used registers
	SET PUSH, A

	; get the tick count
	SET A, 1
	HWI [_clockHardwareID]
	; C Register now contains elapsed ticks

	; restore used register
	SET A, POP

	;Return with C register as elapsed ticks
	SET PC, POP
	
:sleep