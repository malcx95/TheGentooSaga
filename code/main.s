INCLUDE		CONTROL
const gentoo_begins:	0b00
const yakety:			0b01
;; const shit_song:		0b01
const left_edge:        80
const right_edge:       240
const test_const:       230

    ;; set current song
;;reset_game: nop
    addi    yakety_reg, yakety_reg, yakety 
    addi    current_song_reg, zero, yakety; current song
    sw      zero, yakety_reg, song_choice
    ;; initialize player variables
    movhi speed,0
    addi sprite1_y_reg,zero,ground
    addi    sprite1_y_reg, zero, ground
    addi    sprite1_x_reg, zero, left_edge
    addi    ground_reg, zero, ground
    ;; initialize scroll TODO: remind Malcolm to allow writing negative numbers
    addi    scroll_offset_reg, zero, 0xFFF0
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

    ;;sfgeui  sprite1_x_reg, test_const
    ;;bf reset_game
    ;;nop

	jmp		loop

