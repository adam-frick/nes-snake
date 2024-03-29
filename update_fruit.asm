UDFruit:
  lda snake_x
  cmp fruit_x
  bne UDFruit_
  lda snake_y
  cmp fruit_y
  bne UDFruit_
  lda #$01
  sta fruit_hit
  sta snake_len_v

UDFruit_:
  rts

UDFruitSet:
  lda fruit_hit
  cmp #$01
  bne UDFruitSet_

  lda #$00
  sta fruit_hit

;; fruit collect SFX
  lda #%00001000      ; mid freq.
  ora #%10000000      ; buzz
  sta $400e
  lda #%01111000      ; sound length
  sta $400f

UDFruitX:
  jsr Random
  lda fruit_seed
UDFruitX_
  and #%11111000  ; only multiple of 8
  sta fruit_x

UDFruitY:
  jsr Random
  lda fruit_seed
  cmp #$09
  bcc UDFruitYInRange
  cmp #$e8        ; within screen range
  bcc UDFruitY_
UDFruitYInRange:
  sec
  sbc #$20        ; slight edge tile bias
UDFruitY_
  and #%11111000  ; only multiple of 8
  sec
  sbc #$01        ; y coord grid offset by 1
  sta fruit_y  

UDFruitSet_:
  rts
