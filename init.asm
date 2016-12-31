  .bank 0
  .org $8000

Reset:
  sei       ; disable IRQs
  cld       ; disable decimal mode
  ldx #$40  ; 
  stx $4017 ; disable APU frame IRQ
  ldx #$ff
  txs       ; set up stack
  inx       ; x = 0
  stx PPU_CTRL  ; disable NMI
  stx PPU_MASK ; disable rendering
  stx $4010 ; disable DMC IRQs

VBlankWait1:  ; make sure PPU is ready
  bit PPU_STATUS
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
  lda $2002   ; reset hi/lo latch of PPU
  lda #HIGH(PPU_PALETTE)
  sta $2006   
  lda #LOW(PPU_PALETTE)
  sta $2006   

  ldx #$00
LoadPalettesLoop:
  lda palette, x    ; load palette data to a
  sta $2007         ; store palette data to PPU
  inx
  cpx #$20          ; stops after 4 sprites
  bne LoadPalettesLoop

LoadBackground:
  lda $2002 ; reset hi/lo latch of PPU
  lda #HIGH(PPU_BACKGROUND)
  sta $2006
  lda #LOW(PPU_BACKGROUND)
  sta $2006

  lda #$00
  sta ptr_lo  ;bg lB
  lda #HIGH(background)
  sta ptr_hi

  ldx #$00
  ldy #$00
LoadBackgroundOL:

LoadBackgroundIL:
  lda [ptr_lo], y   ; 1 bg byte
  sta $2007

  iny
  cpy #$00
  bne LoadBackgroundIL  ; stop when overflow (256)

  inc ptr_hi

  inx
  cpx #$04
  bne LoadBackgroundOL  ; stop when overflow (256)



;; init nes
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta PPU_CTRL
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta PPU_MASK
  lda #$00          ; no bg scrolling
  sta PPU_SCROLL
  sta PPU_SCROLL

;; init APU
  lda #%0001000       ; enable noise channel
  sta $4015
  lda #%00011111      ; constant and loudest volume
  sta $400c
         
;; init snake
  lda #SNAKE_V_I
  sta snake_v
  lda #SNAKE_DIR_I
  sta snake_dir
  lda #SNAKE_LEN_I
  sta snake_len
  lda #$00
  sta snake_dead

  lda #LOW(HEAD_I)
  sta head_lo
  lda #HIGH(HEAD_I)
  sta head_hi

  lda #FRUIT_TILE_I
  sta fruit_tile
  lda #FRUIT_ATTR_I
  sta fruit_attr
  lda #FRUIT_SEED_I
  sta fruit_seed
  sta fruit_x
  sec
  sbc #$01
  sta fruit_y

  lda #SNAKE_Y_I
  sta snake_y
  lda #SNAKE_TILE_I
  sta snake_tile
  lda #SNAKE_ATTR_I
  sta snake_attr
  lda #SNAKE_X_I
  sta snake_x

;; init state
  lda #PLAY_STATE
  sta game_state
  lda #UD_STATE_I
  sta ud_state

Loop:
  lda ud_state
  cmp #$01
  bne Loop_
;; check if on update frame
  clc
  lda game_frame
  adc #$01
  sta game_frame
  and #$07
  cmp #UPF
  beq Update
  jmp Update_
  
Update:
  lda #$00
  sta game_frame

  jsr UDController
  jsr UDSnakePos
  jsr UDSnakeLen

  jsr UDSnakePosSet
  jsr UpdateSeed
  jsr UDFruit
  jsr UDFruitSet
  jsr UDSnakeLenSet
Update_:
  lda #$00
  sta ud_state
  
Loop_:
  jmp Loop
