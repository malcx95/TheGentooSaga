INCLUDE		CONTROL
reg lr_buttons:			R1
reg sprite1_x_reg:		R10
reg scroll_offset_reg:	R12
reg	gentoo_begins_reg:	R20
reg current_song_reg:	R22
reg new_frame_reg:		R31

const gentoo_begins:	0b00
const shit_song:		0b01
const left_edge:        80
const right_edge:       240

	;; set current song
	addi	gentoo_begins_reg, gentoo_begins_reg, gentoo_begins
	addi	current_song_reg, zero, GENTOO_BEGINS ; current song
	sw		zero, gentoo_begins_reg, song_choice
    ;; initialize jump variables
	jfn		jump_init
    sw      zero, ground_reg, sprite1_y
    ;; initialize scroll
    sw      zero, scroll_offset_reg, scroll_offset

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
no_left:    addi abs_pos_x, abs_pos_x, 16
	sw      zero, abs_pos_x, query_x
    jfn     sf_blocked_x
    bf      no_right
    nop
    jfn     go_right
no_right:   sw      zero, sprite1_x_reg, sprite1_x
	sw      zero, scroll_offset_reg, scroll_offset
	lw		space_reg, zero, space
	sw		zero, space_reg, led0

    ;; Check ground
    addi    corner_chk_y, height, 16
    sw      zero, corner_chk_y, query_y
	jfn     sf_blocked_y
	jfn		jump
	jmp		loop

