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

traffic_lights:
  .s0:
    leds <- 0b0001
    wincr
    .s0_loop:
      r0 <- 0b0001
      r1 <- btns and r0
      if r1 eq r0
        goto .s1
        goto .s0_loop
  .s1:
    leds <- 0b0011
    wincr
  .s2:
    leds <- 0b0100
    wincr
    .s2_loop:
      r0 <- 0b0010
      r1 <- btns and r0
      if r1 eq r0
        goto .s3
        goto .s2_loop
  .s3:
    leds <- 0b0010
    wincr
  .s4:
    leds <- 0b1001
    wincr
    .s5_loop:
      r0 <- 0b0001
      r1 <- btns and r0
      if r1 eq r0
        goto .s5
        goto .s5_loop
  .s5:
    leds <- 0b0011
    wincr
  .s6:
    leds <- 0b0100
    wincr
    .s6_loop:
      r0 <- 0b0010
      r1 <- btns and r0
      if r1 eq r0
        goto .s7
        goto .s6_loop
  .s7:
    leds <- 0b0010
    wincr
  goto traffic_lights
  
