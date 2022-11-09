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

fibonacci:
  r0 <- 0
  leds <- 1
  .loop:
    r1 <- leds
    leds <- r0 + leds
    r0 <- r1
    wincr
    goto .loop
