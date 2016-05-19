include CONSTANTS

func sf_enemy_alive_and_on_screen:
    ;; Check alive value
    lw enemy_alive_reg, enemy_index, enemy_alive_offset
    sfeqi enemy_alive_reg, false
    bf do_not_draw_enemy
    ;; Check if out to left
    lw enemy_x_reg, enemy_index, enemy_x_offset
    sfgeu scroll_offset_reg, enemy_x_reg
    bf do_not_draw_enemy
    ;; Check if out to right
    sub enemy_x_reg, enemy_x_reg, scroll_offset_reg
    sfgeui enemy_x_reg, screen_width
    bf do_not_draw_enemy
    ;; Enemy is on screen, draw it
    sfeqi zero, 0
    jmp end_of_enemy_alive
do_not_draw_enemy: nop
    sfnei zero, 0
end_of_enemy_alive: end

func do_ai:
    lw      enemy_x_reg, enemy_index, enemy_x_offset
    lw      enemy_dir_reg, enemy_index, enemy_dir_offset
    sw      zero, enemy_y_reg, query_y
    sfeqi   enemy_dir_reg, left
    bf      enemy_going_left
    nop
    ;; Enemy is going right
    addi    enemy_x_reg, enemy_x_reg, sprite_fat
    addi    new_dir_if_collided, zero, left
    jmp     check_enemy_collision
    ;; Enemy is going left
enemy_going_left: nop
    addi    new_dir_if_collided, zero, right
check_enemy_collision: sw zero, enemy_x_reg, query_x
    lw      enemy_x_reg, enemy_index, enemy_x_offset
    nop
    lw      query_res_reg, zero, query_res
    sfeqi   query_res_reg, 0
    bf no_enemy_collision
    nop
    ;; Enemy hit a wall, reverse direction
    addi    enemy_dir_reg, new_dir_if_collided, 0
    sw      enemy_index, enemy_dir_reg, enemy_dir_offset
no_enemy_collision: add enemy_x_reg, enemy_x_reg, enemy_dir_reg
    sw      enemy_index, enemy_x_reg, enemy_x_offset
    end

func check_collision_with_enemy:
    lw      enemy_x_reg, enemy_index, enemy_x_offset
    lw      enemy_y_reg, enemy_index, enemy_y_offset
    add     abs_pos_x, sprite1_x_reg, scroll_offset_reg
    ;; check right side
    addi    abs_pos_x, abs_pos_x, sprite_fat
    sfgeu   enemy_x_reg, abs_pos_x
    subi    abs_pos_x, abs_pos_x, sprite_fat
    bf      no_collision
    ;; check left collision
    addi    enemy_x_reg, enemy_x_reg, sprite_fat
    sfgeu   abs_pos_x, enemy_x_reg
    bf      no_collision
    nop
    ;; check bottom collision
    addi    sprite1_y_reg, sprite1_y_reg, sprite_fat
    sfgeu   sprite1_y_reg, enemy_y_reg
    subi    sprite1_y_reg, sprite1_y_reg, sprite_fat
    bf      no_collision
    ;; check top collision
    addi    enemy_y_reg, enemy_y_reg, sprite_fat
    sfgeu   enemy_y_reg, sprite1_y_reg 
    bf      no_collision
    nop
;; when collision found set flag
    sfeqi   zero, 0
    jmp     exit_func
    nop
no_collision: nop
    ;; reset f flag
    sfeqi   zero, 1
exit_func:  end
