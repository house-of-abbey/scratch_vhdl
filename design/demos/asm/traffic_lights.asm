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
  
