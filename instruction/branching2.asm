;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 26 May 2024
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
;---------------------------------------------------------------------------------

#include "../design/demos/asm/ruledef.asm"

; Decimal literals
r0   <- 0  ; Terminal value
r1   <- 1  ; Amount to subtract
; Binary literal
leds <- 0b1111

wincr 2
min_out:
  if leds gt r0
    leds <- leds - r1
    goto end
  wincr 1
  goto min_out
end:
;;------------------------------------------------------------------------------
;; Loop forever
goto $     ; (this instruction), i.e. infinite loop
noop       ; Padding for end of simulation and fetch pipeline
noop       ; Padding for end of simulation and fetch pipeline
