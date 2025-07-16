#include "./ruledef.asm"

loop:
  leds <- rnd
  wincr
  goto loop
