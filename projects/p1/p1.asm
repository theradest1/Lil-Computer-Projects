        .orig x3000
START
		LD R3,RAND_LIM			;
		NOT R3,R3				;
		ADD R3,R3,#1			;
		ST R3,RAND_LIM			;
		
		LD R3,SCREEN_SIZE_I		;
		NOT R3,R3				;
		ADD R3,R3,#1			;
		ST R3,SCREEN_SIZE_I		;

LOOP0	AND R5,R5,#0			; reset y
		ADD R5,R5,#-1
LOOP1	ADD R5,R5,#1			; step y

		LD R0,SCREEN_SIZE_I		;
		ADD	R0,R5,R0			; reset y if y = screen_size
		ADD R0,R0,#-1			;
		BRz LOOP0				;

		AND R6,R6,#0			; reset x
		ADD R6,R6,#-1			;
LOOP2	ADD R6,R6,#1			; step x

		LD R0,SCREEN_SIZE_I		;
		ADD	R0,R6,R0			; reset 6 & increment y if x = screen_size
		ADD R0,R0,#-1			;
		BRz LOOP1				;		

		ST R5,R5STORE			;
		JSR RAND				; get random color
		LD R5,R5STORE			;

		AND R2,R0,#-1			;
		AND R1,R5,#-1			;
		AND R0,R6,#-1			; put point at (R5,R6) with color R2
		ST R5,R5STORE			;
		JSR POINT				;
		LD R5,R5STORE			;

		JSR LOOP2				;go back to start of y loop




; data ----------------




SCREEN_START .FILL xC000
SCREEN_SIZE .FILL x0080
SCREEN_SIZE_I .FILL x0080		; (gets inverted)

RAND_SEED .FILL x0001			; stuff for random nums
RAND_MULT .FILL x0002			;
RAND_INCR .FILL xD900			;
RAND_LIM .FILL x7FFF			; (gets inverted)

R0STORE	.FILL x0000				;
R1STORE	.FILL x0000				;
R2STORE	.FILL x0000				;
R3STORE	.FILL x0000				; when register-heavy tasks are done I can store them here
R4STORE	.FILL x0000				;
R5STORE	.FILL x0000				;
R6STORE	.FILL x0000				;




;Functions --------------- Generally uses R0-R5




POINT	;sets point (R0,R1) on screen to color (R2), outputs point's address (R0)

		ST R0,R0STORE		; save values
		ST R2,R2STORE		;

		LD R2,SCREEN_SIZE	; R1 is already Y value
		AND R0,R0,#0		; 
		ADD R3,R0,#1		; 
		ADD R4,R0,#-1		; 	
POINT1	AND R2,R2,R4		;
		BRz POINT3			;
		AND R5,R2,R3		; multiply hight with screen size
		BRz POINT2			; explinations are in mult subroutine
		ADD R0,R0,R1		; did't just call the subroutine because return is lost
POINT2	ADD R1,R1,R1		;	 
		ADD R3,R3,R3		;
		ADD R4,R4,R4		;
		BRnzp POINT1		;
POINT3						;
		
		AND R1,R0,#-1		;
		LD R0,R0STORE		; load address and color
		LD R2,R2STORE		;
		ADD R0,R0,R1		;
		LD R1,SCREEN_START
		ADD R0,R0,R1
		
		STR R2,R0,#0		; set color (R2) at mem[R0]

		RET




RAND	; generates a random (ish) hex number from x0000 to x7FFF, stored in R0
		LD R1,RAND_SEED		;
		LD R2,RAND_MULT		; 
		AND R0,R0,#0		; 
		ADD R3,R0,#1		; 
		ADD R4,R0,#-1		; 
RAND1	AND R2,R2,R4		;
		BRz RAND3			;
		AND R5,R2,R3		; multiply seed with mult
		BRz RAND2			; explinations are in mult subroutine
		ADD R0,R0,R1		; did't just call the subroutine because return is lost
RAND2	ADD R1,R1,R1		;	 
		ADD R3,R3,R3		;
		ADD R4,R4,R4		;
		BRnzp RAND1			;
RAND3						;

		LD R1,RAND_INCR		; add increment
		ADD R0,R0,R1		;

		LD R1,RAND_LIM		; 
		ADD R1,R0,R1		; wrap if bigger than RAND_LIM
		BRn #1				;
		AND R0,R1,#-1		;

		ST R0,RAND_SEED		; store seed

		RET

		


MULT	;multiplication - input R1, R2, output R0
		AND R0,R0,#0	; result
		ADD R3,R0,#1	; bit test mask
		ADD R4,R0,#-1	; end condition mask	

MULT1	AND R2,R2,R4	; any bits left
		BRz MULT3		;
		AND R5,R2,R3	; test bit
		BRz MULT2		;
		ADD R0,R0,R1	; add mult to result

MULT2	ADD R1,R1,R1	; shift mult bits
		ADD R3,R3,R3	;
		ADD R4,R4,R4	;
		BRnzp MULT1		; keep going

MULT3	RET				; finished
	



		.end