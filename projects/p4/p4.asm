        .orig x3000
START
		;set point group - top left = (R0,R1) - (width, height) = (R2,R3) - color = R4
		AND R0,R0,#0
		AND R1,R1,#0
		LD R2,MAP_WIDTH
		LD R3,MAP_HEIGHT		;background
		LD R4,MAP_BGD_COL
		JSR POINTG

		AND R0,R0,#0
		AND R1,R1,#0
		LD R2,MAP_WIDTH
		LD R3,MAP_WALL_WIDTH		;top wall
		LD R4,MAP_WALL_COL
		JSR POINTG

		AND R0,R0,#0
		AND R1,R1,#0
		LD R2,MAP_WALL_WIDTH
		LD R3,MAP_HEIGHT		;left wall
		LD R4,MAP_WALL_COL
		JSR POINTG

		LD R0,MAP_WIDTH
		ADD R0,R0,#-4
		AND R1,R1,#0
		LD R2,MAP_WALL_WIDTH
		LD R3,MAP_HEIGHT		;right wall
		LD R4,MAP_WALL_COL
		JSR POINTG

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
		
		JSR GETKEYQ				;get key quick

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
		;LD R0,PLAYER_POS
		;LD R1,PLAYER_Y			;clear last player pos
		;LD R2,BGD_COL
		;JSR POINT

		LD R0,PLAYER_POS
		LD R1,PLAYER_Y
		LD R2,PLAYER_WIDTH
		LD R3,PLAYER_HEIGHT		;clear player last postition
		LD R4,MAP_BGD_COL
		JSR POINTG
		
		;apply player velocity
		LD R0,PLAYER_POS
		LD R1,PLAYER_VEL
		ADD R0,R0,R1

		;check if new pos is valid
		LD R1,PLAYER_MIN_X_I
		ADD R1,R0,R1
		BRn BADPOS
		
		LD R1,PLAYER_MAX_X_I
		ADD R1,R0,R1
		BRp BADPOS

		ST R0,PLAYER_POS
BADPOS	
		
		LD R0,PLAYER_POS
		LD R1,PLAYER_Y
		LD R2,PLAYER_WIDTH
		LD R3,PLAYER_HEIGHT		;print player new postition
		LD R4,PLAYER_COL
		JSR POINTG
		

		BRnzp LOOP				;loop

;game functions --------------------


; data ----------------

SCREEN_START .FILL xC000
SCREEN_SIZEX .FILL x0080
SCREEN_SIZEX_I .FILL xFF80		; (gets inverted)
SCREEN_SIZEY .FILL x007C
SCREEN_SIZEY_I .FILL xFF84		; (gets inverted)

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

PLAYER_POS	.FILL x0024
PLAYER_Y	.FILL x0076
PLAYER_VEL	.FILL x0000
PLAYER_WIDTH	.FILL x000A
PLAYER_HEIGHT	.FILL x0004
PLAYER_MAX_X_I	.FILL xFFBA
PLAYER_MIN_X_I	.FILL xFFFC

BALL_POS_X	.FILL x0009
BALL_POS_Y	.FILL x0009
BALL_VEL_X	.FILL x0001
BALL_VEL_Y	.FILL x0001

BGD_COL .FILL x0000
PLAYER_COL	.FILL xFFFF
BLOCK_COL 	.FILL xDDDD

K_A		.FILL xFF9F				;x0061		Inverted key codes
K_D		.FILL xFF9C				;x0064

DELAY	.FILL x5000				;the delay in the program so it doesnt go so fast

MAP_WIDTH	.FILL x0054
MAP_HEIGHT	.FILL x007C
MAP_WALL_WIDTH	.FILL x0004	
MAP_BGD_COL		.FILL x1012
MAP_WALL_COL	.FILL xC000
MAP_BRICK_COL	.FILL x0463

;util functions --------------- Generally uses R0-R5

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
		ST R7,SBSTORE		; save return

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
		
		JSR POINTADDR 		;get address
		
		LD R2,R2STORE
		STR R2,R0,#0		; set color (R2) at mem[R0]
		
		LD R7,R7STORE
		RET

POINTG	;set point group - top left = (R0,R1) - (width, height) = (R2,R3) - color = R4
		ST R7,R7STORE
		
		ST R2,R2STORE
		ST R3,R3STORE		;store values for future use
		ST R4,R4STORE

		ADD R0,R0,#-1		;not sure why I need to do this
		ADD R1,R1,#-2		;its to make the position correct

		JSR POINTADDR 		;get address of top left

		;(width, height) = (R0,R1), color = R2, current address = R3, junk = R4, negative current offset = (R5,R6), y step = R7
		ADD R3,R0,#0		;address
		LD R0,R2STORE		;target width
		LD R1,R3STORE		;target height
		LD R2,R4STORE		;color
		LD R7,SCREEN_SIZEX
		AND R6,R6,#0		;height start

		ADD R1,R1,#1		;not sure why I need to do this - makes the height right

POINTGY	
		ADD R6,R6,#-1		; increment y
		ADD R3,R3,R7

		ADD R3,R3,R5		;move address back to beginning of x

		AND R5,R5,#0		; reset x

		ADD R4,R1,R6		;check if done
		BRz POINTGE
POINTGX
		ADD R5,R5,#-1		; increment x
		ADD R3,R3,#1

		STR R2,R3,#0		; set color (R2) at address (R3)

		ADD R4,R0,R5
		BRz POINTGY			; check if x is done
		BRnzp POINTGX
POINTGE
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