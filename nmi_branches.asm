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

  lda head_lo           ; check if lb is outside bottom row range
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

  lda head_lo           ; check if lb is outside top row range
  cmp #LOW(HEAD_T_MAX)
  bcs UDSnakePosSetUW_

  lda head_lo
  clc
  adc #LOW(HEAD_WRAP)
  sta head_lo
  lda head_hi
  adc #HIGH(HEAD_WRAP)
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

UDSprite:
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

UDSnakeBG:

  lda $2002 ; ready to write to PPU
  
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
