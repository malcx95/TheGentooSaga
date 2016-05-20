include CONSTANTS

func jump:
    ;; f flag will be set if the player is touching the ground
    bf on_ground
    nop
    ;; Player is in the air, accelerate
    subi speed, speed, g
    jmp no_jump
    ;; The player is standing on the ground
on_ground:  nop
    srli sprite1_y_reg, sprite1_y_reg, 4
    slli sprite1_y_reg, sprite1_y_reg, 4
    movhi speed, 0
    sfeqi space_reg, 0
    bf no_jump
    nop
    ;; Player pressed space, jump
    addi speed, zero, v0
no_jump: end

func head_collision:
    bf hit_head
    nop
    jmp no_hit_head
    ;; Player hit their head, push them out of the block
hit_head: nop
    movhi speed, 0
    srli sprite1_y_reg, sprite1_y_reg, 4
    slli sprite1_y_reg, sprite1_y_reg, 4
    addi sprite1_y_reg, sprite1_y_reg, 16
no_hit_head: end

func sf_blocked_y:
    ;; Check left corner
    add abs_pos_x, scroll_offset_reg, sprite1_x_reg
    addi abs_pos_x, abs_pos_x, 1
    sw zero, abs_pos_x, query_x
    nop
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf yblocked
    ;; Check right corner
    addi abs_pos_x, abs_pos_x, sprite_thin
    sw zero, abs_pos_x, query_x
    nop
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf yblocked
    nop
    jmp end_of_can_go_up
    nop
yblocked: sfeqi, zero, 0
end_of_can_go_up: end

func sf_blocked_x:
    ;; Check top corner
    addi corner_chk_y, sprite1_y_reg, 0
    sw zero, corner_chk_y, query_y
    nop
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf xblocked
    ;; Check lower corner
    addi corner_chk_y, corner_chk_y, sprite_thin
    sw zero, corner_chk_y, query_y
    nop
    lw query_res_reg, zero, query_res
    sfnei query_res_reg, 0
    bf xblocked
    nop
    ;; No collision, skip to termination
    jmp end_of_can_go_side
xblocked: nop
    sfeqi, zero, 0
end_of_can_go_side: end

func go_left:
    lw lr_buttons, zero, left
    sfeqi scroll_offset_reg, 0xfff0
    bf no_left_scroll
    nop
    sfeqi sprite1_x_reg,left_edge
    bf scroll_left
no_left_scroll: nop
    add sprite1_x_reg, sprite1_x_reg, lr_buttons
    jmp end_of_left
scroll_left: nop
    add scroll_offset_reg, scroll_offset_reg, lr_buttons
end_of_left: end

func go_right:
    lw lr_buttons, zero, right
    sfeq scroll_offset_reg, level_end
    bf no_right_scroll
    nop
    sfeqi sprite1_x_reg, right_edge
    bf scroll_right
no_right_scroll: nop
    sub sprite1_x_reg, sprite1_x_reg, lr_buttons
    jmp end_of_right
scroll_right: nop
    sub scroll_offset_reg, scroll_offset_reg, lr_buttons
end_of_right: end
