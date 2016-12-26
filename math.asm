Modulus:
  lda mod_a
  sec
ModulusLoop:
  sbc mod_n
  bcs ModulusLoop
  adc #$01
  rts

UpdateSeed:   ; once per vblank
  lda fruit_seed
  clc
  adc #$01
  sta fruit_seed
  rts

Random:   ; LFSR algorithm
  lda fruit_seed
  beq RandomEOR
  asl a
  beq Random_
  bcc Random_
RandomEOR:
  eor #$1d
Random_:
  sta fruit_seed
  rts
