#bits 16
#ruledef
{
    r{r} <-  {v}        => 0x1 @ r`4 @ v`4 @ 0`4
    r{f} <- r{t}        => 0x2 @ f`4 @ t`4 @ 0`4
    r{r} <- in          => 0x3 @ r`4 @ 0`8
    out  <- r{r}        => 0x4 @ r`4 @ 0`8
    r{a} <- r{b} & r{o} => 0x5 @ a`4 @ b`4 @ o`4
    r{a} <- r{b} | r{o} => 0x6 @ a`4 @ b`4 @ o`4
    r{a} <- r{b} + r{o} => 0x7 @ a`4 @ b`4 @ o`4
    r{a} <- r{b} - r{o} => 0x8 @ a`4 @ b`4 @ o`4
    goto {a}            => 0xe @ a`12
    move {a}            => 0xf @ a`12
}

threePlusI:
    r0 <- 3
    
    .loop:
        r1  <- in
        r2  <- r0 + r1
        out <- r2
        goto .loop

