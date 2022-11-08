# RISC CPU

Reduced Instruction Set Computer Central Processing Unit

How about a 4-bit CPU? That gives the opportunity to define 16 instructions, and we can simplify the architecture so the code is stored in a ROM at compile time. You can choose how many registers you code and how the buttons and LEDs are read or driven.

Candidate instructions are:

* NOOP - No operation, does nothing and is more useful than you might think.
* `LOAD` a register with a literal (actual value)
* `ADD` two registers and place the answer in a register
* `SUB`tract
* `AND` - Vector based, i.e. "1001" AND "0011" = "0001"
* `OR` - Vector based
* `NOT` - Vector based
* `IF_EQ` - If equal
* `IF_GT` - If greater than
* `IF_GE` - If greater than or equal
* `IF_LT` - If less than. Note you don't need this if you have `LT_GT` as you can just swap the operands over.
* `IF_LE` - If less than or equal to. Note you don't need this if you have `LT_GT` as you can just swap the operands over.
* `GOTO` an instruction. This requires some care with program counter values that may get shifted by code changes. At this point you need to start using loop labels with an assembler.
* `WAIT` - Wait for a specified number of pulses on the `incr` input

You will need to design the instruction set that operates on 0, 1 or 2 operands. You will need to consider how to format the assembled instructions so that the logic to implement them is thought out and minimal, and where the result gets written. You could write the answer to a third specified register, or use one of the two operands registers and perform an update in place.

You will need to pack your instructions into words to be stored in memory. For example, you might choose to pack your instructions like the following. 4-bit registers, but the values packed into the instructions are not the contents of the registers but the references to the internal registers. So if you have 8 registers, you will need 3 bits to reference them, only 2 bits if you have 4 internal registers.

Here's an example of an assembled instruction for `ADD` taking two inputs and writing one output, e.g. A = B AND C.

|      | Instruction | Operand 1 | Operand 2 | Result |
|:----:|:-----------:|:---------:|:---------:|:------:|
| Bits |      4      |     3     |     3     |    3   |

If you change one of the operands in place, e.g. A = A AND B, you can reduce the word size.

|      | Instruction | Operand 1 | Operand 2 |
|:----:|:-----------:|:---------:|:---------:|
| Bits |      4      |     3     |     3     |

But you will need to be able to specify 4-bit literals in the `LOAD` opration. So you might need a different format for that particular case:

|      | Instruction | Literal   | Packing |
|:----:|:-----------:|:---------:|:-------:|
| Bits |      4      |     4     |   `0`s  |

Then a `GOTO` will require an operand for the jump to another programme counter. The program counter needs to have as many bits as there are address lines to the ROM.

Finally, all instructions must assemble to the same number of bits in a word, so there might be some unused bits that just need some value, e.g. `0`.
