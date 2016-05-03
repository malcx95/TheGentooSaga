CONST GENTOO_BEGINS:	0b00
CONST SHIT_SONG:		0b01

			addi    r11, r11, 224
			addi	r20, r20, GENTOO_BEGINS
			addi	r21, r21, SHIT_SONG
			add		R22, R20, R0 # current song
            sw      r0, r11, SPRITE1_Y
			sw		R0, R20, SONG_CHOICE
LOOP:       lw      r31, r0, NEW_FRAME
            sfeqi   r31, 0
            bf      loop
            nop
            LW      R1, R0, LEFT
	        ADD	    R10, R10, R1
	        LW      R1, R0, RIGHT
	        SUB	    R10, R10, R1
            SW      R0, R10, SPRITE1_X
			LW		R25, R0, SPACE
			SW		R0, R25, LED0
			SFNEI	R25, 0
			BF		SONG_CHANGE
			NOP
			JMP		LOOP
			NOP
SONG_CHANGE: JFN	CHANGE_SONG
			JMP		LOOP
			NOP

FUNC CHANGE_SONG:
			SFEQI	R22, GENTOO_BEGINS
			BF		SHIT
			NOP
			MOVHI	R22, GENTOO_BEGINS
			JMP		E
			NOP
SHIT:		ADDI	R22, R0, SHIT_SONG
E:			SW		R0, R22, SONG_CHOICE
			END
