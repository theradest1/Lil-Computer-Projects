        .orig x3000
START	LD R3,SCREEN_SIZEX_I	;
		NOT R3,R3				;
		ADD R3,R3,#1			;
		ST R3,SCREEN_SIZEX_I	;

		LD R3,SCREEN_SIZEY_I	;
		NOT R3,R3				;
		ADD R3,R3,#1			;
		ST R3,SCREEN_SIZEY_I	;

LOOP
		JSR GETKEY
		JSR PRINT
		JSR LOOP				;go to loop




; data ----------------




SCREEN_START .FILL xC000
SCREEN_SIZEX .FILL x0080
SCREEN_SIZEX_I .FILL x0080		; (gets inverted)
SCREEN_SIZEY .FILL x007C
SCREEN_SIZEY_I .FILL x007C		; (gets inverted)

R0STORE	.FILL x0000				;
R1STORE	.FILL x0000				;
R2STORE	.FILL x0000				;
R3STORE	.FILL x0000				; when register-heavy tasks are done I can store them here
R4STORE	.FILL x0000				;
R5STORE	.FILL x0000				;
R6STORE	.FILL x0000				;

KB_DATA .FILL xFE02				;key press data
DI_DATA .FILL xFE06				;print mem address




;Functions --------------- Generally uses R0-R5

GETKEY	;gets key - in R0
		LDI R0,KB_DATA			;get keypress
		RET

PRINT	; idk yet - uses data in R0
		STI R0,DI_DATA
		RET
		


POINT	;sets point (R0,R1) on screen to color (R2), outputs point's address (R0)

		ST R0,R0STORE		; save values
		ST R2,R2STORE		;

		LD R2,SCREEN_SIZEX	; R1 is already Y value
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

		.end