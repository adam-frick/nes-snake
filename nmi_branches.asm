UDSnake: 

; no collision or optimisation yet
UDSnakePos:
  lda buttons
  and #$0F  ; only check dir pad
   
;; check right
  cmp #B_R 
  bne UDSnakePosNR

  pha
  lda #$00
  sta snake_v
  sta snake_dir
  pla
  jmp UDSnakePos_
UDSnakePosNR:
 
;; check left
  cmp #B_L
  bne  UDSnakePosNL

  pha
  lda #$00
  sta snake_v
  lda #$01
  sta snake_dir
  pla
  jmp UDSnakePos_
UDSnakePosNL:

;; check up
  cmp #B_U 
  bne UDSnakePosNU

  pha
  lda #$01
  sta snake_v
  sta snake_dir
  pla
  jmp UDSnakePos_
UDSnakePosNU:
 
;; check down
  cmp #B_D
  bne  UDSnakePosND

  pha
  lda #$01
  sta snake_v
  lda #$00
  sta snake_dir
  pla
UDSnakePosND:
UDSnakePos_:
  rts

UDSnakePosSet:

  ldx snake_len
  dex 
UDSnakePosSetLoop:    ; todo: quite expensive, doesn't keep up with ~35+,
  cpx #$ff            ; could update over course of 2 vblanks (30fps max)
  beq UDSnakePosSetLoop_ 
  lda tail_hi,x
  inx
  sta tail_hi,x
  dex
  lda tail_lo,x
  inx
  sta tail_lo,x
  dex
  dex
  jmp UDSnakePosSetLoop
UDSnakePosSetLoop_:

  lda head_hi
  sta tail_hi
  lda head_lo
  sta tail_lo
  
  lda snake_v
  cmp #$01
  beq UDSnakePosSetY

UDSnakePosSetX:
  lda snake_dir
  cmp #$01
  beq UDSnakePosSetL

UDSnakePosSetR:
  lda head_lo      
  sta mod_a
  clc              
  adc #$01    
  sta head_lo     

  lda head_hi    
  adc #$00      
  sta head_hi  

  lda #ROW_LEN          ; allows snake to wrap horizontally (R) 
  sta mod_n
  jsr Modulus
  cmp #$00
  beq UDSnakePosSetU

  jmp UDSnakePosSet_

UDSnakePosSetL:
  lda head_lo   
  sec          
  sbc #$01    
  sta head_lo  
  sta mod_a

  lda head_hi 
  sbc #$00   
  sta head_hi 

  lda #ROW_LEN          ; allows snake to wrap horizontally (L)
  sta mod_n
  jsr Modulus
  cmp #$00
  beq UDSnakePosSetD

  jmp UDSnakePosSet_

UDSnakePosSetY:
  lda snake_dir
  cmp #$01
  beq UDSnakePosSetU

UDSnakePosSetD:

UDSnakePosSetDW:        ; allows snake to wrap vertically (D)
  lda head_hi
  cmp #HIGH(HEAD_B_MIN)
  bne UDSnakePosSetDW_

  lda head_lo           ; check if lB is outside bottom row range
  cmp #LOW(HEAD_B_MIN)
  bcc UDSnakePosSetDW_

  lda head_lo
  sec
  sbc #LOW(HEAD_WRAP)
  sta head_lo
  lda head_hi
  sbc #HIGH(HEAD_WRAP)
  sta head_hi
  jmp UDSnakePosSet_
UDSnakePosSetDW_:

  lda head_lo   
  clc          
  adc #$20    
  sta head_lo  
  lda head_hi 
  adc #$00   
  sta head_hi 


  jmp UDSnakePosSet_

UDSnakePosSetU:

UDSnakePosSetUW:        ; allows snake to wrap vertically (U)
  lda head_hi
  cmp #HIGH(HEAD_T_MAX)
  bne UDSnakePosSetUW_

  lda head_lo           ; check if lB is outside top row range
  cmp #LOW(HEAD_T_MAX)
  bcs UDSnakePosSetUW_

  lda head_lo
  clc
  adc #LOW(HEAD_WRAP)
  sta head_lo
  lda head_hi
  Adc #HIGH(HEAD_WRAP)
  sta head_hi
  jmp UDSnakePosSet_
UDSnakePosSetUW_:


  lda head_lo   
  sec          
  sbc #$20    
  sta head_lo  
  lda head_hi 
  sbc #$00   
  sta head_hi 
  jmp UDSnakePosSet_

UDSnakePosSet_:
  rts

UDSnakeLen:
  lda buttons
  and #B_A
  cmp #B_A
  bne UDSnakeLen_
  lda #$01
  sta snake_len_v
UDSnakeLen_:
  rts

UDSnakeLenSet:
  lda snake_len
  cmp #SNAKE_LEN_MAX
  beq UDSnakeLenSet_
  clc
  adc snake_len_v
  sta snake_len
UDSnakeLenSet_:
  lda #$00
  sta snake_len_v
  rts

UDFruit:
  lda $2002
  and #%01000000
  cmp #%01000000
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

UDFruitX:
  jsr Random
  lda fruit_seed
  and #%11111000  ; only multiple of 8
  sta fruit_x

UDFruitY:
  jsr Random
  lda fruit_seed
  cmp #$d1        ; within screen range
  bcc UDFruitY_
  sec
  sbc #$20        ; slight edge tile bias
UDFruitY_:
  and #%11111000  ; only multiple of 8
  sec
  sbc #$01
  sta fruit_y  

UDFruitSet_:
  rts

DrawFruit:
  lda fruit_y
  sta $0200
  lda fruit_tile
  sta $0201
  lda fruit_attr
  sta $0202
  lda fruit_x
  sta $0203

  rts

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

DrawSnake:

  lda $2002 ; PPU ready
  
  ldx snake_len
  lda tail_hi, x
  sta $2006
  lda tail_lo, x
  sta $2006
  lda #BG_CLR
  sta $2007

  lda head_hi
  sta $2006
  lda head_lo
  sta $2006

  lda #SNAKE_CLR
  sta $2007

  rts

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
