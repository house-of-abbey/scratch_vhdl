;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 23 April 2022
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
; Demonstrates the origin of the 'op_ifbit' instruction and the "if btns[x]"
; assembler macros. See file "dimmer_macros.asm".
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

; Increment button
r4 <- 0b0010
; Decrement button
r5 <- 0b0001

dimmer:
  .b0:
    leds <- 0b0000
    wincr
    r1 <- btns and r4
    if r1 eq r4 ; Increment
      goto .b1
      goto .b0
  .b1:
    leds <- 0b0001
    wincr
    r1 <- btns and r4
    if r1 eq r4 ; Increment
      goto .b2
      noop
    r1 <- btns and r5
    if r1 eq r5 ; Decrement
      goto .b0
      goto .b1
  .b2:
    leds <- 0b0011
    wincr
    r1 <- btns and r4
    if r1 eq r4 ; Increment
      goto .b3
      noop
    r1 <- btns and r5
    if r1 eq r5 ; Decrement
      goto .b1
      goto .b2
  .b3:
    leds <- 0b0111
    wincr
    r1 <- btns and r4
    if r1 eq r4 ; Increment
      goto .b4
      noop
    r1 <- btns and r5
    if r1 eq r5 ; Decrement
      goto .b2
      goto .b3
  .b4:
    leds <- 0b1111
    wincr
    r1 <- btns and r5
    if r1 eq r5 ; Decrement
      goto .b3
      goto .b4
