CONST GENTOO_BEGINS:	0b00
CONST SHIT_SONG:		0b01

			addi    r11, r11, 224
			addi	r20, r20, 0b00
			addi	r21, r21, 0b01
            sw      r0, r11, SPRITE1_Y
			; TODO load gentoo begins
LOOP:       lw      r31, r0, NEW_FRAME
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
SONG_CHANGE: ; TODO change song
            JMP     LOOP
            NOP
