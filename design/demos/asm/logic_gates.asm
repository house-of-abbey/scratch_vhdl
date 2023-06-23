;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 23 June 2023
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

; Shadow changes to the LEDs, then assign to LEDs at the same time when all decision are made
r5 <- 0b0000
leds <- 0b0000
; Effectively two constants
r0 <- 0b0000
r4 <- 0b1111

loop:
  r1 <- 0b0001
  r2 <- 0b1110
  if btns eq r4 ; AND
    r5 <- r5 or r1
    r5 <- r5 and r2
  r1 <- 0b0010
  r2 <- 0b1101
  if btns gt r0 ; OR
    r5 <- r5 or r1
    r5 <- r5 and r2
  ; NB. We have no simple XOR solution, requires multiple tests
  r1 <- 0b0100
  r2 <- 0b1011
  if btns eq r4 ; NAND
    r5 <- r5 and r2
    r5 <- r5 or r1
  r1 <- 0b1000
  r2 <- 0b0111
  if btns gt r0 ; NOR
    r5 <- r5 and r2
    r5 <- r5 or r1
  leds <- r5 ; Update all the LEDS at the same time rather than independently (but that is also a solution)
  wincr
  goto loop
