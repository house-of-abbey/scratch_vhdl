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

#once
#bits 13

; Define a register
#subruledef reg
{
  btns    => 6`3 ; equivalent to r6
  leds    => 7`3 ; equivalent to r7
  r{r:u3} => r`3
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

#subruledef condition               ;      VHDL references
{                                   ;  op @ dest @ src1 @ src2
  {a:reg}[{b:u2}]                  => 0xa @  0`3 @  a`3 @  0`1 @ b`2 ; op_ifbit
  {a:reg} eq {b:reg}               => 0xb @  0`3 @  a`3 @  b`3       ; op_ifeq
  {a:reg} gt {b:reg}               => 0xc @  0`3 @  a`3 @  b`3       ; op_ifgt
  {a:reg} ge {b:reg}               => 0xd @  0`3 @  a`3 @  b`3       ; op_ifge

  {a:reg} lt {b:reg}               => asm { {b} ge {a} }
  {a:reg} le {b:reg}               => asm { {b} gt {a} }
}

; In general: o = fn(a, b)
;
#ruledef                            ;      VHDL references
{                                   ;  op @ dest @ src1 @ src2
  noop                             => 0x0 @         0`9              ; noop
  {o:sreg} <- {v:u4}               => 0x1 @  o`3 @  0`2 @  v`4       ; op_set
  {o:sreg} <- {a:reg}              => 0x2 @  o`3 @  a`3 @  0`3       ; op_copy
  {o:sreg} <- {a:reg} and {b:reg}  => 0x3 @  o`3 @  a`3 @  b`3       ; op_and
  {o:sreg} <- {a:reg} or  {b:reg}  => 0x4 @  o`3 @  a`3 @  b`3       ; op_or
  {o:sreg} <- not {a:reg}          => 0x5 @  o`3 @  a`3 @  0`3       ; op_not
  {o:sreg} <- {a:reg}  +  {b:reg}  => 0x6 @  o`3 @  a`3 @  b`3       ; op_add
  {o:sreg} <- {a:reg}  -  {b:reg}  => 0x7 @  o`3 @  a`3 @  b`3       ; op_sub
  {o:sreg} <- {b:u1}   >  {a:reg}  => 0x8 @  o`3 @  a`3 @  0`2 @ b`1 ; op_shft
  {o:sreg} <- {a:reg}  <  {b:u1}   => 0x8 @  o`3 @  a`3 @  1`2 @ b`1 ; op_shft
  {o:sreg} <- rnd                  => 0x9 @  o`3 @         0`6       ; op_rnd

  {o:sreg} <- {a:reg} nand {b:reg}  => asm {
    {o} <- {a} and {b}
    {o} <- not {o}
  }
  {o:sreg} <- {a:reg} nor {b:reg}  => asm {
    {o} <- {a} or {b}
    {o} <- not {o}
  }
  
  if {c:condition}                 => c`13
  wait until {c:condition} => asm {
    if {c}
      noop
      goto $ - 2
  }
  wait while {c:condition} => asm {
    if {c}
      goto $ - 1
      noop
  }

  wincr                            => 0xe @         1`9              ; op_wi
  wincr {l:u9}                     => 0xe @         l`9              ; op_wi
  wait incr        => asm { wincr }     ; Included as an alias to provide a
  wait incr {l:u9} => asm { wincr {l} } ; more readable and consistent option.

  goto  {l:u9}                     => 0xf @         l`9              ; op_goto

  halt    => asm { goto $ }
  restart => asm { goto 0 }
  clear   => asm {
    r0   <- 0
    r1   <- 0
    r2   <- 0
    r3   <- 0
    r4   <- 0
    r5   <- 0
    btns <- 0
    leds <- 0
  }
}
