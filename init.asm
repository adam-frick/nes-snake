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
  sta $2000
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta $2001
  lda #$00          ; no bg scrolling
  sta $2005
  sta $2005

;; init snake
  lda #SNAKE_V_I
  sta snake_v
  lda #SNAKE_DIR_I
  sta snake_dir
  lda #SNAKE_LEN_I
  sta snake_len

  lda #LOW(HEAD_I)
  sta head_lo
  lda #HIGH(HEAD_I)
  sta head_hi

;; init state
  lda #PLAY_STATE
  sta game_state

Loop:
  jmp Loop


