reg zero:				R0
reg abs_pos_x:          R2
reg corner_chk_y:       R3
reg query_res_reg:      R4
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
	movhi	height, 0
	add		height, zero, ground_reg
	movhi	speed, 0
	sfeqi	space_reg, 0
	bf		no_jump
	nop
	addi	speed, zero, v0
off_ground:		subi	speed, speed, g
no_jump:		sub		height, height, speed
	sw		zero, height, sprite1_y
	end

func sfcan_go_to_side:
    ;; Check top corner
    sw zero, height, query_y
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf blocked
    ;; Check lower corner
    addi corner_chk_y, height, 15
    sw zero, height, query_y
	lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
	bf blocked
    nop
    ;; No collision, skip to termination
    jmp end_of_can_go_side
    nop
blocked:    sfeqi, zero, 0
end_of_can_go_side: end

func go_left:
	lw      lr_buttons, zero, left
	sfeqi   sprite1_x_reg,left_edge
	bf      scroll_left
	nop
	add	    sprite1_x_reg, sprite1_x_reg, lr_buttons
	jmp     end_of_left
	nop
scroll_left: add    scroll_offset_reg, scroll_offset_reg, lr_buttons
end_of_left: end

func go_right:
    lw      lr_buttons, zero, right
	sfeqi   sprite1_x_reg, right_edge
	bf      scroll_right
	nop
	sub	    sprite1_x_reg, sprite1_x_reg, lr_buttons
	jmp     end_of_right
	nop
scroll_right: sub    scroll_offset_reg, scroll_offset_reg, lr_buttons
end_of_right: end
