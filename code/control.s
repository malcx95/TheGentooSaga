reg zero:				R0
reg height:				R5
reg speed:				R6
reg space_reg:			R25
reg ground_reg:			R7

const g:				1
const ground:			224
const v0:				12

func jump_init:
				addi	ground_reg, zero, ground
				end
func jump:
				sfgeu	ground_reg, height
				bf		off_ground
				nop
				movhi	height, ground ; TODO 
				movhi	speed, 0
				sfeqi	space_reg, 0
				bf		no_jump
				nop
				addi	speed, zero, v0
off_ground:		subi	speed, speed, g
no_jump:		sub		height, height, speed
				sw		zero, height, sprite1_y
				end
