NMI:
  lda #$00
  sta $2003   ;RAM lb lda #$02
  lda #$02
  sta $4014   ;RAM hb, start transfer
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta $2001
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta $2000
  lda #$00          ; no bg scrolling
  sta $2005
  sta $2005

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
  sta $2003   ;RAM lb lda #$02
  lda #$02
  sta $4014   ;RAM hb, start transfer
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta $2001
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta $2000
  lda #$00          ; no bg scrolling
  sta $2005
  sta $2005

; interrupt return
  rti
