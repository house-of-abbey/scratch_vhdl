# Pulse Generator

Create a short pulse from a longer one. Here each LED is only briefly lit however long the button is pressed. This is a basic and standard technique in digital design.

![Digital Circuit for pulse generators](./images/circuit_diagrams/pulse_gen_circuit.png)

This basic principle is shown above. The output goes high when the input does, except if the register's output is high. This occurs one clock cycle after the input goes high, hence the output being high only lasts for one clock cycle. i.e. We have a pulse generated off the leading edge of `button`. The sequence of states in condensed time is shown in the following truth table.

| buttons | Q   | pulse |
|:-------:|:---:|:-----:|
| 0       | 0   | 0     |
| 1       | 0   | 1     |
| 1       | 1   | 0     |
| 0       | 1   | 0     |
| 0       | 0   | 0     |

From this we can determine that:

`pulse` = `buttons` AND NOT `Q`

<center>
  <iframe
    src="https://circuitverse.org/simulator/embed/lead-edge-pulse-generator?theme=lite-born-spring&display_title=true&clock_time=true&fullscreen=true&zoom_in_out=true"
    style="border-width: 2; border-style: solid; border-color: black;"
    id="sm_buttons"
    height="400"
    width="600"
    allowFullScreen>
  </iframe>
</center>

This principle can be extended to several clock cycles by including a condition on a heart beat pulse like `incr`.

![Wave window for pulse generators](./images/modelsim_wave/pulse_gen_wave.png)

Each pulse on `leds(3:0)` shown here is the length of the gap between adjacent pulses on `incr`, just long enough to make an LED flash.
