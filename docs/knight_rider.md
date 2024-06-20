# Knight Rider

The **[Knight Rider](https://www.youtube.com/watch?v=oNyXYPhnUIs&ab_channel=NBCClassics) KITT car** bonnet light sequence from the 1980's television series. Otherwise known as a [Larson Scanner](https://shop.evilmadscientist.com/productsmenu/tinykitlist/152-scanner)!

Create a simple light sequence of a single LED lit moving from right to left to right and so on. Also with `start` and `stop`.

![KITT Car's Light Sequence](./images/sim_controls/knight_rider_demo.gif)

This introduces the idea of mapping a state variable to bespoke outputs. The state variable can be kept simple by using a constrained integer, and rolling over at the correct value.

Do click the YouTube video link to remind yourself of the TV series' theme tune.

## Implementation

This requires a very simple [finite state machine](https://en.wikipedia.org/wiki/Finite-state_machine). Hopefully you have identified from the animation that it requires 6 states, passing through each in a linear sequence, even if the lights go back and forth. That is correct, four states will not be sufficient, and you need two states to decode to light `leds(1)` and two states to decode to light `leds(2)`, one of the pair for forwards and the other for backwards.

Typically state machines written in VHDL use a custom type that enumerates the states by a recognisable name, e.g. "IDLE", "RUNNING", "READ" etc. Here we'll keep the VHDL simple by using an integer to number the states. This also helps debugging as the state moves through its linear sequence from 0 to 5. Then each state needs decoding to light one of `leds(3:0)`.

## Finite State Machines (FSM)

Typically, in the general case, an FSM has both inputs and outputs as well as the state variable. The inputs are decoded to transition between states, and the outputs are a function of either the state or both the state and the inputs. For this implementation our state transitions look like the following diagram.

<div class="mermaid">
stateDiagram-v2
    [*] --> 0
    0 --> 1 : running = '1' and incr = '1'
    1 --> 2 : running = '1' and incr = '1'
    2 --> 3 : running = '1' and incr = '1'
    3 --> 4 : running = '1' and incr = '1'
    4 --> 5 : running = '1' and incr = '1'
    5 --> 0 : running = '1' and incr = '1'
</div>

As before `start` and `stop` toggle `running`. Now we just need to add the output assignments, e.g. using a `case` statement. Next make the output assignments run through the sequence of LEDs, decoding an integer value to a 4-bit vector assignment to `leds(3:0)`.

Output decoding based solely on the state variable's value.

| state | `leds(3:0)` |
|:-----:|:-----------:|
|   0   |   "0001"    |
|   1   |   "0010"    |
|   2   |   "0100"    |
|   3   |   "1000"    |
|   4   |   "0100"    |
|   5   |   "0010"    |

This suggests a simple implementation in logic as follows where the state variable is [one-hot encoded](https://en.wikipedia.org/wiki/One-hot) for trivial state decoding. **Press "reset" to initialise the light sequence.**

<center>
  <iframe
    src="https://circuitverse.org/simulator/embed/knight-rider-21ab8d72-a345-4138-bd17-3ff16545cc99?theme=lite-born-spring&display_title=true&clock_time=true&fullscreen=true&zoom_in_out=true"
    style="border-width: 2; border-style: solid; border-color: black;"
    id="logic_gates"
    height="500"
    width="700"
    allowFullScreen>
  </iframe>
</center>
