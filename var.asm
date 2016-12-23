  .rsset $0000  ;; vars at beginning of mem

game_state  .rs 1
game_frame  .rs 1

; 0: x, 1:y
snake_v     .rs 1
; 0: Q4, 1:Q2
snake_dir 	.rs 1

snake_len   .rs 1
snake_len_v .rs 1

snake_y     .rs 1
snake_tile  .rs 1
snake_attr  .rs 1
snake_x     .rs 1

snake_dead  .rs 1
ud_bg_only  .rs 1

head_lo     .rs 1
head_hi     .rs 1

tail_lo     .rs 32 ; max tail len
tail_hi     .rs 32

tail_dir    .rs 32

fruit_y     .rs 1
fruit_tile  .rs 1
fruit_attr  .rs 1
fruit_x     .rs 1

fruit_seed  .rs 1
fruit_hit   .rs 1

buttons     .rs 1
points      .rs 1

ptr_lo      .rs 1
ptr_hi      .rs 1
mod_a       .rs 1
mod_n       .rs 1

;; CONSTS

PLAY_STATE  = $01
UPF         = $04 ; 15fps (NTSC)

ROW_LEN     = $20
COL_LEN     = $1d

SNAKE_VX    = $01
SNAKE_VY    = $20

SNAKE_V_I   = $00
SNAKE_DIR_I = $00
SNAKE_LEN_I = $00
SNAKE_LEN_MAX  = $1f  ; 32 - 1

HEAD_B_MIN  = $2380 ; non-inclusive range for head wrapping
HEAD_T_MAX  = $2040

HEAD_WRAP   = $0360
HEAD_I      = $2020

SNAKE_X_I   = $00
SNAKE_Y_I   = $07

B_A         = %10000000
B_B         = %01000000
B_SELECT    = %00100000
B_START     = %00010000
B_U         = %00001000
B_D         = %00000100
B_L         = %00000010
B_R         = %00000001

SNAKE_CLR   = $01
BG_CLR      = $00

PPU_PALETTE = $3f00
PPU_BACKGROUND = $2000

FRUIT_TILE_I  = $04
FRUIT_ATTR_I  = $00
FRUIT_SEED_I  = $80

SNAKE_TILE_U  = $0a
SNAKE_TILE_D  = $0b
SNAKE_TILE_L  = $0c
SNAKE_TILE_R  = $0d

SNAKE_TILE_I  = SNAKE_TILE_R
SNAKE_ATTR_I  = $00

SNAKE_SPR_T   = $07
SNAKE_SPR_B   = $df

TILE_LEN    = $08
TILE_MOD    = $20
