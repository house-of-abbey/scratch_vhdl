;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 18 June 2023
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

; Simple version with no start/stop buttons

knight_rider:
  .s0:
    leds <- 1
    wincr
  .s1:
    leds <- 2
    wincr
  .s2:
    leds <- 4
    wincr
  .s3:
    leds <- 8
    wincr
  .s4:
    leds <- 4
    wincr
  .s5:
    leds <- 2
    wincr
  goto .s0
