NMI:
  lda #$00
  sta OAM_ADDR
  lda #$02
  sta OAM_DMA

  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta PPU_MASK
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta PPU_CTRL
  lda #$00          ; no bg scrolling
  sta PPU_SCROLL
  sta PPU_SCROLL

  lda #$01
  sta ud_state

NMIMain:

NMICheckCln:
  lda snake_dead
  cmp #$01
  beq SnakeDeath
  lda $2002
  and #%01000000
  cmp #%01000000
  bne Draw

  lda #$01
  sta snake_dead

SnakeDeath:
  jsr DrawSnake
  jsr UDSnakeDeath
  jmp NMIMain_

Draw:
  jsr DrawSnake
  jsr DrawFruit
  jmp NMIMain_

NMIMain_:

  lda #$00
  sta OAM_ADDR
  lda #$02
  sta OAM_DMA
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta PPU_MASK
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta PPU_CTRL
  lda #$00          ; no bg scrolling
  sta PPU_SCROLL
  sta PPU_SCROLL

; interrupt return
  rti
