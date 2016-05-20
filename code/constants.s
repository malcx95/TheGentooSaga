reg zero:               R0
reg lr_buttons:         R1
reg abs_pos_x:          R2
reg corner_chk_y:       R3
reg query_res_reg:      R4
reg sprite1_y_reg:      R5
reg speed:              R6
reg ground_reg:         R7
reg slower_speed:       R8
reg new_dir_if_collided:R9
reg sprite1_x_reg:      R10
reg logo_speed:         R11
reg scroll_offset_reg:  R12
reg enemy_x_reg:        R13
reg enemy_y_reg:        R14
reg enemy_dir_reg:      R15
reg enemy_alive_reg:    R16
reg enemy_index:        R17
reg logo_x:             R18
reg logo_y:             R19
reg yakety_reg:			R20
reg current_level:      R21
reg current_song_reg:   R22
reg space_reg:          R25
reg new_frame_reg:      R31

;; const start_scroll:    	0xFFF0
;const start_scroll:    	0x270
const start_scroll: 0x810
const g:                1
const ground:           160
const v0:               20
const sprite_fat:       16
const sprite_thin:      14
const enemy_speed:      10
const bottom_void:      239

const gentoo_begins:	0b00
const yakety:			0b01
;; const shit_song:		0b01
const left_edge:        80
const right_edge:       240
const screen_width:     336
const true:             1
const false:            0
const right:            1
const left:             0xFFFF
;; enemy initial position
const enemy1_start_x:   448
const enemy1_start_y:   144

const enemy2_start_x:   992
const enemy2_start_y:   160

const enemy3_start_x:   1440
const enemy3_start_y:   96

const enemy4_start_x:   1856
const enemy4_start_y:   160

const enemy5_start_x:   2368
const enemy5_start_y:   192

const logo_start_x:     2336
const logo_start_y:     144
const logo_top_left_x:	104
const logo_top_left_y:	105
const logo_start_v:     40
const logo_pos_shift:   6

const enemy_x_offset:   0
const enemy_y_offset:   1
const enemy_dir_offset: 2
const enemy_alive_offset: 3
const enemy_struct_size: 4
const end_of_enemy_data: 24
