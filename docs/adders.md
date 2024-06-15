# Sum of Buttons Pressed (Adder)

These come in two variations, but as the title suggests, each will count the number of buttons pressed and display the result with the LEDs.

## Binary

<center>
  <iframe
    src="https://circuitverse.org/simulator/embed/sum-of-buttons-pressed?theme=lite-born-spring&display_title=true&clock_time=true&fullscreen=true&zoom_in_out=true"
    style="border-width: 2; border-style: solid; border-color: black;"
    id="sm_buttons"
    height="600"
    width="700"
    allowFullScreen>
  </iframe>
</center>

The number of buttons pressed is displayed in binary of the LEDs. It may be useful to have tried the [binary counter](binary_counter.md)) demonstration first to ensure familiarity with how computers and electronics count.

## One Hot

As each additional button is pressed, the LED to the left is lit, and with each release the LED lit moves right. It should not be necessary to push the buttons in order, any order will do.

<center>
  <iframe
    src="https://circuitverse.org/simulator/embed/sum-of-buttons-pressed-one-hot?theme=lite-born-spring&display_title=true&clock_time=true&fullscreen=true&zoom_in_out=true"
    style="border-width: 2; border-style: solid; border-color: black;"
    id="sm_buttons"
    height="600"
    width="700"
    allowFullScreen>
  </iframe>
</center>

This introduced the concept of "[One Hot](https://en.wikipedia.org/wiki/One-hot)" encoding visually. Only one LED is lit at any one time. This can be a way of encoding state variables too, so that only one bit drives an action, making decoding cheaper at the expense of the number of registers in the state variable.

## Note

The interactive demos show an implementation with logic gates (other solutions may be available). But importantly they show how much work needs to be done to derive the desired implementation. [Karnaugh maps](https://en.wikipedia.org/wiki/Karnaugh_map) and [Boolean equations](https://en.wikipedia.org/wiki/Boolean_algebra) were used in the derivation of the gates, and possibly in a non-optimal way too.

The whole point of a specification language like [VHDL](https://en.wikipedia.org/wiki/VHDL) (or [Verilog](https://en.wikipedia.org/wiki/Verilog)) is to alleviate the burden of this level of implementation and allow the developer to work at a higher level of abstraction (specification), knowing that a tool can produce the solution (implementation) on their behalf from a readable description of what is required.
