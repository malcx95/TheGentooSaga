            # R10: x
            # R11: y

FUNC READ:	LW      R1, R0, LEFT
            ADD	    R10, R10, R1
            LW      R1, R0, RIGHT
            SUB	    R10, R10, R1
            END

            addi    r11, r11, 224
            sw      r0, r11, SPRITE1_Y
LOOP:       lw      r31, r0, NEW_FRAME
            sfeqi   r31, 0
            bf      loop
            nop

            JFN     READ
            SW      R0, R10, SPRITE1_X
            JMP     LOOP
            NOP
