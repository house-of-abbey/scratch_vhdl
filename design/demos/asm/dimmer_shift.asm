;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 26 July 2023
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
; A more succint implementation than dimmer.asm and dimmer_macros.asm.
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

dimmer_shift:
  if btns[0]
    leds <- leds < 1
    noop
  if btns[1]
    leds <- 0 > leds
    noop
  wincr
  goto dimmer_shift
