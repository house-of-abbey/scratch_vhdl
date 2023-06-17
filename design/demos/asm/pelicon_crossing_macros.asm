;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 17 June 2022
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

pelicon_crossing:
  .s0:
    leds <- 0b0001
    wait until btns[0]
  .s1:
    leds <- 0b0010
    wincr
  .s2:
    leds <- 0b0000
    wincr
  .s3:
    leds <- 0b0010
    wincr
  .s4:
    leds <- 0b0000 ; Left filter this time
    wincr
  .s5:
    leds <- 0b0010
    wincr
  .s6:
    leds <- 0b0100
    wait until btns[1]
  .s7:
    leds <- 0b0010
    wincr
    goto pelicon_crossing
