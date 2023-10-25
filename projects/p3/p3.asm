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

		JSR NEWFOOD

LOOP
		LD R0,DELAY
DELAYL1	ADD R0,R0,#-1			; a delay so that the snake doesnt go zoom
		BRp DELAYL1
		
		LD R0,DELAY
DELAYL2	ADD R0,R0,#-1			; a delay so that the snake doesnt go zoom
		BRp DELAYL2

		;get new direction
		LDI R0,KB_STE
		BRz ENDKEY				;skip key finding if status is zero
		JSR GETKEYQ

		;R0 = pressed key, R1 = tested key, R2 = current x vel, R3 = current y vel, R4 = new x vel, R5 = new y vel

		LD R2,VEL_X
		LD R3,VEL_Y
		AND R4,R4,#0
		AND R5,R5,#0

		LD R1,K_W
		ADD R1,R0,R1			; W (up)
		BRnp #1
		ADD R5,R5,#-1

		LD R1,K_A
		ADD R1,R0,R1			; A (left)
		BRnp #1
		ADD R4,R4,#-1

		LD R1,K_S
		ADD R1,R0,R1			; S (down)
		BRnp #1
		ADD R5,R5,#1

		LD R1,K_D
		ADD R1,R0,R1			; D (right)
		BRnp #1
		ADD R4,R4,#1

		;test if new velocity is valid
		ADD R0,R2,R4
		BRz ENDKEY
		ADD R0,R3,R5
		BRz ENDKEY

		ST R4,VEL_X
		ST R5,VEL_Y

		;JSR PRINT				;print key

ENDKEY

		;past x pos = R0, past y pos = R1, new x pos = R3, new y pos = R4

		LD R0,POS_X
		LD R1,POS_Y
		LD R5,VEL_X
		LD R6,VEL_Y
		AND R3,R0,#-1
		AND R4,R1,#-1

		; apply velocity
		ADD R3,R3,R5
		ADD R4,R4,R6
		AND R0,R3,#-1
		AND R1,R4,#-1
		ST R3,POS_X
		ST R4,POS_Y

		; check bounds
		AND R3,R3,#-1			;left
		BRn DEATH

		AND R4,R4,#-1			;top
		BRn DEATH

		LD R5,SCREEN_SIZEX_I	;right
		ADD R3,R3,R5
		BRz DEATH

		LD R5,SCREEN_SIZEY_I	;bottom
		ADD R4,R4,R5
		BRz DEATH

		JSR POINTADDR
		LDR R0,R0,#0			;get color at to-be point
		BRz #8					;skip checks if color is 0 INCREASE IF CHANGES TO THIS CHUNK IS MADE
		LD R1,SNK_COL_I			; hit self
		ADD R1,R0,R1
		BRz DEATH
		LD R1,FOOD_COL_I		; eat food
		ADD R1,R0,R1
		BRnp #2
		JSR INCRSNAKE
		JSR NEWFOOD

		LD R0,POS_X
		LD R1,POS_Y	
		LD R2,SNK_COL			;print new pos
		JSR POINT

		LD R3,SNK_STR			;get last segment point and load into (R0,R1)
		LD R1,SNK_OFF			
		ADD R3,R3,R1
		LDR R0,R3,#0			
		LDR R1,R3,#1
		LD R2,BGD_COL			;clear it
		JSR POINT

		LD R3,SNK_STR			
		LD R1,SNK_OFF			
		ADD R3,R3,R1
		LD R0,POS_X				;overwrite with current pos
		LD R1,POS_Y	
		STR R0,R3,#0			
		STR R1,R3,#1

		LD R0,SNK_OFF
		ADD R0,R0,#2
		LD R1,SNK_LEN_I
		ADD R1,R1,R0			;increment offset (reset if end of snake mem)
		BRnp #1
		AND R0,R0,#0
		ST R0,SNK_OFF

		JSR LOOP				;loop

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

POS_X	.FILL x0020
POS_Y	.FILL x0020
VEL_X	.FILL x0001
VEL_Y	.FILL x0000

SNK_STR .FILL x4000				;the start of the snake segments
SNK_OFF .FILL x0000				;offset of the snake memory (not the segments)
SNK_LEN	.FILL x0006				;length of snake memory (not the segments)
SNK_LEN_I .FILL xFFFA			;length of snake memory (not the segments) (inverted)

SNK_COL .FILL xFFFF
SNK_COL_I .FILL x0001
BGD_COL .FILL x0000
BGD_COL_I .FILL x0000
FOOD_COL .FILL x00FF
FOOD_COL_I .FILL xFF01

FOOD_X	.FILL x0040
FOOD_X_I	.FILL x0040
FOOD_Y	.FILL x0040
FOOD_Y_I	.FILL x0040

K_W		.FILL xFF89				;x0077
K_A		.FILL xFF9F				;x0061
K_S		.FILL xFF8D				;x0073		Inverted key codes
K_D		.FILL xFF9C				;x0064

RAND_SEED .FILL x0050			; stuff for random nums
RAND_INCR .FILL xD900			;
RAND_LIM .FILL x7FFF			; (gets inverted)

RAND_MASK .FILL x000F			;AND with rand to get 0-64

DELAY	.FILL x5000				;the delay in the program so it doesnt zoom so fast

;game functions
DEATH	TRAP x25


INCRSNAKE	;increments the snake size
		LD R0,SNK_LEN
		ADD R0,R0,#2
		ST R0,SNK_LEN

		NOT R0,R0
		ADD R0,R0,#1
		ST R0,SNK_LEN_I
		
		RET

NEWFOOD 
		ST R7,SBSTORE			;store return

		JSR RAND
		LD R1,RAND_MASK
		AND R0,R0,R1
		ADD R0,R0,#10
		ST R0,FOOD_X			;get new food pos
		JSR RAND
		LD R1,RAND_MASK
		AND R0,R0,R1
		ADD R0,R0,#10
		ST R0,FOOD_Y
		
		LD R0,FOOD_X			
		NOT R0,R0				;preprocess negative food position
		ADD R0,R0,#1			
		ST R0,FOOD_X_I			
		LD R0,FOOD_Y			
		NOT R0,R0				
		ADD R0,R0,#1			
		ST R0,FOOD_Y_I		
		
		LD R0,FOOD_X
		LD R1,FOOD_Y
		JSR POINTADDR
		LD R7,SBSTORE
		LDR R0,R0,#0			;check if new food position is on somethning else
		BRnp NEWFOOD

		LD R0,FOOD_X
		LD R1,FOOD_Y			;print food
		LD R2,FOOD_COL 
		JSR POINT

		LD R7,SBSTORE			;return
		RET

;util functions --------------- Generally uses R0-R5

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



RAND	; generates a random (ish) hex number from x0000 to x7FFF, stored in R0
		LD R0,RAND_SEED
		ADD R0,R0,R0		; mult seed by 2

		LD R1,RAND_INCR		; add increment
		ADD R0,R0,R1		;

		LD R1,RAND_LIM		; 
		ADD R1,R0,R1		; wrap if bigger than RAND_LIM
		BRn #1				;
		AND R0,R1,#-1		;

		ST R0,RAND_SEED		; store seed

		RET






		.end				; KEEP AT THE END - errors from me being dumb and forgetting so far = 3