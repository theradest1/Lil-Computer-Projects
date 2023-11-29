.ORIG x3000 
LEA R1,HELLO 		; load hello start address
AGAIN 	LDR R2,R1,#0 		; put mem[R1] into R2
BRz NEXT 			; if null ended, go to next chunk
ADD R1,R1,#1 		; step R1
BR AGAIN 			; again
NEXT 	LEA R0,PROMPT	; load prompt address
TRAP x22 			; PUTS - print prompt
LD R3,NEGENTER	; load negative of enter into R3 to check end (A)
AGAIN2 TRAP x20 			; GETC - gets keyboard press
TRAP x21 			; OUT - echoes keyboard press
ADD R2,R0,R3 		; add key and negative enter
BRz CONT			; skip if enter
STR R0,R1,#0		; store character at mem[R1] (B)
ADD R1,R1,#1		; step address (C)
		BR AGAIN2			; get another key
CONT	AND R2,R2,#0		; set R2 to 0
		STR R2,R1,#0					; 
		LEA R0,HELLO		; load hello start address
		TRAP x22			; print hello and name
		TRAP x25			; halt
NEGENTER	.FILL xFFF6		; negative enter
PROMPT	.STRINGZ "Please enter your name: "
HELLO		.STRINGZ "Hello, "
			.BLKW #25		;25 character long empty string
		.END

