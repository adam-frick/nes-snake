UDSnake: 
UDSnakePos:
  lda buttons
  and #$0f    ; only check dir pad

;; check right
  cmp #B_R          ; check if pressed 
  bne UDSnakePosNR
  ldx snake_v       ; can only alternate between axes
  cpx #$01
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
  bne UDSnakePosNL
  ldx snake_v
  cpx #$01
  bne UDSnakePosNR

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
  ldx snake_v
  cpx #$00
  bne UDSnakePosNR

  pha
  lda #$01
  sta snake_v
  sta snake_dir
  pla
  jmp UDSnakePos_
UDSnakePosNU:
 
;; check down
  cmp #B_D 
  bne UDSnakePosND
  ldx snake_v
  cpx #$00
  bne UDSnakePosNR

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

  lda snake_len
  tay
  sec
  sbc #$01
  tax
UDSnakePosSetLoop:    ; todo: quite expensive, doesn't keep up with ~35+,
  cpx #$ff            ; could update over course of 2 vblanks (30fps max)
  beq UDSnakePosSetLoop_ 

  lda tail_hi,x
  sta tail_hi,y
  lda tail_lo,x
  sta tail_lo,y
  
  lda tail_dir,x
  sta tail_dir,y

  dex
  dey
  jmp UDSnakePosSetLoop
UDSnakePosSetLoop_:

  lda head_hi
  sta tail_hi
  lda head_lo
  sta tail_lo

  lda snake_tile
  eor #%00000001      ; offset dir
  sta tail_dir
  
  lda snake_dead
  cmp #$01
  bne UDSnakePosSetCont
  rts

UDSnakePosSetCont:
  lda snake_v
  cmp #$01
  beq UDSnakePosSetY

UDSnakePosSetX:
  lda snake_dir
  cmp #$01
  beq UDSnakePosSetL

UDSnakePosSetR:

  lda #$01        ; if reach edge, sprite vert update ignored
  sta ud_bg_only

  lda head_lo      
  sta mod_a
  clc              
  adc #$01    
  sta head_lo     

  lda head_hi    
  adc #$00      
  sta head_hi  

  lda snake_x   ; sprite
  adc #TILE_LEN
  sta snake_x
  lda #SNAKE_TILE_R
  sta snake_tile

  lda #ROW_LEN          ; allows snake to wrap horizontally (R) 
  sta mod_n
  jsr Modulus
  cmp #$00
  bne UDSnakePosSetR_
  jmp UDSnakePosSetU    ; branch out of range
UDSnakePosSetR_:
  jmp UDSnakePosSet_ 

UDSnakePosSetL:

  lda #$01        ; if reach edge, sprite vert update ignored
  sta ud_bg_only

  lda head_lo   
  sec          
  sbc #$01    
  sta head_lo  
  sta mod_a

  lda head_hi 
  sbc #$00   
  sta head_hi 

  lda snake_x   ; sprite
  sbc #TILE_LEN
  sta snake_x
  lda #SNAKE_TILE_L
  sta snake_tile

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

  lda #SNAKE_SPR_T    ; sprite
  sta snake_y

  jmp UDSnakePosSet_
UDSnakePosSetDW_:

  lda head_lo   
  clc          
  adc #$20    
  sta head_lo  
  lda head_hi 
  adc #$00   
  sta head_hi 

  lda ud_bg_only
  cmp #$01
  beq UDSnakePosSet_

  lda snake_y   ; sprite
  adc #TILE_LEN
  sta snake_y
  lda #SNAKE_TILE_D
  sta snake_tile

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
  adc #HIGH(HEAD_WRAP)
  sta head_hi

  lda #SNAKE_SPR_B    ; sprite
  sta snake_y

  jmp UDSnakePosSet_
UDSnakePosSetUW_:

  lda head_lo   
  sec          
  sbc #$20    
  sta head_lo  
  lda head_hi 
  sbc #$00   
  sta head_hi 

  lda ud_bg_only
  cmp #$01
  beq UDSnakePosSet_
  lda snake_y   ; sprite
  sec
  sbc #TILE_LEN
  sta snake_y
  lda #SNAKE_TILE_U
  sta snake_tile

  jmp UDSnakePosSet_

UDSnakePosSet_:
  lda #$00
  sta ud_bg_only
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

UDSnakeDeath:
  lda snake_len
  inx
  lda tail_hi
  cmp tail_hi, x
  bne UDSnakeDeath_
  lda tail_lo
  cmp tail_lo, x
  bne UDSnakeDeath_

  lda tail_hi, x
  sta $2006
  lda tail_lo, x
  sta $2006
  lda #BG_CLR
  sta $2007

  lda snake_y
  sta $0200
  lda #$00
  sta $0201
  lda snake_attr
  sta $0202
  lda snake_x
  sta $0203
  rts

UDSnakeDeath_:
  rts
