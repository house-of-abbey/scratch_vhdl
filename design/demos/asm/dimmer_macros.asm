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

dimmer:
  .b0:
    leds <- 0b0000
    wincr
    if btns[0]
      goto .b1
      noop
    goto .b0
  .b1:
    leds <- 0b0001
    wincr
    if btns[0]
      goto .b2
      noop
    if btns[1]
      goto .b0
      goto .b1
  .b2:
    leds <- 0b0011
    wincr
    if btns[0]
      goto .b3
      noop
    if btns[1]
      goto .b1
      goto .b2
  .b3:
    leds <- 0b0111
    wincr
    if btns[0]
      goto .b4
      noop
    if btns[1]
      goto .b2
      goto .b3
  .b4:
    leds <- 0b1111
    wincr
    if btns[1]
      goto .b3
      goto .b4
