  .inesprg 1  ; 1x 16KB PRG code
  .ineschr 1  ; 1x 8KB CHR data
  .inesmap 0  ; mapper 0 NROM, no bank swapping
  .inesmir 1  ; background mirroring

; var declaration
;-------------------------------------------------

  .rsset $0000  ;; vars at beginning of mem

game_state  .rs 1
game_frame  .rs 1

; 0: x, 1:y
snake_v     .rs 1
; 0: Q4, 1:Q2
snake_dir 	.rs 1

snake_len   .rs 1

head_lo     .rs 1
head_hi     .rs 1

tail_lo     .rs 30
tail_hi     .rs 30

buttons     .rs 1
points      .rs 1

ptr_lo      .rs 1
ptr_hi      .rs 1

;; CONSTS

PLAY_STATE  = $01
UPF         = $04 ; 15fps (NTSC)

WALL_U      = $05
WALL_D      = $e0
WALL_L      = $04
WALL_R      = $fa 

SNAKE_VX    = $01
SNAKE_VY    = $20

SNAKE_V_I   = $00
SNAKE_DIR_I = $00
SNAKE_LEN_I = $00

HEAD_I      = $2350

B_A         = %10000000
B_B         = %01000000
B_SELECT    = %00100000
B_START     = %00010000
B_U         = %00001000
B_D         = %00000100
B_L         = %00000010
B_R         = %00000001

SNAKE_CLR   = $01
BG_CLR      = $09

PPU_PALETTE = $3f00
PPU_BACKGROUND = $2000

;-------------------------------------------------
; /var declaration


; init
;-------------------------------------------------

  .bank 0
  .org $C000

Reset:
  sei       ; disable IRQs
  cld       ; disable decimal mode
  ldx #$40  ; 
  stx $4017 ; disable APU frame IRQ
  ldx #$ff
  txs       ; set up stack
  inx       ; x = 0
  stx $2000 ; disable NMI
  stx $2001 ; disable rendering
  stx $4010 ; disable DMC IRQs

VBlankWait1:  ; make sure PPU is ready
  bit $2002
  bpl VBlankWait1

ClearMem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$fe
  sta $0200, x
  inx
  bne ClearMem

VBlankWait2:    ; PPU ready after this
  bit $2002
  bpl VBlankWait2

LoadPalettes:
  lda $2002   ; reset hi/lo latch of PPU
  lda #HIGH(PPU_PALETTE)
  sta $2006   
  lda #LOW(PPU_PALETTE)
  sta $2006   

  ldx #$00
LoadPalettesLoop:
  lda palette, x    ; load palette data to a
  sta $2007         ; store palette data to PPU
  inx
  cpx #$20          ; stops after 4 sprites
  bne LoadPalettesLoop

LoadBackground:
  lda $2002 ; reset hi/lo latch of PPU
  lda #HIGH(PPU_BACKGROUND)
  sta $2006
  lda #LOW(PPU_BACKGROUND)
  sta $2006

  lda #$00
  sta ptr_lo  ;bg lB
  lda #HIGH(background)
  sta ptr_hi

  ldx #$00
  ldy #$00
LoadBackgroundOL:

LoadBackgroundIL:
  lda [ptr_lo], y   ; 1 bg byte
  sta $2007

  iny
  cpy #$00
  bne LoadBackgroundIL  ; stop when overflow (256)

  inc ptr_hi

  inx
  cpx #$04
  bne LoadBackgroundOL  ; stop when overflow (256)



;; init nes
  lda #%10010000    ; enable NMI, spr: table 0, bg: table 1
  sta $2000
  lda #%00011110    ; enable spr and bg, no clipping on left 
  sta $2001
  lda #$00          ; no bg scrolling
  sta $2005
  sta $2005

;; init snake
  lda #SNAKE_V_I
  sta snake_v
  lda #SNAKE_DIR_I
  sta snake_dir
  lda #SNAKE_LEN_I
  sta snake_len

  lda #LOW(HEAD_I)
  sta head_lo
  lda #HIGH(HEAD_I)
  sta head_hi

;; init state
  lda #PLAY_STATE
  sta game_state


Loop:
  jmp Loop
;-------------------------------------------------
; /init


; NMI
;-------------------------------------------------
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
;-------------------------------------------------
; /NMI

; branches
;-------------------------------------------------

UDSnake:    ;;;;;

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

  clc
  lda snake_len
  rol a
  tax
  lda head_hi
  sta tail_hi,x
  lda head_lo
  sta tail_lo,x
  
  lda snake_v
  cmp #$01
  beq UDSnakePosSetY

UDSnakePosSetX:
  lda snake_dir
  cmp #$01
  beq UDSnakePosSetL

UDSnakePosSetR:
  lda head_lo      
  clc              
  adc #$01    
  sta head_lo     
  lda head_hi    
  adc #$00      
  sta head_hi  
  jmp UDSnakePosSet_

UDSnakePosSetL:
  lda head_lo   
  sec          
  sbc #$01    
  sta head_lo  
  lda head_hi 
  sbc #$00   
  sta head_hi 
  jmp UDSnakePosSet_

UDSnakePosSetY:
  lda snake_dir
  cmp #$01
  beq UDSnakePosSetU

UDSnakePosSetD:
  lda head_lo   
  clc          
  adc #$20    
  sta head_lo  
  lda head_hi 
  adc #$00   
  sta head_hi 
  jmp UDSnakePosSet_

UDSnakePosSetU:
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


UDSprite:

  rts ;;;

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

  
  clc
  lda snake_len
  rol a
  tax
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

; data
;-------------------------------------------------

  .bank 1
  .org $E000

background:

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09 ; 5
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09


  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09 ; 10
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09


  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09 ; 15
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09


  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09 ; 20
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09


  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09 ; 25
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09


  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09

  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09 ; 30
  .db $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09


attributes:  ;8 x 8 = 64 bytes

  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  .db %00000000,%00000000,%00000000,%00000000
  




palette:
  .db $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F  ;background palette
  .db $0F,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C  ;sprite palette

  .org $FFFA     ; vectors for init
  .dw NMI        ; update label
  .dw Reset      ; init label
  .dw 0          ; external interrupt IRQ turned off

  .bank 2
  .org $0000
  .incbin "tileset.chr"   ; graphics

;-------------------------------------------------
; /data

