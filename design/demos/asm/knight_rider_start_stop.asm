;---------------------------------------------------------------------------------
;
; Distributed under MIT Licence
;   See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
;
; J D Abbey & P A Abbey, 18 June 2023
;
; https://github.com/hlorenzi/customasm/wiki/Getting-started
;
;---------------------------------------------------------------------------------

#include "./ruledef.asm"

; Clever version with start/stop buttons

#ruledef
{
  btnschk => asm {
    if btns[0]
      r0 <- 1 ; start
      noop
    if btns[1]
      r0 <- 0 ; stop
      noop
  }
}

knight_rider:
  ; Execute if r0 bit 0 is one, else stop
  r0 <- 0
  btnschk
  .s0:
    leds <- 1
    wincr
    btnschk
    if r0[0]
      goto .s1
      goto .s0
  .s1:
    leds <- 2
    wincr
    btnschk
    if r0[0]
      goto .s2
      goto .s1
  .s2:
    leds <- 4
    wincr
    btnschk
    if r0[0]
      goto .s3
      goto .s2
  .s3:
    leds <- 8
    wincr
    btnschk
    if r0[0]
      goto .s4
      goto .s3
  .s4:
    leds <- 4
    wincr
    btnschk
    if r0[0]
      goto .s5
      goto .s4
  .s5:
    leds <- 2
    wincr
    btnschk
    if r0[0]
      goto .s0
      goto .s5
