# RISC CPU

Reduced Instruction Set Computer Central Processing Unit

How about a 4-bit CPU? That gives the opportunity to define 16 instructions, and we can simplify the architecture so the code is stored in a ROM at compile time. You can choose how many registers you code and how the buttons and LEDs are read or driven respectively.

![CPU Architecture](images/circuit_diagrams/cpu_architecture.png)

For the sake of simplicity, we're proposing the use of a Read Only memory (ROM) over a Random Access Memory (RAM).

## Candidate Instructions

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

Here's an example of an assembled instruction for `ADD` taking two inputs and writing one output, e.g. `A` = `B` `AND` `C`.

|      | Instruction | Operand 1 | Operand 2 | Result |
|:----:|:-----------:|:---------:|:---------:|:------:|
| Bits |      4      |     3     |     3     |    3   |

If you change one of the operands in place, e.g. `A` = `A` `AND` `B`, you can reduce the word size.

|      | Instruction | Operand 1 | Operand 2 |
|:----:|:-----------:|:---------:|:---------:|
| Bits |      4      |     3     |     3     |

But you will need to be able to specify 4-bit literals in the `LOAD` operation. So you might need a different format for that particular case:

|      | Instruction | Literal   | Packing |
|:----:|:-----------:|:---------:|:-------:|
| Bits |      4      |     4     |   `0`s  |

Then a `GOTO` will require an operand for the jump to another programme counter. The program counter needs to have as many bits as there are address lines to the ROM.

Finally, all instructions must assemble to the same number of bits in a word, so there might be some unused bits that just need some value, e.g. `0`. This is because you are writing these resulting bit vectors into a sequence of addresses in a ROM, so the length of each vector must be the same number of bits.

## Assembler Definition

For this part of the project we suggest you use [customasm](https://github.com/JosephAbbey/customasm). The link here is to a fork of the original which has been extended for portability and re-use. The original repository provides the [documentation](https://github.com/hlorenzi/customasm/wiki/Getting-started). Here you will need to describe the mnemonics used for your assembly language and how the instructions and operands pack into the bit vectors to be stored in the ROM. 'customasm' provides a language or configuration method to describe how to parse the mnemonics and convert them to a sequence of bits (packing) for your custom microprocessor. It then provides a bundle of utilities that you might expect to be available when writing assembly language.

* Labels for `GOTO` instructions. The labels get converter to program counter values for the jump required in the address lines to the ROM
* Constants that enable you to define bit offsets, e.g. `btn1 = 0b0010`.
* Functions - but now we're getting more complicated than a 4-bit CPU can really make use of.

All of this can be made available either through

* A web-based editor, or
* A command line tool to compile a file of assembly code to instructions in a text file that can be read by a ROM initialisation routine in VHDL. Very useful for build scripts.

## Example CPU

This project comes with an example RISC processor if you would prefer to jump ahead to the programming in assembly step. Both the VHDL for the RISC CPU and the assembly of instructions is ready and available for experiments. Perhaps work your way through the existing examples for state machines but this time in assembly code. Again this can be simulated and then downloaded to the development board and executed to prove it works. Take a look in the [ASM examples](../design/demos.asm/) to get started.

In order to execute these files you will need to:

1. Compile the simulation to include the `risc_cpu` architecture of the `led4button4` component.
2. Supply the simulation with the path to the _compiled_ instructions, i.e. the contents to initialise the ROM with.
3. Amend the generic used by the top level of the design in Vivado. Then the synthesis will be able to include the instructions in the ROM when generating the BIT file.
4. Send the BIT file to the development board for execution.

These are the scripts that you need to use to manage this process:

| Action    | Script | Description |
|:----------|:-------|:------------|
| Simulation|        |             |
| Synthesis |        |             |

## And Finally

Just pause for a moment and think about what we have done here. All the demonstrations for creating firmware to drive the LEDs can be implemented in one general purpose processor. If the ROM was actually RAM, we would be able to re-programme the LED operations without the synthesis step. But more to the point, software (a collection of assembled instructions) is just one great big finite state machine. It is still 'finite' because the storage space for code in the memory (ROM) is limited. In this case the limit is 2<sup>9</sup> = 512 states. But the states might not be used as efficiently if multiple instructions are required to achieve what one state in a pure firmware implementation can achieve.

There's a trade here between generality of purpose and optimal calculation. This is a trade that is conventionally driven by economics, the (additional) cost of writing an optimal design in firmware versus the re-usability and flexibility of a single solution that does many things that does not achieve quite the same performance. If you want the highest performance then you'll need to turn to Application Specific Integrated Circuits (ASIC), where the logic is hard coded and sometimes carved and chiselled to perfection. Taking away the reprogrammability of FPGAs leads to greater clock speeds and yet higher performance.

| Feature     | ASIC | FPGA | Software |
|:------------|:----:|:----:|:--------:|
| Flexibility | Low  |  -   | High     |
| Performance | High |  -   | Low      |
| £ Price     | High |  -   | Low      |

FPGAs sit in the middle, with the elements of the reprogrammability of software and the performance of application specific devices. The remaining amusing anecdote is that both microprocessors and FPGAs are themselves ASICs.
