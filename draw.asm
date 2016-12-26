
DrawFruit:
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
  lda $2002 ; PPU ready
  
DrawSnakeSprite:
  lda snake_dead
  cmp #$01
  beq DrawSnakeSprite_

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
  lda snake_dead
  cmp #$01
  beq DrawSnakeBG_

  lda tail_hi
  sta $2006
  lda tail_lo
  sta $2006

  lda #SNAKE_CLR
  sta $2007
DrawSnakeBG_:

  ldx snake_len
  lda tail_hi, x
  sta $2006
  lda tail_lo, x
  sta $2006
  lda #BG_CLR
  sta $2007

DrawSnakeBGTaper:
  dex
  lda tail_hi, x
  sta $2006
  lda tail_lo, x
  sta $2006

  cpx #$00
  beq BGTaperSmall
  dex
BGTaperSmall:
  lda tail_dir, x
  sta $2007
  rts
