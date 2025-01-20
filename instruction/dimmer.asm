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

#include "./demos/asm/ruledef.asm"

dimmer:
  .s0:
    leds <- 0b0000
    if btns[0]
      goto .s1 ; Jump to "brighter" state
      goto .s0 ; Loop back to start of state
  .s1:
    leds <- 0b0001
    if btns[0]
      goto .s2
      noop     ; Check next "if" if not pressed
    if btns[1]
      goto .s0 ; Jump to "dimmer" state
      goto .s1 ; Loop back to start of state
