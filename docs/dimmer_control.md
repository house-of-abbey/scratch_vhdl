# Dimmer Control

Consider a room light dimmer control that can be incremented and decremented in brightness of the main light. This is a digital version of the classic analogue dimmer that you rotate.

![Dimmer Controller Sequence](./images/sim_controls/dimmer_control_demo.gif)

Choose two buttons for `up` and `down` functions to manually advance through states. This example has two immediately obvious implementations.

1. Use an integer counter in the range 0 to 4 and add or subtract 1 for each change. Make sure the actions on values of 0 and 4 are constrained.
2. Use a state machine like the following to explicitly enumerate each state.

<div class="mermaid">
stateDiagram-v2
    [*] --> 0
    0 --> 1 : up   = '1' and incr = '1'
    1 --> 0 : down = '1' and incr = '1'
    1 --> 2 : up   = '1' and incr = '1'
    2 --> 1 : down = '1' and incr = '1'
    2 --> 3 : up   = '1' and incr = '1'
    3 --> 2 : down = '1' and incr = '1'
    3 --> 4 : up   = '1' and incr = '1'
    4 --> 3 : down = '1' and incr = '1'
</div>

Now we just need to add the output assignments, e.g. using a `case` statement, to decode the state (integer) value to a 4-bit vector assignment to `leds(3:0)`.

| state | `leds(3:0)` |
|:-----:|:-----------:|
|   0   |   "0000"    |
|   1   |   "1000"    |
|   2   |   "1100"    |
|   3   |   "1110"    |
|   4   |   "1111"    |


## Non-Finite State Machine

An implementation using a two-way shift register. The FSM implementation is perhaps more descriptive and hence easier to understand.

<center>
  <iframe
    src="https://circuitverse.org/simulator/embed/dimmer?theme=lite-born-spring&display_title=true&clock_time=true&fullscreen=true&zoom_in_out=true"
    style="border-width: 2; border-style: solid; border-color: black;"
    id="logic_gates"
    height="500"
    width="700"
    allowFullScreen>
  </iframe>
</center>
