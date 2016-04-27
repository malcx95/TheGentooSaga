    movhi r0, 0
    movhi r1, 0
START: lw r1, r0, LEFT
	   sw r0, r1, 0x4000
	   lw r1, r0, RIGHT
	   sw r0, r1, 0x4001
	   lw r1, r0, SPACE
	   sw r0, r1, 0x4002
	   jmp START
