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

			addi    r11, r11, 224
			addi	gentoo_begins_reg, gentoo_begins_reg, gentoo_begins
			addi	current_song_reg, zero, GENTOO_BEGINS # current song
			jfn		jump_init
            sw      zero, r11, sprite1_y
			sw		zero, gentoo_begins_reg, song_choice
            sw      zero, scroll_offset_reg, scroll_offset
loop:       lw      new_frame_reg, zero, new_frame
            sfeqi   new_frame_reg, 0
            bf      loop
            nop
            jfn scroll
			lw		space_reg, zero, space
			sw		zero, space_reg, led0
			jfn		jump
			sfnei	space_reg, 0
			bf		song_change
			nop
			jmp		loop
			nop
song_change: jfn	change_song
			jmp		loop
			nop

func change_song:
			sfeqi	current_song_reg, gentoo_begins
			bf		shit
			nop
			movhi	current_song_reg, gentoo_begins
			jmp		e
			nop
shit:		addi	current_song_reg, zero, shit_song
e:			sw		zero, current_song_reg, song_choice
			end

func scroll:
			lw      lr_buttons, zero, left
			sfeqi   sprite1_x_reg,left_edge
			bf      scroll_left
			nop
			add	    sprite1_x_reg, sprite1_x_reg, lr_buttons
			jmp     end_of_left
			nop
scroll_left: add    scroll_offset_reg, scroll_offset_reg, lr_buttons
end_of_left: lw      lr_buttons, zero, right
			sfeqi   sprite1_x_reg, right_edge
			bf      scroll_right
			nop     
			sub	    sprite1_x_reg, sprite1_x_reg, lr_buttons
			jmp     end_of_right
			nop
scroll_right: sub    scroll_offset_reg, scroll_offset_reg, lr_buttons

end_of_right: sw      zero, sprite1_x_reg, sprite1_x
			sw      zero, scroll_offset_reg, scroll_offset
			end
