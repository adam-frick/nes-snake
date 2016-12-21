  .rsset $0000  ;; vars at beginning of mem

game_state  .rs 1
game_frame  .rs 1

; 0: x, 1:y
snake_v     .rs 1
; 0: Q4, 1:Q2
snake_dir 	.rs 1

snake_len   .rs 1
snake_len_v .rs 1

head_lo     .rs 1
head_hi     .rs 1

tail_lo     .rs 30
tail_hi     .rs 30

buttons     .rs 1
points      .rs 1

ptr_lo      .rs 1
ptr_hi      .rs 1

;; CONSTS

PLAY_STATE  = $01
UPF         = $04 ; 15fps (NTSC)

WALL_U      = $05
WALL_D      = $e0
WALL_L      = $04
WALL_R      = $fa 

SNAKE_VX    = $01
SNAKE_VY    = $20

SNAKE_V_I   = $00
SNAKE_DIR_I = $00
SNAKE_LEN_I = $04
SNAKE_LEN_MAX  = $1d

HEAD_I      = $2350

B_A         = %10000000
B_B         = %01000000
B_SELECT    = %00100000
B_START     = %00010000
B_U         = %00001000
B_D         = %00000100
B_L         = %00000010
B_R         = %00000001

SNAKE_CLR   = $01
BG_CLR      = $09

PPU_PALETTE = $3f00
PPU_BACKGROUND = $2000

