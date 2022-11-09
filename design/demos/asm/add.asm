;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 6 November 2022
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

; These can be used for LEDs or buttons
           ; bit
bit0 = 0x1 ; 0
bit1 = 0x2 ; 1
bit2 = 0x4 ; 2
bit3 = 0x8 ; 3

r0 <- 3
r1 <- 0b0000

loop:
  leds <- r0 + btns
  wincr 3
  leds <- btns and r1
  wincr 1
  goto loop
