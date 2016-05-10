reg zero:				R0
reg abs_pos_x:          R2
reg corner_chk_y:       R3
reg query_res_reg:      R4
reg height:				R5
reg speed:				R6
reg space_reg:			R25
reg ground_reg:			R7

const g:				1
const ground:			160
const v0:				12

func jump_init:
    addi	ground_reg, zero, ground
    end

func jump:
    ;; f flag will be set if the player is touching the ground
    bf		on_ground
    nop
    ;; Player is in the air, accelerate
    subi	speed, speed, g
    jmp     no_jump
    nop

on_ground: nop
    ;; The player is standing on the ground
    srli    height, height, 4
    slli    height, height, 4
    movhi	speed, 0
    sfeqi	space_reg, 0
    bf		no_jump
    nop
    ;; Player pressed space, jump
    addi	speed, zero, v0
no_jump:		sub		height, height, speed
    sw		zero, height, sprite1_y
    end

func sf_blocked_y:
	sfnei	zero, 0
    ;; Check left corner
    add abs_pos_x, scroll_offset_reg, sprite1_x_reg
    sw zero, abs_pos_x, query_x
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf yblocked
    ;; Check right corner
    addi abs_pos_x, abs_pos_x, 16
    sw zero, abs_pos_x, query_x
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf yblocked
    nop
    jmp end_of_can_go_up
    nop
yblocked: sfeqi, zero, 0
end_of_can_go_up: end

func sf_blocked_x:
	sfnei	zero, 0
    ;; Check top corner
    sw zero, height, query_y
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf xblocked
    ;; Check lower corner
    addi corner_chk_y, height, 15
    sw zero, height, query_y
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf xblocked
    nop
    ;; No collision, skip to termination
    jmp end_of_can_go_side
    nop
xblocked: sfeqi, zero, 0
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
