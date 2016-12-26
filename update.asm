UDController:
  lda #$01  ; latch controllers
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

