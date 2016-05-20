include CONSTANTS

func draw_logo:
    ;; reset variables
    lw      logo_x, zero, logo_top_left_x
    lw      logo_y, zero, logo_top_left_y
    srli    logo_y, logo_y, logo_pos_shift
    ;; check if logo is on screen
    sub     logo_x, logo_x, scroll_offset_reg
    sfgeui  logo_x, screen_width
    bf      draw_nothing
    nop

    ;; draw left side
    ;; top
    sw      zero, logo_x, logo_tl_x
    sw      zero, logo_y, logo_tl_y

    ;; bottom
    addi    logo_y, logo_y, sprite_fat
    sw      zero, logo_x, logo_bl_x
    sw      zero, logo_y, logo_bl_y

    ;; draw right side
    ;; bottom
    addi    logo_x, logo_x, sprite_fat
    sw      zero, logo_x, logo_br_x
    sw      zero, logo_y, logo_br_y

    ;; top
    subi    logo_y, logo_y, sprite_fat
	sw      zero, logo_x, logo_tr_x
	sw      zero, logo_y, logo_tr_y
    jmp     done

draw_nothing: nop
    sw      zero, zero, logo_tl_x
    sw      zero, zero, logo_bl_x
    sw      zero, zero, logo_tr_x
    sw      zero, zero, logo_br_x
done: end

func move_logo:
	lw      logo_y, zero, logo_top_left_y
    srli    logo_y, logo_y, logo_pos_shift
    sfgeui  logo_y, logo_start_y
    bf      logo_below
    nop
    addi    logo_speed, logo_speed, 1
    jmp     update_logo_position
logo_below: nop
    addi    logo_speed, logo_speed, 0xFFFF
update_logo_position:   nop
	lw      logo_y, zero, logo_top_left_y
    add     logo_y, logo_y, logo_speed
	sw      zero, logo_y, logo_top_left_y
    end
