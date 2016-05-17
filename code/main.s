INCLUDE		CONTROL, INIT, ENEMIES

reset_game: nop
    jfn init
    
loop: lw    new_frame_reg, zero, new_frame
    sfeqi   new_frame_reg, 0
    bf      loop
    nop
    ;; Check left side
    add     abs_pos_x, scroll_offset_reg, sprite1_x_reg
	sw      zero, abs_pos_x, query_x
    jfn     sf_blocked_x
    bf      no_left
    nop
    jfn     go_left
    ;; Check right side
no_left:    addi abs_pos_x, abs_pos_x, sprite_fat
	sw      zero, abs_pos_x, query_x
    jfn     sf_blocked_x
    bf      no_right
    nop
    jfn     go_right
no_right:   sw      zero, sprite1_x_reg, sprite1_x
	sw      zero, scroll_offset_reg, scroll_offset
	lw		space_reg, zero, space
	sw		zero, space_reg, led0

    ;; Update y position
    srli slower_speed, speed, 2
	sub sprite1_y_reg, sprite1_y_reg, slower_speed
    ;; Check ground
    addi    corner_chk_y, sprite1_y_reg, sprite_fat
    sw      zero, corner_chk_y, query_y
	jfn     sf_blocked_y
	jfn		jump
    ;; Check head
	sw      zero, sprite1_y_reg, query_y
	jfn     sf_blocked_y
    jfn     head_collision
    ;; Store final sprite y
    sw zero, sprite1_y_reg, sprite1_y

    ;; Find on screen enemy
    addi    enemy_index, zero, 0
new_enemy:  jfn sf_enemy_alive_and_on_screen
    bf      draw_enemy
    nop
    ;; Goto next enemy
    addi    enemy_index, enemy_index, enemy_struct_size
    sfeqi   enemy_index, end_of_enemy_data
    bf no_enemy_on_screen
    sw      zero, zero, sprite2_x
    jmp     new_enemy
draw_enemy: nop
    ;; We have found the on screen enemy
    lw      enemy_y_reg, enemy_index, enemy_y_offset
    sw      zero, enemy_y_reg, sprite2_y
    sw      zero, enemy_x_reg, sprite2_x
    ;; Do AI
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
no_enemy_on_screen: nop

    sfgeui  sprite1_y_reg, bottom_void
	nop
    bf reset_game
    nop
    
	jmp     loop
    nop
