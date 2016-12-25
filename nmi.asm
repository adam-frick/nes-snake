NMI:
  lda #$00
  sta $2003   ;RAM lb lda #$02
  lda #$02
  sta $4014   ;RAM hb, start transfer
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta $2001

  lda #$01
  sta ud_state

NMIMain:

NMICheckCln:
  ;lda snake_dead
  ;cmp #$01
  ;beq SnakeDeath
  lda $2002
  ;and #%01000000
  ;cmp #%01000000
  ;bne Draw

  ;lda #$01
  ;sta snake_dead

SnakeDeath:
  ;jsr DrawSnake
  ;jsr UDSnakeDeath
  ;jmp NMIMain_

Draw:
  jsr DrawSnake
  jsr DrawFruit
  jmp NMIMain_

NMIMain_:

; interrupt return
  rti
