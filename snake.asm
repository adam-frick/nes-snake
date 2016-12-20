  .inesprg 1  ; 1x 16KB PRG code
  .ineschr 1  ; 1x 8KB CHR data
  .inesmap 0  ; mapper 0 NROM, no bank swapping
  .inesmir 1  ; background mirroring

; var declaration
;-------------------------------------------------

  .rsset $0000  ;; vars at beginning of mem

game_state  .rs 1

snake_x     .rs 1
snake_y     .rs 1
snake_vx    .rs 1
snake_vy    .rs 1
snake_dir 	.rs 1

;tail_x      .rs 32
;tail_y      .rs 30

buttons     .rs 1

points      .rs 1

;; CONSTS

PLAY_STATE  = $01
WALL_U      = $05
WALL_D      = $e0
WALL_L      = $04
WALL_R      = $fa 
SNAKE_X_I   = $10
SNAKE_Y_I   = $20
SNAKE_VX_I  = $01
SNAKE_VY_I  = $00

B_A         = %10000000
B_B         = %01000000
B_SELECT    = %00100000
B_START     = %00010000
B_U         = %00001000
B_D         = %00000100
B_L         = %00000010
B_R         = %00000001

;-------------------------------------------------
; /var declaration


; init
;-------------------------------------------------

  .bank 0
  .org $C000

Reset:
  sei       ; disable IRQs
  cld       ; disable decimal mode
  ldx #$40  ; 
  stx $4017 ; disable APU frame IRQ
  ldx #$ff
  txs       ; set up stack
  inx       ; x = 0
  stx $2000 ; disable NMI
  stx $2001 ; disable rendering
  stx $4010 ; disable DMC IRQs

VBlankWait1:  ; make sure PPU is ready
  bit $2002
  bpl VBlankWait1

ClearMem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$fe
  sta $0200, x
  inx
  bne ClearMem

VBlankWait2:    ; PPU ready after this
  bit $2002
  bpl VBlankWait2

LoadPalettes:
  lda $2002   ; reset hi/lo hatch of PPU
  lda #$3f
  sta $2006   ; $3f00 hb
  lda #$00
  sta $2006   ; $3f00 lb

  ldx #$00
LoadPalettesLoop:
  lda palette, x    ; load palette data to a
  sta $2007         ; store palette data to PPU
  inx
  cpx #$20          ; stops after 4 sprites
  bne LoadPalettesLoop

;; init snake
	lda #SNAKE_X_I
	sta snake_x
	lda #SNAKE_Y_I
	sta snake_y
  lda #SNAKE_VX_I
  sta snake_vx
  lda #SNAKE_VY_I
  sta snake_vy

;; init state
  lda #PLAY_STATE
  sta game_state

;; init nes
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta $2000
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta $2001
  lda #$00          ; no bg scrolling
  sta $2005
  sta $2005

Loop:
  jmp Loop
;-------------------------------------------------
; /init


; NMI
;-------------------------------------------------
NMI:
  lda #$00
  sta $2003   ;RAM lb
  lda #$02
  sta $4014   ;RAM hb, start transfer

;; PPU cleanup (NES stats)
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta $2000
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta $2001
  lda #$00          ; no bg scrolling
  sta $2005
  sta $2005


Update:
  jsr UDController

  lda game_state
  cmp #PLAY_STATE
  beq UDSnake

Draw:
  jsr UDSprite
  ; jsr UDBackground

;; interrupt return
  rti
;-------------------------------------------------
; /NMI

; branches
;-------------------------------------------------

UDSnake:    ;;;;;


; no collision or optimisation yet
UDSnakePos:
  lda buttons
  and #$0F  ; only check dir pad
   
;; check right
  cmp #B_R 
  bne UDSnakePosNR

  pha
  lda #$01
  sta snake_vx
  lda #$00
  sta snake_vy
  pla
  jmp UDSnakePos_
UDSnakePosNR:
 
;; check left
  cmp #B_L
  bne  UDSnakePosNL

  pha
  lda #$ff
  sta snake_vx
  lda #$00
  sta snake_vy
  pla
  jmp UDSnakePos_
UDSnakePosNL:

;; check up
  cmp #B_U 
  bne UDSnakePosNU

  pha
  lda #$ff
  sta snake_vy
  lda #$00
  sta snake_vx
  pla
  jmp UDSnakePos_
UDSnakePosNU:
 
;; check down
  cmp #B_D
  bne  UDSnakePosND

  pha
  lda #$01
  sta snake_vy
  lda #$00
  sta snake_vx
  pla
UDSnakePosND:

UDSnakePos_:

  clc
  lda snake_x
  adc snake_vx
  sta snake_x

  clc
  lda snake_y
  adc snake_vy
  sta snake_y

  jmp Draw


UDSprite:

;; todo: draw snake to background
;; snake update
  lda snake_y
  sta $0200
  lda #$00
  sta $0201
  lda #$00
  sta $0202
  lda snake_x
  sta $0203

  rts ;;;

UDController:
  lda #$01
  sta $4016
  lda #$00
  sta $4016

  ldx #$08
UDControllerLoop:
  lda $4016
  lsr a
  rol buttons
  dex
  bne UDControllerLoop
  
  rts

; data
;-------------------------------------------------

  .bank 1
  .org $E000

palette:
  .db $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F  ;background palette
  .db $0F,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C  ;sprite palette

  .org $FFFA     ; vectors for init
  .dw NMI        ; update label
  .dw Reset      ; init label
  .dw 0          ; external interrupt IRQ turned off

  .bank 2
  .org $0000
  .incbin "tileset.chr"   ; graphics

;-------------------------------------------------
; /data

