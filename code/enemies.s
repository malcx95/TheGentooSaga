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
    end
