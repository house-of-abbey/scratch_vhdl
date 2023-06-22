;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 23 April 2022
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

bishift_register:
  leds <- 0b0000

  .sl:             ; shift left
    if btns[0]     ; instantaneous press
      leds <- leds < 1
      leds <- leds < 0
    wincr
    if btns[3]
      goto .sr
      goto .sl

  .sr:             ; shift right
    if btns[3]     ; instantaneous press
      leds <- 1 > leds
      leds <- 0 > leds
    wincr
    if btns[0]
      goto .sl
      goto .sr
