.orig x3000

START	;; CLEAR THE SCREEN

	LD R5,VIDEO	; R5 is the pointer to the where the pixels will be written to the display
	LD R7,BLACK	; Black pixel value
	LD R3,DISPSIZE	; The size of the entire frame buffer (We are going to write the value of BLACK in the entire frame buffer)
LOOP0	STR R7,R5,#0	; In this loop, we are storing the pixel in the appropriate location, then incrementing R5
	ADD R5,R5,#1	;
	ADD R3,R3,#-1	; Checking to see if the entire frame buffer has been written into
	BRp LOOP0	;
	
	LD R5,VIDEO	; This is in preparation for drawing the top border, row by row. Each row has length 80 decimal
	LD R1,RMAX	; 
	LD R7,RED	; The value of a red pixel
	
;; TOP SIDE

	LD R4,FOUR	; We need 4 such rows of length 84 decimal each

TIMES4	LD R0,ZERO	; This loop repeats 4 times, once for each row

LOOP1	STR R7,R5,#0	; Storing a red pixel at the present display pointer, and incrementing the pointer
	ADD R0,R0,#1	;
	ADD R5,R5,#1	;
	
	LD R3,ZERO	; In this loop, we check if the length limit has been reached. If not, we go back to LOOP1
	ADD R3,R3,R0	;
	NOT R3,R3	;
	ADD R3,R3,#1	;
	ADD R3,R1,R3	;

	BRzp LOOP1	;

	LD R3,NEXTR	; Here we do the same thing 4 times..
	ADD R5,R5,R3	; ..but rembember that the display pointer must now point to the next row's starting address
	ADD R4,R4,#-1	;
	BRp TIMES4	;

;; LEFT AND RIGHT SIDES

	LD R5,SIDE	; now update the display to where the left side wall begins (Do not consider the overlap with the top side)
	LD R3,CMAX	; This is the height of the side walls (Excluding the 4 rows for the top side)
LOOP2	STR R7,R5,#0	; Drawing the left wall..
	STR R7,R5,#1	; 
	STR R7,R5,#2	;
	STR R7,R5,#3	; ..Done that.
	LD R4,DELTA	; Now updating the display pointer to point to the leftmost pixel of the right wall	
	ADD R5,R5,R4	; Drawing the right wall..
	STR R7,R5,#0	;
	STR R7,R5,#1	;
	STR R7,R5,#2	;
	STR R7,R5,#3	; ..Done that.
	
	LD R4,NEXTS	; Don't forget to change the display pointer to the next starting point
	ADD R5,R5,R4	;
	
	ADD R3,R3,#-1	; Repeat the same process for the entire height of the side walls.
	BRp LOOP2	;

;; BRICKS

	LD R5,BSTART	; Starting at the top left corner of the 1st brick
	LD R7,BLUE	; We'll choose to make it blue
	LD R4,BHEIGHT	; And R4 will store the height of the brick
	
TIME4	LD R3,BLENGTH	; 	
LOOP3	STR R7,R5,#0	; In this loop, we draw the 1st brick, the length of the 1st brick is 20 decimal. 
	ADD R5,R5,#1	;
	ADD R3,R3,#-1	;
	BRp LOOP3	;
	
	ADD R5,R5,#4	; ..Remember to move the display pointer to the next brick
	LD R3,BLENGTH	;
LOOP4	STR R7,R5,#0	; Draw the next brick in the same manner as the previous brick
	ADD R5,R5,#1	;
	ADD R3,R3,#-1	;
	BRp LOOP4	;

	ADD R5,R5,#4	; ..Not to forget to change the display pointer to the location of the start of the last brick
	LD R3,BLENGTH	;
LOOP5	STR R7,R5,#0	;
	ADD R5,R5,#1	; same procedure as was for the last 2 bricks
	ADD R3,R3,#-1	;
	BRp LOOP5	;

	LD R0,BRICKINC	; ..Move the display pointer to the next row of the 1st brick, and then repeat the process
	ADD R5,R5,R0	;
	ADD R4,R4,#-1	; Making sure that we draw the bricks length first for the entire height.
	BRp TIME4	;

;; Ideal Paddle is a bottom wall 

	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVERYTHING BELOW IS TO BE IMPLEMENTED IN HW7 IT WILL NOT ASSEMBLE IT IS INCOMPLETE:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::	
	
;; Draw the 4th wall at the bottom for the "ideal paddle" 

	; YOUR CODE HERE
	
	
	LD R0, BALL_X		; X coordinate of ball starts at location 5	
	LD R1, BALL_Y		; Y coordinate of ball starts at location 5
	LD R2, BALL_COLOR	
	TRAP x40			; Trap to OS to draw the ball

	
GAME_LOOP	; This label is used as the main game loop, so return here as long as there are still bricks in the game!
	; Put some delay to slow down the ball
	LD R6, DELAY	
	JSR DELAY_LOOP

	; Load the current location and direction
	LD R0, BALL_X
	LD R1, BALL_Y
	LD R2, BALL_X_DIR
	LD R3, BALL_Y_DIR
	
	; Calculate the next location
	ADD R0,R0,R2
	ADD R1,R1,R3
	
	; Get the color of the next location
	TRAP x41			
	
	; if it is red, it's a wall
	LD R1,RED
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R5,R1
	;BRz WALL_COLLISION
	
	
	; if it is blue, it's a brick
	LD R1,BLUE
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R5,R1
	;BRz BRICK_COLLISION

	; it's not a wall nor a brick
	; check if it is on the bottom part of the screen
	; if so, it's game over
	; YOUR CODE HERE
	;BR? GAME_OVER 
	
	;; no collision, move the ball
	; first erase the ball in the current location
	LD R0, BALL_X
	LD R1, BALL_Y
	LD R2, BLACK
	TRAP x40
	
	LD R0, BALL_X
	LD R1, BALL_Y
	LD R3, BALL_X_DIR
	LD R4, BALL_Y_DIR
	ADD R0,R0,R3
	ADD R1,R1,R4
	
	; then draw the ball in the new location
	
	LD R2, BALL_COLOR
	TRAP x40
	
	; lastly, store the new location
	ST R0, BALL_X
	ST R1, BALL_Y

	; next, check to make sure that the total number of bricks in the game is still positive.  If not, the game is over!
	LD R0,BRICKS_LEFT
	BRz #1
	
	BRnzp GAME_LOOP	;loop

	HALT

; This ends the core part of the game execution. Below are all the Subroutines and the constants you need.

WALL_COLLISION
	JSR WALL_COL_SR
	BR GAME_LOOP
	
BRICK_COLLISION
	JSR BRICK_COL_SR
	BR GAME_LOOP

;; Below are the service routines that may be useful for this project

BRICK_COL_SR	
	; check if collision with one of the bricks
	
	; first you will want to determine which direction the ball will now bounce
	; YOUR CODE HERE
	

	; next determine which of the 3 bricks we hit, based on X position
	; compare to see of we hit the left brick, based on our X position
	
	; Did we hit the left brick?
	;BR? DELETE_LEFT_BRICK 
	
	; if not, check to see if we hit the middle brick 
	;BR? DELETE_MID_BRICK
	
	; if neither of the other conditions were met, it must be the right brick that was hit
	;BR? DELETE_RIGHT_BRICK

; call the service routines to delete the correct brick
DELETE_LEFT_BRICK
	JSR DELETE_L_BRICK_SR
	BR GAME_LOOP	; return back to the main game loop

DELETE_MID_BRICK
	JSR DELETE_M_BRICK_SR
	BR GAME_LOOP	; return back to the main game loop
	
DELETE_RIGHT_BRICK	
	JSR DELETE_R_BRICK_SR
	BR GAME_LOOP	; return back to the main game loop

	
WALL_COL_SR	
	; check if collision with vertical wall
	
	; Check if we colided with the left wall
	; YOUR CODE HERE	
	;BR? FLIP_VERTICAL

	; Otherwise, check to see if we colided with the right wall
	; YOUR CODE HERE
	;BR? FLIP_VERTICAL

	; hit a horizontal wall, flip the y direction
	
	; YOUR CODE HERE
	RET
	
FLIP_VERTICAL
	; check if collision with corner with either the top wall
	;BR? FLIP_CORNER

	; or check if it has collided at a corner at the bottom wall
	;BR? FLIP_CORNER
	
	;;hit a vertical wall, flip the x direction
	; YOUR CODE HERE TO FLIP X DIRECTION
	
	RET

; This code flips the ball 180 degrees when you have encountered a corner
FLIP_CORNER	
	; collision with corner, flip x and y direction
	LD R3,BALL_X_DIR
	LD R4,BALL_Y_DIR
	LD R5,ZERO
	NOT R3, R3
	ADD R3, R3, #1 ; Get 2's compliment
	ADD R3,R5,R3
	ST R3,BALL_X_DIR
	NOT R4, R4
	ADD R4, R4, #1; Get 2's compliment
	ADD R4,R5,R4
	ST R4,BALL_Y_DIR
	RET
			
GAME_OVER
	
	HALT

; This is the service routine for deleting the left brick.  Use either the TRAP x40 to
; clear the brick or erase it in the same manor you used to draw it
DELETE_L_BRICK_SR
	; YOUR CODE TO DELETE LEFT BRICK HERE
	RET

; This is the service routine for deleting the middle brick.  Use either the TRAP x40 to
; clear the brick or erase it in the same manor you used to draw it
DELETE_M_BRICK_SR
	; YOUR CODE TO DELETE MIDDLE BRICK HERE
	RET		

; This is the service routine for deleting the right brick.  Use either the TRAP x40 to
; clear the brick or erase it in the same manor you used to draw it	
DELETE_R_BRICK_SR
	; YOUR CODE TO DELETE RIGHT BRICK HERE	
	RET
	
; This subroutine is used so that the ball doesn't move faster than what we can see!
DELAY_LOOP
	ADD R6,R6,#-1
	BRp DELAY_LOOP
	RET
	
	
;;And now define all the constants we need..

;;;;;;;;;;;;;;;;;; IMPORTANT NOTE::::::::::::::::::::::::::::::::::::::::::::::::::
; You may not need or use all of these variables listed below.  These are simply
; the ones that may be useful in coding this program.

VIDEO .FILL xC000
DISPSIZE .FILL x3E00
ZERO .FILL x0000
RMAX .FILL x0053		;83
CMAX .FILL x0078

BSTART .FILL xC408		;start of leftmost brick
BSTART2 .FILL xC420		;start of middle brick
BSTART3 .FILL xC438		;start of rightmost brick
BLENGTH .FILL x0014		;20
BHEIGHT .FILL x0004
BRICKINC .FILL x003C	;60
BRICKWRAP .FILL 108		;when deleting bricks, this is the distance to wrap back around during the loob
BRICKS_LEFT .FILL 3
LEFT_BRICK .FILL 6		;rightmost position of the left brick
MID_BRICK .FILL 12		;rightmost position of the middle brick
RIGHT_BRICK .FILL 19		;rightmost position of the right brick

RED .FILL x7C00
BLUE .FILL x001F
BLACK .FILL x0000

FOUR .FILL x0004
NEXTR .FILL x002C	;44
NEXTS .FILL x0030	;48
SIDE .FILL xC200	;512
DELTA .FILL x0050	;50
BOTTOM .FILL 15360	;(128*120)		

BALL_X	.FILL 5
BALL_Y .FILL 5
BALL_X_DIR .FILL 1
BALL_Y_DIR .FILL 1
BALL_COLOR .FILL x8AA8
LEFT_WALL	.FILL 0
RIGHT_WALL	.FILL 20
TOP_WALL	.FILL 0
BOTTOM_WALL	.FILL 31

DELAY	.FILL 6000

.end