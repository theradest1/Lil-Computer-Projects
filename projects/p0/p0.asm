        .orig x2FFF				; 1 value earlier than usual for start mem
		.FILL x0001				; put the inverted end value at this mem location
		.FILL xC000				; start of screen mem
START   LD R2,#-2				; load the start of screen into R2
		LD R3,#-4				; load the inv-end of the screen into R3
		ADD R4,R4,#5
CORLOOP	ADD R2,R2,#1            ; R2 <= R2 + 1
		ADD R4,R2,#1
		STR R4,R2,#0            ; set address in R2 to R4 (corrupt the mem yay!)
		ADD R3,R2,R3			; add current mem and inv-screen end to see if 
		BRz START				; go to start if end of screen
        JSR CORLOOP				; jump to loop
		HALT                    ; return to os
	.end
        