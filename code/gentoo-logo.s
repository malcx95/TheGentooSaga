include CONSTANTS

func draw_logo:
	;; reset variables
	movhi	logo_tmp1, 0
	movhi	logo_tmp2, 0
	;; check if logo is on screen by checking 
	;; whether the left side is on screen
	addi	logo_tmp1, zero, logo_start_l_x
	sub		logo_tmp1, logo_tmp1, scroll_offset_reg
	sfgeui	logo_tmp1, screen_width
	bf draw_nothing
	nop

	;; draw left side
	;; top
	lw		logo_tmp2, zero, logo_top_left_y
	sw		zero, logo_tmp1, logo_tl_x
	sw		zero, logo_tmp2, logo_tl_y

	;; bottom
	lw		logo_tmp2, zero, logo_bottom_left_y
	sw		zero, logo_tmp1, logo_bl_x
	sw		zero, logo_tmp2, logo_bl_y

	;; check right side
	movhi	logo_tmp1, 0
	movhi	logo_tmp2, 0
	addi	logo_tmp1, zero, logo_start_r_x
	sub		logo_tmp1, logo_tmp1, scroll_offset_reg
	sfgeui	logo_tmp1, screen_width
	bf no_right
	nop

	;; draw right side
	;; top
	lw		logo_tmp2, zero, logo_top_left_y
	sw		zero, logo_tmp1, logo_tr_x
	sw		zero, logo_tmp2, logo_tr_y

	;; bottom
	lw		logo_tmp2, zero, logo_bottom_left_y
	sw		zero, logo_tmp1, logo_br_x
	sw		zero, logo_tmp2, logo_br_y
	jmp		done
	nop

draw_nothing: nop
	movhi	logo_tmp1, 0
	movhi	logo_tmp2, 0
	sw		zero, logo_tmp1, logo_tl_x
	sw		zero, logo_tmp1, logo_bl_x
no_right: nop
	sw		zero, logo_tmp1, logo_tr_x
	sw		zero, logo_tmp1, logo_br_x
done: end
