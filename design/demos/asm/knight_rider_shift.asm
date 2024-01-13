;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 26 July 2023
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
; A more succint implementation than knight_rider.asm. This solution was
; contributed by A. Sutton.
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

knight_rider_shift: 
  leds <- 0b0001
  r1 <- 1

  .loop:
    if leds[0]
      r0 <- 1
      noop
    if leds[3]
      r0 <- 0
      noop
    if r0 eq r1
      leds <- leds < 0
      leds <- 0 > leds
    wincr
    goto .loop
