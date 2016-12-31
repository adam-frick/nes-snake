
DrawFruit:

;; drawing fruit sprite
  lda fruit_y
  sta $0204
  lda fruit_tile
  sta $0205
  lda fruit_attr
  sta $0206
  lda fruit_x
  sta $0207
  rts

DrawSnake:
  lda PPU_STATUS  ; PPU ready 
  
DrawSnakeSprite:
  lda snake_dead
  cmp #$01
  beq DrawSnakeSprite_

;; drawing snake head sprite
  lda snake_y
  sta $0200
  lda snake_tile
  sta $0201
  lda snake_attr
  sta $0202
  lda snake_x
  sta $0203
DrawSnakeSprite_:

DrawSnakeBG:

;; draw beginning of snake tail (if applicable)
  lda snake_dead
  cmp #$01
  beq DrawSnakeBG_

  lda tail_hi
  sta PPU_ADDR
  lda tail_lo
  sta PPU_ADDR

  lda #SNAKE_CLR
  sta PPU_DATA

DrawSnakeBG_:

  ldx snake_len
  lda tail_hi, x
  sta PPU_ADDR
  lda tail_lo, x
  sta PPU_ADDR
  lda #BG_CLR
  sta PPU_DATA

DrawSnakeBGTaper:
  dex
  lda tail_hi, x
  sta PPU_ADDR
  lda tail_lo, x
  sta PPU_ADDR

  cpx #$00
  beq BGTaperSmall
  dex
BGTaperSmall:
  lda tail_dir, x
  sta PPU_DATA
  rts
