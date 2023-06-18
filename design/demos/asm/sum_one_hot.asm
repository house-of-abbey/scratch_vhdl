;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 18 June 2023
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
; The one hot representation of the number of buttons currently pressed.
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

sum:
  ; Accumulate one bit per button, assign to leds once on completion
  r0 <- 0
  ; Bit to test
  r1 <- 1
  ; Bit 0
  ; Working reg
  r2 <- btns and r1
  if r2 eq r1
    r0 <- r0 < 1
    noop
  r1 <- r1 < 0
  ; Bit 1
  r2 <- btns and r1
  if r2 eq r1
    r0 <- r0 < 1
    noop
  r1 <- r1 < 0
  ; Bit 2
  r2 <- btns and r1
  if r2 eq r1
    r0 <- r0 < 1
    noop
  r1 <- r1 < 0
  ; Bit 3
  r2 <- btns and r1
  if r2 eq r1
    r0 <- r0 < 1
    noop
  ; Convert one bit per button to precisely one bit, the most significant.
  ; For example:
  ; r0         = 0111
  r2 <- 0 > r0
  ; r2         = 0011
  r2 <- not r2
  ; !r2        = 1100
  ; r0 and !r2 = 0100
  leds <- r0 and r2
  goto sum
