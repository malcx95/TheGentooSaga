		movhi	R0, 0 # R0 bara 0
		movhi	R1, 0xFFFF
		addi	R1, R1, 0xFFFF # R1 bara 1
LOOP:	lw		R2, R0, SPACE
		SFEQ	R0, R2
		BF		LOOP
BLINK:	lw		R2, R0, SPACE
		SFNE	R0, R2
		BF		BLINK
		JMP		LOOP
		
