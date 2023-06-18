;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 18 June 2023
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
; The binary representation of the number of buttons currently pressed.
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

; For add one operation
r5 <- 1

sum:
  ; Accumulated sum, assign to leds once on completion
  r0 <- 0
  ; Bit to test
  r1 <- 1
  ; Bit 0
  ; Working reg
  r2 <- btns and r1
  if r2 eq r1
    r0 <- r0 + r5
    noop
  r1 <- r1 < 0
  ; Bit 1
  r2 <- btns and r1
  if r2 eq r1
    r0 <- r0 + r5
    noop
  r1 <- r1 < 0
  ; Bit 2
  r2 <- btns and r1
  if r2 eq r1
    r0 <- r0 + r5
    noop
  r1 <- r1 < 0
  ; Bit 3
  r2 <- btns and r1
  if r2 eq r1
    leds <- r0 + r5
    leds <- r0
  goto sum
