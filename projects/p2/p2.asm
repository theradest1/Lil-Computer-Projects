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
		JSR GETKEY				;get key
		JSR PRINT				;print key

		;past x pos = R0, past y pos = R1, key = R2, new x pos = R3, new y pos = R4, test keys = R5, changed = R6

		AND R6,R6,#0
		AND R2,R0,#-1
		LD R0,POS_X
		LD R1,POS_Y
		AND R3,R0,#-1
		AND R4,R1,#-1

		;test keys

		LD R5,K_W
		ADD R5,R2,R5			; W (up)
		BRnp #2
		ADD R6,R6,#1
		ADD R4,R4,#-1

		LD R5,K_A
		ADD R5,R2,R5			; A (left)
		BRnp #2
		ADD R6,R6,#1
		ADD R3,R3,#-1

		LD R5,K_S
		ADD R5,R2,R5			; S (down)
		BRnp #2
		ADD R6,R6,#1
		ADD R4,R4,#1

		LD R5,K_D
		ADD R5,R2,R5			; D (right)
		BRnp #2
		ADD R6,R6,#1
		ADD R3,R3,#1

		; apply changes

		ADD R6,R6,#0			; update if pos is changed
		BRnz #8
		ST R3,POS_X
		ST R4,POS_Y			
		LD R2,BGD_COL			;clear last pos
		JSR POINT

		LD R0,POS_X
		LD R1,POS_Y				;print new pos
		LD R2,SNK_COL
		JSR POINT

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

KB_DATA .FILL xFE02				;key press data
KB_STE  .FILL xFE00				;key press state
DI_DATA .FILL xFE06				;print mem address

POS_X	.FILL x0020
POS_Y	.FILL x0020

SNK_COL .FILL xFFFF
BGD_COL .FILL x0000

K_W		.FILL xFF89		;x0077
K_A		.FILL xFF9F		;x0061
K_S		.FILL xFF8D		;x0073		Inverted key codes
K_D		.FILL xFF9C		;x0064




;Functions --------------- Generally uses R0-R5

GETKEY	;gets key - in R0
		LDI R0,KB_STE		; wait for a keystroke
		BRzp GETKEY
		LDI R0,KB_DATA		; read it and return
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