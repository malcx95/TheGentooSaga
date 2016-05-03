
const one:	1
const zero:	0b0
const rand: 0xfa

func coolshit:
HA:	nop
	nop
	add r1, r2, r4
	nop
	jmp HA
	jmp L
L:	end

func nope:

	lw	r3,r4, potato
	nop
	add r1, r2, r3
end
