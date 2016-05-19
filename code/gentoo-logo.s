include CONSTANTS

func draw_logo:
    ;; reset variables
    lw      logo_x, zero, logo_top_left_x
    lw      logo_y, zero, logo_top_left_y
    ;; check if logo is on screen by checking
    sub     logo_x, logo_x, scroll_offset_reg
    sfgeui  logo_x, screen_width
    bf draw_nothing
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
