#include "./ruldef.asm"

fibonacci:
  r0 <- 0
  leds <- 1
  .loop:
    r1 <- leds
    leds <- r0 + leds
    r0 <- r1
    wincr
    goto .loop
