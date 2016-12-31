UDController:
  lda #$01  ; latch controllers
  sta JOYPAD
  lda #$00
  sta JOYPAD

  ldx #$08
UDControllerLoop:
  lda JOYPAD
  lsr a
  rol buttons
  dex
  bne UDControllerLoop
  
  rts

