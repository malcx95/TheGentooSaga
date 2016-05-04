INCLUDE		CONTROL
# r0 = 0
# r1 - left and right buttons
# r10 - sprite1_x
# r11 - sprite1_y
# r12 - scroll_offset
# r20 - gentoo_begins
# r21 - shit_song
# r22 - current_song
# r25 - space
# r31 - new_frame
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

			# set current song
			addi	gentoo_begins_reg, gentoo_begins_reg, gentoo_begins
			addi	current_song_reg, zero, GENTOO_BEGINS # current song
			sw		zero, gentoo_begins_reg, song_choice
			# initialize jump variables
			jfn		jump_init
            sw      zero, ground_reg, sprite1_y
			# initialize scroll
            sw      zero, scroll_offset_reg, scroll_offset

loop:       lw      new_frame_reg, zero, new_frame
            sfeqi   new_frame_reg, 0
            bf      loop
            nop
            jfn scroll
			lw		space_reg, zero, space
			sw		zero, space_reg, led0
			jfn		jump
			jmp		loop

