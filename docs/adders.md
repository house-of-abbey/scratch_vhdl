# Sum of Buttons Pressed (Adder)

These come in two variations, but as the title suggests, each will count the number of buttons pressed and display the result with the LEDs.

## One Hot

As each additional button is pressed, the LED to the left is lit, and with each release the LED lit moves right. It should not be necessary to push the buttons in order, any order will do.

This introduced the concept of "One Hot" visually. Only one LED is lit at any one time. This can be a way of encoding state variables too, so that only one bit drives an action, making decoding cheaper at the expense of the number of registers in the state variable.

## Binary

The number of buttons pressed is displayed in binary of the LEDs. It may be useful to have tried the [binary counter](binary_counter.md)) demonstration first to ensure familiarity with how computers and electronics count.
