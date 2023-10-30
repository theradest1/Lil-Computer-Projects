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

		LD R0,BLOCK1_X
		LD R1,BLOCK_Y
		LD R2,BLOCK_WIDTH
		LD R3,BLOCK_HEIGHT		;block 1
		LD R4,BLOCK_COL
		JSR POINTG

		LD R0,BLOCK2_X
		LD R1,BLOCK_Y
		LD R2,BLOCK_WIDTH
		LD R3,BLOCK_HEIGHT		;block 2
		LD R4,BLOCK_COL
		JSR POINTG

		LD R0,BLOCK3_X
		LD R1,BLOCK_Y
		LD R2,BLOCK_WIDTH
		LD R3,BLOCK_HEIGHT		;block 3
		LD R4,BLOCK_COL
		JSR POINTG

LOOP
		LD R0,DELAY
DELAYL	ADD R0,R0,#-1			; a delay so that the game isnt so fast
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
		LD R3,PLAYER_SPEED
		LD R4,PLAYER_SPEED_I

		LD R1,K_A
		ADD R1,R0,R1			; A (left)
		BRnp #2
		ADD R2,R2,R4
		ST R2,PLAYER_VEL

		LD R1,K_D
		ADD R1,R0,R1			; D (right)
		BRnp #2
		ADD R2,R2,R3
		ST R2,PLAYER_VEL
		
ENDKEY
		;player
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
		ADD R1,R0,R1				;min
		BRn BADPOS
		
		LD R1,PLAYER_MAX_X_I
		ADD R1,R0,R1				;max
		BRp BADPOS					

		ST R0,PLAYER_POS			;store if valid
BADPOS	
		;print player new postition
		LD R0,PLAYER_POS
		LD R1,PLAYER_Y
		LD R2,PLAYER_WIDTH
		LD R3,PLAYER_HEIGHT		
		LD R4,PLAYER_COL
		JSR POINTG


		;ball
		LD R0,BALL_POS_X	;store past position
		LD R1,BALL_POS_Y
		ST R0,BALL_POS_X_P
		ST R1,BALL_POS_Y_P

		LD R0,BALL_POS_X
		LD R1,BALL_POS_Y
		LD R2,BALL_VEL_X	;check new x vel
		ADD R0,R0,R2
		JSR POINTADDR		;get color
		LD R3,MAP_BGD_COL_I
		LDR R0,R0,#0
		ADD R0,R0,R3
		BRz #4				;skip next 4 lines if color is the background
		LD R0,BALL_VEL_X
		NOT R0,R0
		ADD R0,R0,#1		;invert x velocity
		ST R0,BALL_VEL_X

		LD R0,BALL_POS_X
		LD R1,BALL_POS_Y
		LD R2,BALL_VEL_Y	;check new y vel
		ADD R1,R1,R2
		LD R4,SCREEN_SIZEY_I	;check if hit the ground
		ADD R4,R1,R4		
		BRz DEATH
		
		JSR POINTADDR		;get color
		LD R3,MAP_BGD_COL_I
		LDR R0,R0,#0
		ADD R3,R3,R0
		BRz #14				;skip next _ lines if color is the background
		
		LD R3,PLAYER_COL_I
		ADD R3,R3,R0
		BRnp #7				;skip next _ lines if color is not player color
		JSR HITPADDLE
		LD R1,BALL_VEL_X
		ADD R0,R0,R1
		
		LD R1,BALL_VEL_X_MIN
		LD R2,BALL_VEL_X_MAX
		JSR CLAMP
		ST R0,BALL_VEL_X	

		LD R0,BALL_VEL_Y
		NOT R0,R0
		ADD R0,R0,#1		;invert y velocity
		ST R0,BALL_VEL_Y
		
		LD R0,BALL_POS_X
		LD R1,BALL_POS_Y
		LD R2,BALL_VEL_X
		LD R3,BALL_VEL_Y	;apply ball vel
		ADD R0,R0,R2
		ADD R1,R1,R3
		ST R0,BALL_POS_X
		ST R1,BALL_POS_Y
		LD R2,BALL_COL		;print ball
		JSR POINT
		
		LD R0,BALL_POS_X_P
		LD R1,BALL_POS_Y_P
		LD R2,MAP_BGD_COL		;clear last ball pos
		JSR POINT
		

		BRnzp LOOP				;loop

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
PLAYER_WIDTH_H	.FILL x0005		;half of player width
PLAYER_HEIGHT	.FILL x0002
PLAYER_MAX_X_I	.FILL xFFBA
PLAYER_MIN_X_I	.FILL xFFFC
PLAYER_SPEED	.FILL x0002
PLAYER_SPEED_I	.FILL xFFFE
PLAYER_COL	.FILL xFFFF
PLAYER_COL_I	.FILL x0001

BALL_POS_X	.FILL x0024
BALL_POS_Y	.FILL x0030
BALL_POS_X_P	.FILL x0030	;past position for ball movement smoothness
BALL_POS_Y_P	.FILL x0030
BALL_VEL_X	.FILL x0001
BALL_VEL_Y	.FILL xFFFF
BALL_VEL_X_MIN	.FILL xFFFE
BALL_VEL_X_MAX	.FILL x0002
BALL_COL 	.FILL x07E0

K_A		.FILL xFF9F				;x0061		Inverted key codes
K_D		.FILL xFF9C				;x0064

DELAY	.FILL x3500				;the delay in the program so it doesnt go so fast

MAP_WIDTH	.FILL x0054
MAP_HEIGHT	.FILL x007C
MAP_WALL_WIDTH	.FILL x0004
MAP_BGD_COL		.FILL x1012
MAP_BGD_COL_I	.FILL xEFEE
MAP_WALL_COL	.FILL xC000

BLOCK_COL	.FILL x07E0
BLOCK_HEIGHT	.FILL x0004
BLOCK_WIDTH		.FILL x0014
BLOCK_Y		.FILL x0008

BLOCK1_X	.FILL x0008
BLOCK2_X	.FILL x0020
BLOCK3_X	.FILL x0038


;subroutines --------------- Generally uses R0-R5
DEATH	TRAP x25	;just because its easier to remember

HITPADDLE	;get x vel addition based on ball vs paddle positions - R0 is the added vel
		LD R0,BALL_POS_X
		LD R1,PLAYER_POS
		LD R2,PLAYER_WIDTH_H
		ADD R1,R1,R2
		
		;make player pos negative
		NOT R1,R1
		ADD R1,R1,#1
		
		ADD R0,R0,R1
		RET

CLAMP	;clamps R0 with a min of R1 and a max of R2 (output is R0) also uses R3 and R4
		NOT R3,R0		;invert input number
		ADD R3,R3,#1
		
		ADD R4,R1,R3
		BRn #1			;check min
		AND R0,R1,#-1
		
		ADD R4,R2,R3
		BRp #1			;check max
		AND R0,R2,#-1
		
		RET
		

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