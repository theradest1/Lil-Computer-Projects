        .orig x3000
START
		;set point group - top left = (R0,R1) - (width, height) = (R2,R3) - color = R4
    JSR DRAWMAP

		AND R1,R1,#0
WAIT	JSR GETKEYQ
		ADD R1,R1,#1			;get random ball x pos from player delay at start
		ADD R0,R0,#0
		BRz WAIT

		LD R0,BALL_START_MASK	;limit to 5 - 68
		AND R1,R1,R0
		ADD R1,R1,#5
		ST R1,BALL_POS_X
LOOP
		LD R0,DELAY
DELAYL	ADD R0,R0,#-1			; a delay so that the game isnt so fast
		BRp DELAYL

		;key press
		LDI R0,KB_STE
		BRnp DOKEY					;skip key stuff and set vel to 0 if status is zero
		AND R0,R0,#0
		ST R0,PLAYER_VEL
		BRnzp ENDKEY
DOKEY
		JSR GETKEYQ

		;R0 = pressed key, R1 = tested key, R2 = new velocity

		AND R2,R2,#0			;set new player vel to 0
		LD R3,PLAYER_SPEED
		LD R4,PLAYER_SPEED_I

		LD R1,K_A
		ADD R1,R0,R1			; A (left)
		BRnp NOLEFT
		ADD R2,R2,R4
		ST R2,PLAYER_VEL
NOLEFT

		LD R1,K_D
		ADD R1,R0,R1			; D (right)
		BRnp NORIGHT
		ADD R2,R2,R3
		ST R2,PLAYER_VEL
NORIGHT

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
		ADD R1,R0,R1			;min
		BRn BADPOS

		LD R1,PLAYER_MAX_X_I
		ADD R1,R0,R1			;max
		BRp BADPOS

		ST R0,PLAYER_POS		;store if valid
BADPOS
		;print player new postition
		LD R0,PLAYER_POS
		LD R1,PLAYER_Y
		LD R2,PLAYER_WIDTH
		LD R3,PLAYER_HEIGHT
		LD R4,PLAYER_COL
		JSR POINTG


		;ball
		LD R0,BALL_POS_X		;store past position
		LD R1,BALL_POS_Y
		ST R0,BALL_POS_X_P
		ST R1,BALL_POS_Y_P

		LD R0,BALL_POS_X
		LD R1,BALL_POS_Y
		LD R2,BALL_VEL_X		;check new x vel
		ADD R0,R0,R2
		
		JSR POINTADDR			;get color
		LDR R0,R0,#0
		
		LD R3,MAP_BGD_COL_I
		ADD R3,R0,R3
		BRz NOINVERT					;skip next 4 lines if color is the background
		
		LD R3,BALL_COL_I
		ADD R3,R0,R3					;skip if ball color
		BRz NOINVERT
		
		LD R3,BLOCK_COL_I	
		ADD R3,R0,R3					;if block color
		BRnp NOBLOCK
		LD R0,BALL_POS_X
		LD R1,BALL_POS_Y
		LD R2,BALL_VEL_X
		ADD R0,R0,R2
		JSR HITBLOCK
NOBLOCK
		
		LD R0,BALL_VEL_X
		NOT R0,R0
		ADD R0,R0,#1			;invert x velocity
		ST R0,BALL_VEL_X
NOINVERT

		LD R0,BALL_POS_X
		LD R1,BALL_POS_Y
		LD R2,BALL_VEL_Y		;check new y vel
		ADD R1,R1,R2
		LD R4,SCREEN_SIZEY_I	;check if hit the ground
		ADD R4,R1,R4
		BRz DEATH

		JSR POINTADDR			;get color
		LD R3,MAP_BGD_COL_I
		LDR R0,R0,#0
		ADD R3,R3,R0
		BRz ISBACKGROUND					;skip next 14 lines if color is the background
		LD R3,BALL_COL_I
		ADD R3,R0,R3					;skip if ball color
		BRz ISBACKGROUND

		LD R3,PLAYER_COL_I
		ADD R3,R3,R0
		BRnp NOTPLAYER					;skip next 7 lines if color is not player color
		JSR PADDLEDIFF
		LD R1,BALL_VEL_X
		ADD R0,R0,R1

		LD R1,BALL_VEL_X_MIN
		LD R2,BALL_VEL_X_MAX
		JSR CLAMP
		ST R0,BALL_VEL_X
		BRnzp INVERTY
NOTPLAYER
		LD R3,BLOCK_COL_I		;if color is block
		ADD R3,R3,R0
		BRnp INVERTY
		
		LD R0,BALL_POS_X
		LD R1,BALL_POS_Y
		LD R2,BALL_VEL_Y		;get hit point
		ADD R1,R1,R2
		JSR HITBLOCK			;destroy block
INVERTY

		LD R0,BALL_VEL_Y
		NOT R0,R0
		ADD R0,R0,#1			;invert y velocity
		ST R0,BALL_VEL_Y
ISBACKGROUND

		LD R0,BALL_POS_X
		LD R1,BALL_POS_Y
		LD R2,BALL_VEL_X
		LD R3,BALL_VEL_Y		;apply ball vel
		ADD R0,R0,R2
		ADD R1,R1,R3
		ST R0,BALL_POS_X
		ST R1,BALL_POS_Y
		LD R2,BALL_COL			;print ball
		JSR POINT

		LD R0,BALL_POS_X_P
		LD R1,BALL_POS_Y_P
		LD R2,MAP_BGD_COL		;clear last ball pos
		JSR POINT


		BRnzp LOOP				;loop

; subroutines ------------------
HITBLOCK	;destroys block that was hit
	;inputs:
		;x pos: R0
		;y pos: R1
	;overwrites:
		;R0-R7
		;R2S-R4S
		;R7S
	;outputs:
		;none
	ST R7,RE1STORE
		
	LD R2,BLOCK_X_MASK
	LD R3,BLOCK_Y_MASK
	
	ADD R0,R0,#-4
	ADD R1,R1,#-5
	
	AND R0,R0,R2
	AND R1,R1,R3
	
	ADD R1,R1,#5
	ADD R0,R0,#4
	
	LD R2,BLOCK_WIDTH
	ADD R2,R2,#1
	LD R3,BLOCK_HEIGHT
	ADD R3,R3,#1
	LD R4,MAP_BGD_COL
	
	JSR POINTG
	
	LD R7,RE1STORE
	
	RET


PADDLEDIFF	; get x difference between paddle and ball
	;overwrites:
		;R0-R2
	;outputs:
		;x difference: R0

	LD R0,BALL_POS_X
	LD R1,PLAYER_POS		;load values
	LD R2,PLAYER_WIDTH_H
	ADD R1,R1,R2

	NOT R1,R1
	ADD R1,R1,#1			;make player pos negative

	ADD R0,R0,R1
	RET

DRAWMAP  ;no inputs, no outputs
    ST R7,RE2STORE

    AND R0,R0,#0
    AND R1,R1,#0
    LD R2,MAP_WIDTH
    LD R3,MAP_HEIGHT		;background
    LD R4,MAP_BGD_COL
    JSR POINTG

    AND R0,R0,#0
    AND R1,R1,#0
    LD R2,MAP_WIDTH
    LD R3,MAP_WALL_WIDTH	;top wall
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

    ;blocks
    LD R0,BLOCK_START_Y
    ADD R0,R0,#-5
    ST R0,RE3STORE  ;y count variable
BLOCKLOOPY
    LD R0,RE3STORE  ;step y
    LD R2,BLOCK_HEIGHT
    ADD R0,R0,R2
    ADD R0,R0,#1
    ST R0,RE3STORE

    LD R0,BLOCK_START_X
    ADD R0,R0,#-10
    ST R0,RE1STORE  ;x count variable
BLOCKLOOPX
    LD R0,RE1STORE
    LD R2,BLOCK_WIDTH ;load

    ADD R0,R0,R2  ;step x
    ADD R0,R0,#1
    ST R0,RE1STORE

	LD R3,BLOCK_HEIGHT		;print
    LD R1,RE3STORE
	LD R4,BLOCK_COL
	JSR POINTG

    LD R0,RE1STORE
    LD R1,BLOCK_END_X_I
    ADD R0,R0,R1
    BRn BLOCKLOOPX

    LD R0,RE3STORE
    LD R1,BLOCK_END_Y_I
    ADD R0,R0,R1
    BRn BLOCKLOOPY

    LD R7,RE2STORE
    RET

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

RE1STORE	.FILL x0000			;
RE2STORE	.FILL x0000			; a few extra register storages
RE3STORE	.FILL x0000			;

SBSTORE .FILL x0000				; store R7 here when nesting subroutines (for subroutines like print point)
UTSTORE	.FILL x0000				; store R7 here when nesting subroutines (for utilities like multiply)

KB_DATA .FILL xFE02				;key press data
KB_STE  .FILL xFE00				;key press state
DI_DATA .FILL xFE06				;print mem address

PLAYER_POS	.FILL x0024
PLAYER_Y	.FILL x0076
PLAYER_VEL	.FILL x0000
PLAYER_WIDTH	.FILL x000B
PLAYER_WIDTH_H	.FILL x0005		;half of player width
PLAYER_HEIGHT	.FILL x0002
PLAYER_MAX_X_I	.FILL xFFB5
PLAYER_MIN_X_I	.FILL xFFFC
PLAYER_SPEED	.FILL x0002
PLAYER_SPEED_I	.FILL xFFFE
PLAYER_COL	.FILL xFFFF
PLAYER_COL_I	.FILL x0001

BALL_START_MASK		.FILL x003F	;mask for a max of 63
BALL_POS_X	.FILL x0024
BALL_POS_Y	.FILL x0030
BALL_POS_X_P	.FILL x0030		;past position for ball movement smoothness
BALL_POS_Y_P	.FILL x0030
BALL_VEL_X	.FILL x0001
BALL_VEL_Y	.FILL x0001
BALL_VEL_X_MIN	.FILL xFFFE
BALL_VEL_X_MAX	.FILL x0002

BALL_COL 	.FILL xFFF0
BALL_COL_I 	.FILL x0010

K_A		.FILL xFF9F				;x0061		Inverted key codes
K_D		.FILL xFF9C				;x0064

DELAY	.FILL x1500			;the delay in the program so it doesnt go so fast

MAP_WIDTH	.FILL x0059
MAP_HEIGHT	.FILL x007C
MAP_WALL_WIDTH	.FILL x0004
MAP_BGD_COL		.FILL x1012
MAP_BGD_COL_I	.FILL xEFEE
MAP_WALL_COL	.FILL xC000

BLOCK_COL	.FILL x07E0
BLOCK_COL_I	.FILL xF820
BLOCK_HEIGHT	.FILL x0007
BLOCK_WIDTH		.FILL x000F
BLOCK_Y		.FILL x0008
BLOCK_START_X .FILL xFFFF
BLOCK_END_X_I .FILL xFFC0
BLOCK_START_Y .FILL x0002
BLOCK_END_Y_I .FILL xFFE5

BLOCK_X_MASK	.FILL xFFF0
BLOCK_Y_MASK	.FILL xFFF8

RANDCOL		.FILL xF0F0


;subroutines --------------- Generally uses R0-R5
DEATH	TRAP x25	;just because its easier to remember

CLAMP	;clamps value between min and max
		;inputs:
			;value: R0
			;min: R1
			;max: R2
		;overwrites:
			;R0-R4
		;outputs:
			;value: R0

		NOT R3,R0				;invert input number
		ADD R3,R3,#1

		ADD R4,R1,R3
		BRn NOTMIN					;check min
		AND R0,R1,#-1
NOTMIN

		ADD R4,R2,R3
		BRp NOTMAX					;check max
		AND R0,R2,#-1
NOTMAX

		RET


GETKEYW	;get key (waits)
		;outputs:
			;key: R0
		LDI R0,KB_STE			; wait for a keystroke
		BRzp GETKEYW
		LDI R0,KB_DATA			; read it and return
		RET

GETKEYQ	;get last key
		;outputs:
			;key: R0
		LDI R0,KB_DATA			; read it and return
		RET

PRINT	; prints to the console
		;inputs:
			;token: R0 (ASCII)

		STI R0,DI_DATA
		RET

POINTADDR	;get the address of a point
		;inputs:
			;position: (R0,R1)
		;overwrites:
			;R0-R1
			;R7
			;SBS
			;R0S
		;outputs:
			;address: R0

		ST R0,R0STORE			; save x value
		ST R7,SBSTORE			; save return

		LD R2,SCREEN_SIZEX		; R1 is already Y value
		JSR MULT

		AND R1,R0,#-1			; move address to R1
		LD R0,R0STORE			; add x (R0)
		ADD R0,R0,R1			;
		LD R1,SCREEN_START		;add the screen start address
		ADD R0,R0,R1			;

		LD R7,SBSTORE			;load return
		RET

POINT	;sets single point to color
		;inputs:
			;position: (R0,R1)
			;color: R2
		;overwrites:
			;R0-R2
			;R7
			;R7S
			;R2S
			;R0S
			;SBS

		ST R7,R7STORE
		ST R2,R2STORE

		JSR POINTADDR 			;get address

		LD R2,R2STORE
		STR R2,R0,#0			; set color (R2) at mem[R0]

		LD R7,R7STORE
		RET

POINTG	;sets point group to color
		;inputs:
			;start pos: (R0,R1)
			;dimentions: (R2,R3)
			;color: R4
		;overwrites:
			;R0-R7
			;R2S-R4S
			;R7S

		ST R7,R7STORE

		ST R2,R2STORE
		ST R3,R3STORE			;store values for future use
		ST R4,R4STORE

		ADD R0,R0,#-1			;not sure why I need to do this
		ADD R1,R1,#-2			;its to make the position correct

		JSR POINTADDR 			;get address of top left

		;(width, height) = (R0,R1), color = R2, current address = R3, junk = R4, negative current offset = (R5,R6), y step = R7
		ADD R3,R0,#0			;address
		LD R0,R2STORE			;target width
		LD R1,R3STORE			;target height
		LD R2,R4STORE			;color
		LD R7,SCREEN_SIZEX
		AND R6,R6,#0			;height start

		ADD R1,R1,#1			;not sure why I need to do this - makes the height right

POINTGY
		ADD R6,R6,#-1			; increment y
		ADD R3,R3,R7

		ADD R3,R3,R5			;move address back to beginning of x

		AND R5,R5,#0			; reset x

		ADD R4,R1,R6			;check if done
		BRz POINTGE
POINTGX
		ADD R5,R5,#-1			; increment x
		ADD R3,R3,#1

		STR R2,R3,#0			; set color (R2) at address (R3)

		ADD R4,R0,R5
		BRz POINTGY				; check if x is done
		BRnzp POINTGX
POINTGE
		LD R7,R7STORE
		RET


MULT	;multiplication
		;inputs:
			;R1
			;R2
		;overwrites:
			;R0-R5
		;outputs:
			;R0

		AND R0,R0,#0			; result
		ADD R3,R0,#1			; bit test mask
		ADD R4,R0,#-1			; end condition mask

MULT1	AND R2,R2,R4			; any bits left
		BRz MULT3				;
		AND R5,R2,R3			; test bit
		BRz MULT2				;
		ADD R0,R0,R1			; add mult to result

MULT2	ADD R1,R1,R1			; shift mult bits
		ADD R3,R3,R3			;
		ADD R4,R4,R4			;
		BRnzp MULT1				; keep going

MULT3	RET						; finished


		.end					; KEEP AT THE END - errors from me being dumb and forgetting so far = 3
