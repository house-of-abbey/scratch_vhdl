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
#ruledef                          ;       VHDL references
{                                 ;   op @ dest @ src1 @ src2
  noop                            => 0x0 @         0`9        ; noop
  {o:sreg} <- {v:u4}              => 0x1 @  o`3 @  0`2 @  v`4 ; op_set
  {o:sreg} <- {a:reg}             => 0x2 @  o`3 @  a`3 @  0`3 ; op_copy
  {o:sreg} <- {a:reg} and {b:reg} => 0x3 @  o`3 @  a`3 @  b`3 ; op_and
  {o:sreg} <- {a:reg} or  {b:reg} => 0x4 @  o`3 @  a`3 @  b`3 ; op_or
  {o:sreg} <- not {a:reg}         => 0x5 @  o`3 @  a`3 @  0`3 ; op_not
  {o:sreg} <- {a:reg}  +  {b:reg} => 0x6 @  o`3 @  a`3 @  b`3 ; op_add
  {o:sreg} <- {a:reg}  -  {b:reg} => 0x7 @  o`3 @  a`3 @  b`3 ; op_sub
  if {a:reg} eq {b:reg}           => 0xa @  0`3 @  a`3 @  b`3 ; op_ifeq
  if {a:reg} gt {b:reg}           => 0xb @  0`3 @  a`3 @  b`3 ; op_ifgt
  if {a:reg} ge {b:reg}           => 0xc @  0`3 @  a`3 @  b`3 ; op_ifge
  wincr {l:u9}                    => 0xd @         l`9        ; op_wi
  goto  {l:u9}                    => 0xe @         l`9        ; op_goto
  jump  {l:s9}                    => 0xf @         l`9        ; op_jump
}

; These can be used for LEDs or buttons
           ; bit
bit0 = 0x1 ; 0
bit1 = 0x2 ; 1
bit2 = 0x4 ; 2
bit3 = 0x8 ; 3

r0 <- 3
r1 <- 0b0000

loop:
  leds <- r0 + btns
  wincr 3
  leds <- btns and r1
  wincr 1
  goto loop
