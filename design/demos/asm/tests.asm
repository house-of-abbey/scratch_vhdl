; https://github.com/hlorenzi/customasm/wiki/Getting-started

#bits 13

; Define a register
#subruledef reg
{
  r{r:u3} => r`3
  btns    => 6`3
  leds    => 7`3
}

; Safely assign the output register, make sure it is not r6, which is
; read-only for the buttons inputs.
#subruledef sreg
{
  {o:reg} => {
    assert(o != 6)
    o`3
  }
}

; In general: o = fn(a, b)
;
#ruledef                           ;       VHDL references
{                                  ;   op @ dest @ src1 @ src2
  noop                            => 0x0 @         0`9              ; noop
  {o:sreg} <- {v:u4}              => 0x1 @  o`3 @  0`2 @  v`4       ; op_set
  {o:sreg} <- {a:reg}             => 0x2 @  o`3 @  a`3 @  0`3       ; op_copy
  {o:sreg} <- {a:reg} and {b:reg} => 0x3 @  o`3 @  a`3 @  b`3       ; op_and
  {o:sreg} <- {a:reg} or  {b:reg} => 0x4 @  o`3 @  a`3 @  b`3       ; op_or
  {o:sreg} <- not {a:reg}         => 0x5 @  o`3 @  a`3 @  0`3       ; op_not
  {o:sreg} <- {a:reg}  +  {b:reg} => 0x6 @  o`3 @  a`3 @  b`3       ; op_add
  {o:sreg} <- {a:reg}  -  {b:reg} => 0x7 @  o`3 @  a`3 @  b`3       ; op_sub
  {o:sreg} <- {b:u1} > {a:reg}    => 0x8 @  o`3 @  a`3 @  0`2 @  b`1 ; op_shft
  {o:sreg} <- {a:reg} < {b:u1}    => 0x8 @  o`3 @  a`3 @  1`2 @  b`1 ; op_shft

  if {a:reg} eq {b:reg}           => 0xb @  0`3 @  a`3 @  b`3       ; op_ifeq
  if {a:reg} gt {b:reg}           => 0xc @  0`3 @  a`3 @  b`3       ; op_ifgt
  if {a:reg} ge {b:reg}           => 0xd @  0`3 @  a`3 @  b`3       ; op_ifge
  wincr {l:u9}                    => 0xe @         l`9              ; op_wi
  wincr                           => 0xe @         1`9              ; op_wi
  goto  {l:u9}                    => 0xf @         l`9              ; op_goto
}

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
;

end:
  leds <- 0b1110
  goto $

fail:
  leds <- 0b0111
  goto $
