include CONSTANTS

func init:
	;; increment current song
    addi    current_song_reg, current_song_reg, 1
    sw      zero, current_song_reg, song_choice
    ;; initialize player variables
    movhi	speed, 0
    addi    sprite1_y_reg, zero, ground
    addi    sprite1_x_reg, zero, left_edge
    addi    ground_reg, zero, ground

    ;; initialize scroll
    addi    scroll_offset_reg, zero, start_scroll
    sw      zero, scroll_offset_reg, scroll_offset

    sw zero, sprite1_x_reg, sprite2_x
	sw zero, sprite1_y_reg, 15

    ;; initialize enemies
    addi    enemy_index, zero, 0
    addi    enemy_dir_reg, zero, right
    addi    enemy_alive_reg, zero, true

    addi    enemy_x_reg, zero, enemy1_start_x
    addi    enemy_y_reg, zero, enemy1_start_y
    sw      enemy_index, enemy_x_reg, enemy_x_offset
    sw      enemy_index, enemy_y_reg, enemy_y_offset
    sw      enemy_index, enemy_dir_reg, enemy_dir_offset
    sw      enemy_index, enemy_alive_reg, enemy_alive_offset
    addi    enemy_index, enemy_index, enemy_struct_size

    addi    enemy_x_reg, zero, enemy2_start_x
    addi    enemy_y_reg, zero, enemy2_start_y
    sw      enemy_index, enemy_x_reg, enemy_x_offset
    sw      enemy_index, enemy_y_reg, enemy_y_offset
    sw      enemy_index, enemy_dir_reg, enemy_dir_offset
    sw      enemy_index, enemy_alive_reg, enemy_alive_offset
    addi    enemy_index, enemy_index, enemy_struct_size

    addi    enemy_x_reg, zero, enemy3_start_x
    addi    enemy_y_reg, zero, enemy3_start_y
    sw      enemy_index, enemy_x_reg, enemy_x_offset
    sw      enemy_index, enemy_y_reg, enemy_y_offset
    sw      enemy_index, enemy_dir_reg, enemy_dir_offset
    sw      enemy_index, enemy_alive_reg, enemy_alive_offset
    addi    enemy_index, enemy_index, enemy_struct_size

    addi    enemy_x_reg, zero, enemy4_start_x
    addi    enemy_y_reg, zero, enemy4_start_y
    sw      enemy_index, enemy_x_reg, enemy_x_offset
    sw      enemy_index, enemy_y_reg, enemy_y_offset
    sw      enemy_index, enemy_dir_reg, enemy_dir_offset
    sw      enemy_index, enemy_alive_reg, enemy_alive_offset
    addi    enemy_index, enemy_index, enemy_struct_size

    addi    enemy_x_reg, zero, enemy5_start_x
    addi    enemy_y_reg, zero, enemy5_start_y
    sw      enemy_index, enemy_x_reg, enemy_x_offset
    sw      enemy_index, enemy_y_reg, enemy_y_offset
    sw      enemy_index, enemy_dir_reg, enemy_dir_offset
    sw      enemy_index, enemy_alive_reg, enemy_alive_offset

	;; initialize gentoo logo
	addi    logo_x, zero, logo_start_x
	addi    logo_y, zero, logo_start_y
    slli    logo_y, logo_y, 6
    addi    logo_speed, zero, logo_start_v
	sw      zero, logo_x, logo_top_left_x
	sw      zero, logo_y, logo_top_left_y

    end
