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

#include "./ruledef.asm"

leds <- 0b1000
; 0001 is correct
; 1000 is incorrect

r0 <- 0
r1 <- 1

op_ifeq:
  if r0 eq r0      ; 0 == 0
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  if r0 eq r1      ; 0 == 1
    goto fail      ; fail
    leds <- 0b1000 ; pass

  wincr

op_ifgt:
  if r1 gt r0      ; 1 >  0
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  if r1 gt r1      ; 1 >  1
    goto fail      ; fail
    leds <- 0b1000 ; pass

  wincr

  if r0 gt r1      ; 0 >  1
    goto fail      ; fail
    leds <- 0b1000 ; pass

  wincr

op_ifge:
  if r1 ge r1      ; 1 >= 1
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  if r1 ge r0      ; 1 >= 0
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  if r0 ge r1      ; 0 >= 1
    goto fail      ; fail
    leds <- 0b1000 ; pass

  wincr

op_copy:
  r0 <- 0b0101
  r1 <- r0
  if r0 eq r1
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

op_and:
  r0 <- 0b0101
  r1 <- 0b1100
  r2 <- r0 and r1
  r3 <- 0b0100
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

op_or:
  r0 <- 0b0101
  r1 <- 0b1100
  r2 <- r0 or r1
  r3 <- 0b1101
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

op_not:
  r0 <- 0b0101
  r2 <- not r0
  r3 <- 0b1010
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

op_add:
  r0 <- 0b0101
  r1 <- 0b0111
  r2 <- r0 + r1
  r3 <- 0b1100
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  r0 <- 0b0111
  r1 <- 0b0001
  r2 <- r0 + r1
  r3 <- 0b1000
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

op_sub:
  r0 <- 0b0111
  r1 <- 0b0101
  r2 <- r0 - r1
  r3 <- 0b0010
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  r0 <- 0b0111
  r1 <- 0b0001
  r2 <- r0 - r1
  r3 <- 0b0110
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

op_shft:
  r0 <- 0b0111
  r2 <- 0 > r0
  r3 <- 0b0011
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  r0 <- 0b0111
  r2 <- 1 > r0
  r3 <- 0b1011
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  r0 <- 0b0111
  r2 <- r0 < 0
  r3 <- 0b1110
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

  r0 <- 0b0111
  r2 <- r0 < 1
  r3 <- 0b1111
  if r2 eq r3
    leds <- 0b1000 ; pass
    goto fail      ; fail

  wincr

end:
  leds <- 0b1110
  goto $

fail:
  leds <- 0b0111
  goto $
