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

r0 <- 0b0000
r4 <- 0b0001
r5 <- 0b0010

loop:
  r1 <- btns and r4
  if r1 eq r4
    r0 <- r0 + r4
    noop
  r1 <- btns and r5
  if r1 eq r5
    r0 <- r0 - r4
    noop
  leds <- 0b0000
  r1 <- 0
  if r0 eq r1
    leds <- 0b0001
    noop
  r1 <- 1
  if r0 eq r1
    leds <- 0b0011
    noop
  r1 <- 2
  if r0 eq r1
    leds <- 0b0111
    noop
  r1 <- 3
  if r0 eq r1
    leds <- 0b1111
    noop
  goto loop
