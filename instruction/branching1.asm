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
r0   <- 15 ; Terminal value
r1   <- 1  ; Amount to add
; Binary literal
leds <- 0b0000

wincr 2
max_out:
  if leds eq r0
    goto end
    leds <- leds + r1
  wincr 1
  goto max_out
end:
;;------------------------------------------------------------------------------
;; Loop forever
goto $     ; (this instruction), i.e. infinite loop
noop       ; Padding for end of simulation and fetch pipeline
noop       ; Padding for end of simulation and fetch pipeline
