        .orig x3000
START	LD R3,SCREEN_SIZEX_I	;
		NOT R3,R3				;
		ADD R3,R3,#1			;
		ST R3,SCREEN_SIZEX_I	;

		LD R3,SCREEN_SIZEY_I	;
		NOT R3,R3				;
		ADD R3,R3,#1			;
		ST R3,SCREEN_SIZEY_I	;

		LD R3,RAND_LIM			;
		NOT R3,R3				;
		ADD R3,R3,#1			;
		ST R3,RAND_LIM			;

		AND R1,R1,#0
WAIT	JSR GETKEYQ
		ADD R1,R1,#1			;get random seed from player delay at start
		AND R0,R0,#-1
		BRz WAIT
		ST R1,RAND_SEED

LOOP
		LD R0,DELAY
DELAYL	ADD R0,R0,#-1			; a delay so that the game is a little slower
		BRp DELAYL

		;key press
		LDI R0,KB_STE
		BRz ENDKEY				;skip key finding if status is zero
		JSR GETKEYQ

		;R0 = pressed key, R1 = tested key, R2 = new velocity

		AND R2,R2,#0
		
		LD R1,K_A
		ADD R1,R0,R1			; A (left)
		BRnp #2
		ADD R2,R2,#-1
		ST R2,PLAYER_VEL

		LD R1,K_D
		ADD R1,R0,R1			; D (right)
		BRnp #2
		ADD R2,R2,#1
		ST R2,PLAYER_VEL

ENDKEY
		;past x pos = R0, past y pos = R1, new x pos = R3, new y pos = R4

		

		JSR LOOP				;loop

;game functions --------------------


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

SBSTORE .FILL x0000				; store R7 here when nesting subroutines (for subroutines like print point)
UTSTORE	.FILL x0000				; store R7 here when nesting subroutines (for utilities like multiply)

KB_DATA .FILL xFE02				;key press data
KB_STE  .FILL xFE00				;key press state
DI_DATA .FILL xFE06				;print mem address

PLAYER_POS	.FILL x0005
PLAYER_VEL	.FILL x0000

BALL_POS_X	.FILL x0009
BALL_POS_Y	.FILL x0009
BALL_VEL_X	.FILL x0001
BALL_VEL_Y	.FILL x0001

BGD_COL .FILL x0000
BGD_COL_I .FILL x0000

K_A		.FILL xFF9F				;x0061		Inverted key codes
K_D		.FILL xFF9C				;x0064

DELAY	.FILL x5000				;the delay in the program so it doesnt go so fast

;util functions --------------- Generally uses R0-R5

DEATH	TRAP x25

GETKEYW	;get key wait - in R0
		LDI R0,KB_STE		; wait for a keystroke
		BRzp GETKEYW
		LDI R0,KB_DATA		; read it and return
		RET

GETKEYQ	;get key quick - in R0
		LDI R0,KB_DATA		; read it and return
		RET

PRINT	; idk yet - uses data in R0
		STI R0,DI_DATA
		RET
		
POINTADDR	;gets address at point (R0,R1), outputs address in R0
		
		ST R0,R0STORE		; save values
		ST R2,R2STORE		;

		LD R2,SCREEN_SIZEX	; R1 is already Y value
		AND R0,R0,#0		; 
		ADD R3,R0,#1		; 
		ADD R4,R0,#-1		; 	
PNTAD1	AND R2,R2,R4		;
		BRz PNTAD3			;
		AND R5,R2,R3		; multiply hight with screen size
		BRz PNTAD2			; explinations are in mult subroutine
		ADD R0,R0,R1		; should move this to the mult subroutine, but I'm lazy
PNTAD2	ADD R1,R1,R1		;	 
		ADD R3,R3,R3		;
		ADD R4,R4,R4		;
		BRnzp PNTAD1		;
PNTAD3						;
		
		AND R1,R0,#-1		;
		LD R0,R0STORE		; load address and color
		LD R2,R2STORE		;
		ADD R0,R0,R1		;
		LD R1,SCREEN_START
		ADD R0,R0,R1

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
		ADD R0,R0,R1		; should move this to the mult subroutine, but I'm lazy
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


		.end				; KEEP AT THE END - errors from me being dumb and forgetting so far = 3