        .orig x3000
START   LD R3,SCREEN_END			; load the end of the screen
		LD R1,COLOR_START

		NOT R3,R3				; change R3 to negative (pre-computing)
		ADD R3,R3,#1

INCOLOR LD R5,SCREEN_START			; load the start of screen into R5 (address counter)

LOOP	JSR RAND				; get random color
		ADD R4,R1,#0

		ADD R5,R5,#1            ; R5 <= R5 + 1
		STR R4,R5,#0            ; mem[R5 + 0] <= R4

		ADD R0,R5,R3			; R0 <= R5 - R3
		BRnp LOOP				; go to LOOP if previous calc is not zero

		JSR INCOLOR				; if not end of screen mem, increment color and reset mem counter
		HALT					; return to os (never)

		; data ----------------

SCREEN_START .FILL xC000				; start of screen mem (+1 for example)
SCREEN_END .FILL xFDFE				; End of screen mem (-1 for example)
COLOR_START .FILL xFF00
RAND_SEED1 .FILL xFAEF
RAND_SEED2 .FILL xE129

		;;Functions ---------------

RAND	; generates a random (ish) hex number from x0000 to xFFFF, stored in R1
		LD R0,RAND_SEED1
		ADD R1,R1,R0
		ST R1,RAND_SEED1
		LD R0,RAND_SEED2
		ADD R1,R1,R0
		ST R1,RAND_SEED2
		RET

MULT	;multiplication - input R0, R1, output R2
		AND R2,R2,#0
MULTLOOP
		ADD R0,R0,#-1
		ADD R1,R1,R1
		BRp MULTLOOP
		RET
	
		.end