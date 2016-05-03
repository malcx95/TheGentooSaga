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

const gentoo_begins:	0b00
const shit_song:		0b01
const left_edge:        80
const right_edge:       240

			addi    r11, r11, 224
			addi	r20, r20, gentoo_begins
			addi	r21, r21, shit_song
			add		r22, r20, r0 # current song
            sw      r0, r11, sprite1_y
			sw		r0, r20, song_choice
            sw      r0, r12, scroll_offset
loop:       lw      r31, r0, new_frame
            sfeqi   r31, 0
            bf      loop
            nop
            jfn scroll
			lw		r25, r0, space
			sw		r0, r25, led0
			sfnei	r25, 0
			bf		song_change
			nop
			jmp		loop
			nop
song_change: jfn	change_song
            jfn     jump
			jmp		loop
			nop

func change_song:
			sfeqi	r22, gentoo_begins
			bf		shit
			nop
			movhi	r22, gentoo_begins
			jmp		e
			nop
shit:		addi	r22, r0, shit_song
e:			sw		r0, r22, song_choice
			end

func scroll:
    lw      r1, r0, left
    sfeqi   r10,left_edge
    bf      scroll_left
    nop
	add	    r10, r10, r1
    jmp     end_of_left
    nop
scroll_left: add    r12, r12, r1
end_of_left: lw      r1, r0, right
    sfeqi   r10, right_edge
    bf      scroll_right
    nop     
    sub	    r10, r10, r1
    jmp     end_of_right
    nop
scroll_right: sub    r12, r12, r1

end_of_right: sw      r0, r10, sprite1_x
    sw      r0, r12, scroll_offset
    end

func jump:
jump_loop: sfeqi   r11,214
    bf      fall_down
    nop
    subi     r11,r11,1
    jmp     jump_loop

fall_down: sfeqi   r11,224
    bf      end_jump
    nop
    addi     r11,r11,1
    jmp    fall_down

end_jump: nop
    end
