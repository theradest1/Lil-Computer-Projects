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
		LD R0,DELAY
DELAYL	ADD R0,R0,#-1			; a delay so that the game is slower
		BRp DELAYL

		;key press
		LDI R0,KB_STE
		BRnp #3				;skip key stuff and set vel to 0 if status is zero
		AND R0,R0,#0
		ST R0,PLAYER_VEL
		BRnzp ENDKEY
		
		JSR GETKEYQ

		;R0 = pressed key, R1 = tested key, R2 = new velocity

		AND R2,R2,#0			;set new player vel to 0
		
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
		;clear last player pos
		LD R0,PLAYER_POS
		LD R1,PLAYER_Y
		LD R2,BGD_COL
		JSR POINT
		
		;apply player velocity
		LD R0,PLAYER_POS
		LD R1,PLAYER_VEL
		ADD R0,R0,R1
		ST R0,PLAYER_POS
		
		;print new player pos
		LD R0,PLAYER_POS
		LD R1,PLAYER_Y
		LD R2,PLAYER_COL
		JSR POINT
		

		BRnzp LOOP				;loop

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
R7STORE	.FILL x0000				;

SBSTORE .FILL x0000				; store R7 here when nesting subroutines (for subroutines like print point)
UTSTORE	.FILL x0000				; store R7 here when nesting subroutines (for utilities like multiply)

KB_DATA .FILL xFE02				;key press data
KB_STE  .FILL xFE00				;key press state
DI_DATA .FILL xFE06				;print mem address

PLAYER_POS	.FILL x0005
PLAYER_Y	.FILL x0005;78
PLAYER_VEL	.FILL x0000

BALL_POS_X	.FILL x0009
BALL_POS_Y	.FILL x0009
BALL_VEL_X	.FILL x0001
BALL_VEL_Y	.FILL x0001

BGD_COL .FILL x0000
PLAYER_COL	.FILL xFFFF

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

PRINT	; prints R0 to the console
		STI R0,DI_DATA
		RET

POINTADDR	;get the address from a point on the screen (R0,R1)
		ST R0,R0STORE		; save x value
		ST R7,SBSTORE		;save return

		LD R2,SCREEN_SIZEX	; R1 is already Y value
		JSR MULT
		
		AND R1,R0,#-1		; move address to R1
		LD R0,R0STORE		; add x (R0)
		ADD R0,R0,R1		;
		LD R1,SCREEN_START	;add the screen start address
		ADD R0,R0,R1		;
		
		LD R7,SBSTORE		;load return
		RET
		

POINT	;sets point (R0,R1) on screen to color (R2), outputs point's address (R0)
		ST R7,R7STORE
		ST R2,R2STORE
		
		JSR POINTADDR 	;get address
		
		LD R2,R2STORE
		STR R2,R0,#0		; set color (R2) at mem[R0]
		
		LD R7,R7STORE
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


		.end				; KEEP AT THE END - errors from me being dumb and forgetting so far = 3