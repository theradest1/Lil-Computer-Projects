        .orig x2FFD				; 1 value earlier than usual for start mem
		.FILL xC000				; start of screen mem (+1 for example)
		.FILL xFDFE				; End of screen mem (-1 for example)
		.FILL x0F00				; start color
START   LD R3,#-3				; load the end of the screen into R3
		LD R4,#-3				; load start color

		NOT R3,R3				; change R3 to negative (pre-computing)
		ADD R3,R3,#1

INCOLOR ADD R4,R4,#1			; increment color
		LD R2,#-9				; load the start of screen into R2 (address counter)

LOOP	ADD R2,R2,#1            ; R2 <= R2 + 1
		ADD R4,R4,#1			; R4 <= R2 + 1
		STR R4,R2,#0            ; mem[R2 + 0] <= R4

		ADD R1,R2,R3			; R1 <= R2 - R3 R3
		BRnp LOOP				; go to LOOP if previous calc is not zero

		JSR INCOLOR				; if not end of screen mem, increment color and reset mem counter (R2)
		HALT					; return to os (never)
		.end
        