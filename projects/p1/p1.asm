        .orig x3000
START	LD R3,SCREEN_END		; change screen mem end to negative (pre-computing)
		NOT R3,R3				; 
		ADD R3,R3,#1			;
		ST R3,SCREEN_END		;

		LD R3,RAND_LIM
		NOT R3,R3
		ADD R3,R3,#1
		ST R3,RAND_LIM

INCOLOR LD R6,SCREEN_START			; load the start of screen into R5 (address counter)

LOOP	JSR RAND				; assign random color to mem[R6]
EXIT	ADD R6,R6,#1            ;
		STR R0,R6,#0            ;

		LD R3,SCREEN_END		; check if at the end of the screen memory
		ADD R0,R6,R3			;
		BRnp LOOP				;

		JSR INCOLOR				; increment color and reset mem counter



; data ----------------

SCREEN_START .FILL xC000
SCREEN_END .FILL xFDFE

RAND_SEED .FILL x0001
RAND_MULT .FILL xF3B4
RAND_INCR .FILL xA904
RAND_LIM .FILL x7FFF		;(gets inverted)


;Functions ---------------

RAND	; generates a random (ish) hex number from x0000 to xFFFF, stored in R0
		LD R1,RAND_SEED		;
		LD R2,RAND_MULT		; multiply seed with mult
		JSR MULT			;

		LD R1,RAND_INCR		; add increment
		ADD R0,R0,R1		;

		LD R1,RAND_LIM
		ADD R1,R0,R1
		BRn #1				;skip copy if R0 is bigger than limit
		AND R0,R1,#-1		;copy R1 to R0

		ST R0,RAND_SEED		; store

		JSR EXIT

		
MULT	;multiplication - input R1, R2, output R0 - uses R0-R5
		AND R0,R0,#0	; result
		ADD R3,R0,#1	; bit test mask
		ADD R4,R0,#-1	; end condition mask

MULT1	AND R2,R2,R4	; any bits left
		BRz MULT3			;
		AND R5,R2,R3	; test bit
		BRz MULT2			;
		ADD R0,R0,R1	; add mult to result

MULT2	ADD R1,R1,R1	; shift mult bits
		ADD R3,R3,R3	;
		ADD R4,R4,R4	;
		BRnzp MULT1		; keep going

MULT3	RET				; finished
	
		.end