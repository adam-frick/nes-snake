NMI:
  lda #$00
  sta $2003   ;RAM lb
  lda #$02
  sta $4014   ;RAM hb, start transfer

  lda #%00010010    ; allow PPU editing outside vblank
  sta $2001

Update:
  jsr UDController
  lda game_state
  cmp #PLAY_STATE
  jsr UDSnakePos
  jsr UDSnakeLen

;; check if on update frame
  clc
  lda game_frame
  adc #$01
  sta game_frame
  and #$07
  cmp #UPF
  beq NMIMain
  jmp NMIMain_

NMIMain:

Draw:
  jsr UDSnakeLenSet
  jsr UDSnakePosSet
  jsr UDSprite
  jsr UDSnakeBG

NMIMain_:

;; PPU cleanup (NES stats)
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta $2000
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta $2001
  lda #$00          ; no bg scrolling
  sta $2005
  sta $2005

;; interrupt return
  rti
