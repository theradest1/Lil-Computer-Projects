        .orig x3000
START   LEA R2,#10				; load the start of corruption into R2
LOOP	ADD R2,R2,#1            ; R2 <= R2 + 1
		STR R2,R2,#0            ; set address in R2 to R2 (corrupt the mem yay)
        JSR LOOP				; jump to start
		HALT                    ; return to os
	.end
        