  .inesprg 1  ; 1x 16KB PRG code
  .ineschr 1  ; 1x 8KB CHR data
  .inesmap 0  ; mapper 0 NROM, no bank swapping
  .inesmir 1  ; background mirroring

  .include "var.asm"  ; var declaration
  .include "init.asm" ; sets up PPU
  .include "nmi.asm"  ; runs each vblank
  .include "math.asm" ; modulus and RNG 
  .include "nmi_branches.asm" ; updates snake

  .include "tiles.asm"

  .org $FFFA     ; vectors for init (bank 1)
  .dw NMI        ; update label
  .dw Reset      ; init label
  .dw 0          ; external interrupt IRQ turned off

  .bank 2
  .org $0000
  .incbin "tileset.chr"   ; graphics

