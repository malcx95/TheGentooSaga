CONST GENTOO_BEGINS:	0b00
CONST SHIT_SONG:		0b01

			addi    r11, r11, 224
			addi	r20, r20, GENTOO_BEGINS
			addi	r21, r21, SHIT_SONG
            sw      r0, r11, SPRITE1_Y
			sw		R0, R21, SONG_CHOICE
LOOP:       lw      r31, r0, NEW_FRAME
			lw		R0, R30, SPACE
			sw		R0, R30, LED0
            sfeqi   r31, 0
            bf      loop
            nop
            LW      R1, R0, LEFT
	        ADD	    R10, R10, R1
	        LW      R1, R0, RIGHT
	        SUB	    R10, R10, R1
            SW      R0, R10, SPRITE1_X
			LW		R0, R25, SPACE
			SFNEI	R25, 0
			BF		SONG_CHANGE
			NOP
			JMP		LOOP
			NOP
SONG_CHANGE: sw		R0, R21, SONG_CHOICE
            JMP     LOOP
            NOP
