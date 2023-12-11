.orig x3000

START:	;; CLEAR THE SCREEN
	JSR INIT_FRAME_BUFFER_SR 	; Clear the frame buffer by writing zeros to all memory locations.
	LD R5,VIDEO			; This is in preparation for drawing the top border, row by row. Each row has length 80 decimal.
	LD R1,RMAX	 
	LD R2, RED
	JSR DRAW_TOP_SR 		; Subroutine to draw the top border.
	JSR DRAW_SIDES_SR 		; Subroutine to draw the left and right border.
	
	;**************************************
	;; Find DRAW_PADDLE_SR subroutine and implement it
	JSR DRAW_PADDLE_SR		; Subroutine to draw the paddle. Uncomment this line once you 
						; put in the code to draw the paddle in there.
	;**************************************
	
	;; Drawing the 3 bricks
	AND R0,R0, #0
	ADD R1,R0, #2
	ADD R0,R0, #2
	LD R2,BLUE			; We'll choose to make it blue
	JSR DRAW_BRICK_SR		; Draw the first brick
	ADD R0,R0, #1
	JSR DRAW_BRICK_SR		; Draw the second brick
	ADD R0,R0, #1
	JSR DRAW_BRICK_SR		; Draw the third brick
	
	;; Draw the ball 
	LD R0, BALL_X
	LD R1, BALL_Y
	LD R2, BALL_COLOR
	TRAP x40

GAME_LOOP:
	LD R0, BRICKS_LEFT
	BRz WIN_SR

	; Put some delay to slow down the ball	
	JSR DELAY_LOOP_SR

	; Load the current location and direction
	JSR LOAD_BALL_COOR_SR
	; Calculate the next location
	ADD R0,R0,R3
	ADD R1,R1,R4
	; Get the color of the next location
	TRAP x41

	; if it is red, it's a wall
	LD R4,RED2
	ADD R4, R5, R4
	BRz WALL_COLLISION

	; if it is blue, it's a brick
	LD R4,BLUE2
	ADD R4, R5, R4
	BRz BRICK_COLLISION	

	;; no collision, move the ball
	; first erase the ball in the current location
	JSR LOAD_BALL_COOR_SR
	LD R2, BLACK
	TRAP x40
	; then draw the ball in the new location
	ADD R0,R0,R3
	ADD R1,R1,R4	
	LD R2, BALL_COLOR
	TRAP x40
	; lastly, store the new location
	ST R0, BALL_X
	ST R1, BALL_Y

	LD R5, THIRTY2 ;if the ball misses the paddle, game over
	ADD R5, R5, R1
	BRz GAME_OVER

	;**************************************
	;; Find PADDLE_NEXT_LOC_SR subroutine and implement it
	JSR PADDLE_NEXT_LOC_SR	; uncomment this line once to implement the code to move the paddle to the
						; next location in the subroutine.
	;**************************************

	; next, check to make sure that the total number of bricks in the game is still positive.  If not, the game is over!
	;
	LD R5, BRICKS_LEFT
	ADD R5, R5, #0
	BRp GAME_LOOP
GAME_OVER:
	JSR LOSE_SR
	HALT
WALL_COLLISION:
	JSR WALL_COL_SR
	BR GAME_LOOP	
BRICK_COLLISION:
	JSR BRICK_COL_SR
	BR GAME_LOOP

;; Below are the service routines that may be useful for this project
VIDEO .FILL xC000
BLACK .FILL x0000
DISPSIZE .FILL x3E00
RMAX .FILL x0053		;83
RED .FILL x7C00
RED2 .FILL x8400
TWENTYONE	.FILL 21
TWENTYONE2	.FILL xFFEC
ZERO .FILL x0000
SIDE .FILL xC200	;512
CMAX .FILL x0078
DELTA .FILL x0050	;50
NEXTS .FILL x0030	;48
BLUE .FILL x001F
BLUE2 .FILL xFFE1
EIGHT		.FILL 8
FIVE		.FILL 5
THIRTY .FILL 30
THIRTY2 .FILL xFFE2
BALL_X	.FILL 5
BALL_Y .FILL 5
BALL_X_DIR .FILL 1
BALL_Y_DIR .FILL 1
BALL_COLOR .FILL x8AA8
DELAY	.FILL 6000
LEFT_WALL	.FILL 0
RIGHT_WALL	.FILL 20
TOP_WALL	.FILL 0
BOTTOM_WALL	.FILL 31
BRICKS_LEFT .FILL 3

;;*************************************
;; This subroutine is used to initialize the frame buffer to zero.
;;*************************************
INIT_FRAME_BUFFER_SR
	LD R5,VIDEO	; R5 is the pointer to the where the pixels will be written to the display
	LD R6,BLACK	; Black pixel value
	LD R3,DISPSIZE	; The size of the entire frame buffer (We are going to write the value of BLACK in the entire frame buffer)
LOOP0:
	STR R6,R5,#0	; In this loop, we are storing the pixel in the appropriate location, then incrementing R5
	ADD R5,R5,#1	;
	ADD R3,R3,#-1	; Checking to see if the entire frame buffer has been written into
	BRp LOOP0	;
	RET

;;*************************************
;; This subroutine is used to draw the top RED border.
;;*************************************
DRAW_TOP_SR
	LD R4,TWENTYONE	; We need 4 such rows of length 84 decimal each
	AND R0,R0, #0
	LD R1, ZERO
	
	ST R7, TEMP
TOP_LOOP:
	TRAP x40
	ADD R0, R0, #1
	ADD R4, R4, #-1
	BRp TOP_LOOP;	
	LD R7, TEMP
	RET

;;*************************************
;; This subroutine is used to draw the left and the right side wall.
;;*************************************
DRAW_SIDES_SR
	AND R1,R1, #0	; now update the display to where the left side wall begins (Do not consider the overlap with the top side)
	ADD R1,R1, #1
	LD R3,THIRTY	; This is the height of the side walls (Excluding the 4 rows for the top side)
	LD R5,TWENTYONE 
	ADD R5,R5, #-1
	ST R7, TEMP
SIDE_LOOP:	
	AND R0,R0, #0
	TRAP x40	; Drawing the right wall..
	ADD R0,R0,R5	
	TRAP x40
	ADD R1,R1,#1	;
	ADD R3,R3,#-1	; Repeat the same process for the entire height of the side walls.
	BRp SIDE_LOOP	;
	LD R7, TEMP
	RET

;;*************************************
;; This subroutine is used to draw a single blue brick.
;; Inputs: 
;;	R0 should contain the starting X location of the brick
;;	R1 should contain the starting Y location of the brick
;;*************************************
DRAW_BRICK_SR
	LD R4, FIVE
	ST R7, TEMP
BRICK_LOOP:		
	TRAP x40
	ADD R0, R0, #1
	ADD R4, R4, #-1
	BRp BRICK_LOOP	;
	LD R7, TEMP
	RET
;;*************************************
;; This subroutine is used to draw the paddle.
;; WRITE YOUR CODE TO DRAW THE PADDLE
;;*************************************
DRAW_PADDLE_SR
	;; Implement code for drawing the paddle here
	;; The paddle is of the same size as a brick
	;; Color of the paddle should be RED
	
	; Initialize registers here
	LD R0, PADDLE_CURR_POS
	LD R1, PADDLE_HEIGHT
	LD R2, RED

	LD R3, PADDLE_WIDTH
	ST R7, TEMP ;; we need to store R7 because we will call the TRAP
PADDLE_LOOP:
	TRAP x40
	ADD R0, R0, #1
	ADD R3, R3, #-1
	BRp PADDLE_LOOP
	LD R7, TEMP ;; loading R7 to jump back to the instruction after the JSR
	RET

;;*************************************
;; This subroutine is loads the current location and the direction of the ball.
;;*************************************
LOAD_BALL_COOR_SR
	LD R0, BALL_X	
	LD R1, BALL_Y
	LD R3, BALL_X_DIR
	LD R4, BALL_Y_DIR
	RET
;;*************************************
;; This subroutine is used to detect the collision between the wall and the bricks.
;; Incase of a collision the brick is deleted.
;;*************************************
BRICK_COL_SR	
	; check if collision with one of the bricks
	LD R5, BRICKS_LEFT
	ADD R5, R5, #-1
	ST R5, BRICKS_LEFT
	LD R5,LEFT_WALL
	NOT R5, R5
	ADD R5, R5, #1
	ADD R4, R0, R5
	BRz FLIP_VERTICAL
	LD R5,RIGHT_WALL
	NOT R5, R5
	ADD R5, R5, #1
	ADD R4, R0, R5
	BRz FLIP_VERTICAL

	; hit a horizontal wall, flip the y direction
	LD R4,BALL_Y_DIR
	LD R5,ZERO
	NOT R4, R4
	ADD R4, R4, #1
	ADD R4, R5, R4
	ST R4,BALL_Y_DIR
	
	; next determine which of the 3 bricks we hit, based on X position
	; compare to see of we hit the left brick, based on our X position
	LD R4, LEFT_BRICK
	NOT R0, R0
	ADD R0, R0, #1
	ADD R4, R4, R0
	BRzp DELETE_LEFT_BRICK 
	
	; if not, check to see if we hit the middle brick 
	LD R4, MID_BRICK
	ADD R4, R4, R0
	BRzp DELETE_MID_BRICK
	
	; if neither of the other conditions were met, it must be the right brick that was hit
	BR DELETE_RIGHT_BRICK

DELETE_LEFT_BRICK:
	ST R7, TEMP
	JSR DELETE_L_BRICK_SR
	LD R7, TEMP
	RET

DELETE_MID_BRICK:
	ST R7, TEMP
	JSR DELETE_M_BRICK_SR
	LD R7, TEMP
	RET
	
DELETE_RIGHT_BRICK:
	ST R7, TEMP	
	JSR DELETE_R_BRICK_SR
	LD R7, TEMP
	RET

;;*************************************
;; This subroutine is used to detect the collision with the wall.
;; Incase of a collision, the direction of the ball is changed.
;;*************************************
WALL_COL_SR	
	; check if collision with vertical wall
	LD R5,LEFT_WALL
	NOT R5, R5
	ADD R5, R5, #1
	ADD R4, R0, R5
	BRz FLIP_VERTICAL
	LD R5,RIGHT_WALL
	NOT R5, R5
	ADD R5, R5, #1
	ADD R4, R0, R5
	BRz FLIP_VERTICAL
	; hit a horizontal wall, flip the y direction
	LD R4,BALL_Y_DIR
	LD R5,ZERO
	NOT R4, R4
	ADD R4, R4, #1
	ADD R4, R5, R4
	ST R4,BALL_Y_DIR
	RET	
FLIP_VERTICAL:
	; check if collision with corner
	LD R5,TOP_WALL
	NOT R5, R5
	ADD R5, R5, #1
	ADD R4, R1, R5
	BRz FLIP_CORNER
	LD R5,BOTTOM_WALL
	NOT R5, R5
	ADD R5, R5, #1
	ADD R4, R1, R5
	BRz FLIP_CORNER
	;;hit a vertical wall, flip the x direction
	LD R3,BALL_X_DIR
	LD R5,ZERO
	NOT R3, R3
	ADD R3, R3, #1
	ADD R3, R5, R3
	ST R3,BALL_X_DIR
	RET
FLIP_CORNER:	
	; collision with corner, flip x and y direction
	LD R3,BALL_X_DIR
	LD R4,BALL_Y_DIR
	LD R5,ZERO
	NOT R3, R3
	ADD R3, R3, #1
	ADD R3, R5, R3
	ST R3,BALL_X_DIR
	NOT R4, R4
	ADD R4, R4, #1
	ADD R4, R5, R4
	ST R4,BALL_Y_DIR
	RET

;;*************************************
;; This subroutine is used to move the paddle left of right.
;; if the user presses 'a' the paddle moves left by one 4x4 block.
;; if the user pressed 'd' the paddle moves right by one 4x4 block.
;;*************************************
PADDLE_NEXT_LOC_SR
	ST R7, TEMP
	;; Get the key pressed by the user 'a' equals 'left' and 'd' equals 'right'
	TRAP x42  ;in R5
	
	LD R4, PADDLE_CURR_POS ;; get current position of paddle
	LD R1, THIRTY ;; the row number where the paddle is present
	;; check if the user pressed 'a'
	LD R0, KEY_A
	ADD R0, R0, R5
	BRz PADDLE_MOVE_L

	;; check if the user pressed 'd'
	LD R0, KEY_D
	ADD R0, R0, R5
	BRz PADDLE_MOVE_R

	;; check if the user pressed 'q'
	LD R0, KEY_Q
	ADD R0, R0, R5
	BRz QUIT
	BRnzp PADDLE_DONE
PADDLE_MOVE_L:
	;; if 'a' is pressed move paddle to left by one 4x4 block
	ADD R4, R4, #-1	;move variable
	BRz PADDLE_DONE_NO

	;visually move
	ADD R0, R4, #0
	LD R1, PADDLE_HEIGHT
	LD R2, RED
	TRAP x40

	ADD R0, R0, #5
	LD R2, BLACK
	TRAP x40

	BRnzp PADDLE_DONE
PADDLE_MOVE_R:
	;; if 'd' is pressed move paddle to right by one 4x4 block
	ADD R4, R4, #1	
	ADD R0, R4, #-16
	BRz PADDLE_DONE_NO

	;visually move
	ADD R0, R4, #4
	LD R1, PADDLE_HEIGHT
	LD R2, RED
	TRAP x40
	
	ADD R0, R0, #-5
	LD R2, BLACK
	TRAP x40

	BRnzp PADDLE_DONE
QUIT:
	HALT
PADDLE_DONE:
	ST R4, PADDLE_CURR_POS ;; Store the new position of the paddle
PADDLE_DONE_NO: ; if paddle is done, but I dont want to change the current pos
	LD R7, TEMP
	RET

WIN_SR: 
	LEA R0, WIN_MSG
	TRAP x22
	HALT

LOSE_SR:
	LEA R0, LOSE_MSG
	TRAP x22
	HALT

DELETE_L_BRICK_SR
	LD R5,BSTART	; starting at the top left corner of the 1st brick
	LD R6,BLACK		; we are erasing it, so set it back to black
	LD R4,BHEIGHT	; R4 will store the height of the brick
DEL_B1_L1:
	LD R3,BLENGTH	
DEL_B1_L2:
	STR R6,R5,#0	; In this loop, we delete the 1st brick, the length of the 1st brick is 20 decimal. 
	ADD R5,R5,#1	
	ADD R3,R3,#-1	
	BRp DEL_B1_L2	
	LD R0,BRICKWRAP	; wrap around to the next position in the row below
	ADD R5,R5,R0	
	ADD R4,R4,#-1	; Making sure that we draw the bricks length first for the entire height.
	BRp DEL_B1_L1	
	RET
	
DELETE_M_BRICK_SR
	LD R5,BSTART2	; starting at the top left corner of the middle brick
	LD R6,BLACK		; we are erasing it, so set it back to black
	LD R4,BHEIGHT	; R4 will store the height of the brick
DEL_B2_L1:
	LD R3,BLENGTH	
DEL_B2_L2:
	STR R6,R5,#0	
	ADD R5,R5,#1	
	ADD R3,R3,#-1	
	BRp DEL_B2_L2	
	LD R0,BRICKWRAP	; wrap around to the next position in the row below
	ADD R5,R5,R0	
	ADD R4,R4,#-1	; Making sure that we draw the bricks length first for the entire height.
	BRp DEL_B2_L1	
	RET		
	
DELETE_R_BRICK_SR
	LD R5,BSTART3	; Starting at the top left corner of the rightmost brick
	LD R6,BLACK		; we are erasing it, so set it back to black
	LD R4,BHEIGHT	; R4 will store the height of the brick
DEL_B3_L1:	
	LD R3,BLENGTH	
DEL_B3_L2:
	STR R6,R5,#0	
	ADD R5,R5,#1	; same procedure as was for the last 2 bricks
	ADD R3,R3,#-1	
	BRp DEL_B3_L2	
	LD R0,BRICKWRAP	; ..Move the display pointer to the next row of the 1st brick, and then repeat the process
	ADD R5,R5,R0	
	ADD R4,R4,#-1	; Making sure that we draw the bricks length first for the entire height.
	BRp DEL_B3_L1		
	RET		
	
DELAY_LOOP_SR:
	LD R6, DELAY
LOOP_DELAY:
	ADD R6,R6,#-1
	BRp LOOP_DELAY
	RET
;;And now define all the constants we need..

BSTART .FILL xC408		;start of leftmost brick
BSTART2 .FILL xC420		;start of middle brick
BSTART3 .FILL xC438		;start of rightmost brick
BLENGTH .FILL x0014		;20
BHEIGHT .FILL x0004
BRICKINC .FILL x003C	;60
BRICKWRAP .FILL 108		;when deleting bricks, this is the distance to wrap back around during the loob
LEFT_BRICK .FILL 6		;rightmost position of the left brick
MID_BRICK .FILL 12		;rightmost position of the middle brick
RIGHT_BRICK .FILL 19	;rightmost position of the right brick
FOUR .FILL x0004
NEXTR .FILL x002C	;44
BOTTOM .FILL 15360	;(128*120)		
TEMP		.FILL 0
PADDLE_CURR_POS .FILL 8
PADDLE_HEIGHT .FILL 30
PADDLE_WIDTH .FILL 5

KEY_A		.FILL xFF9F				;x0061		Inverted key codes
KEY_D		.FILL xFF9C				;x0064
KEY_Q		.FILL xFF8F				;x0071

WIN_MSG: 	.STRINGZ "You Win!!!"
LOSE_MSG: 	.STRINGZ "You Lose!!!"


.end
