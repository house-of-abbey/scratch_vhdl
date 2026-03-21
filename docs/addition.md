# Binary Addition

Two pairs of buttons are used as 2-bit inputs. So `btns(3:2)` and  `btns(1:0)` form two inputs with the integer range 0 to 3. They are then added together to create a 3-bit output displayed as `leds(2:0)`. The logic is crafted to produce the following table of results.

## Integer:

| `btns(3:2)` | `btns(1:0)` | `leds(2:0)` |
|:-----------:|:-----------:|:-----------:|
|      0      |      0      |      0      |
|      0      |      1      |      1      |
|      0      |      2      |      2      |
|      0      |      3      |      3      |
|      1      |      0      |      1      |
|      1      |      1      |      2      |
|      1      |      2      |      3      |
|      1      |      3      |      4      |
|      2      |      0      |      2      |
|      2      |      1      |      3      |
|      2      |      2      |      4      |
|      2      |      3      |      5      |
|      3      |      0      |      3      |
|      3      |      1      |      4      |
|      3      |      2      |      5      |
|      3      |      3      |      6      |

## Binary:

| `btns(3:2)` | `btns(1:0)` | `leds(2:0)` |
|:-----------:|:-----------:|:-----------:|
|     "00"    |     "00"    |    "000"    |
|     "00"    |     "01"    |    "001"    |
|     "00"    |     "10"    |    "010"    |
|     "00"    |     "11"    |    "011"    |
|     "01"    |     "00"    |    "001"    |
|     "01"    |     "01"    |    "010"    |
|     "01"    |     "10"    |    "011"    |
|     "01"    |     "11"    |    "100"    |
|     "10"    |     "00"    |    "010"    |
|     "10"    |     "01"    |    "011"    |
|     "10"    |     "10"    |    "100"    |
|     "10"    |     "11"    |    "101"    |
|     "11"    |     "00"    |    "011"    |
|     "11"    |     "01"    |    "100"    |
|     "11"    |     "10"    |    "101"    |
|     "11"    |     "11"    |    "110"    |

## Equations

$\\
\mathtt{led}(0) = \mathtt{btns}(2) \oplus \mathtt{btns}(0)
\\
\mathtt{led}(1) = (\mathtt{btns}(2) . \mathtt{btns}(0)) \oplus \mathtt{btns}(3) \oplus \mathtt{btns}(1)
\\
\mathtt{led}(2) = (\mathtt{btns}(3) . \mathtt{btns}(1)) + (\mathtt{btns}(3) \oplus \mathtt{btns}(1)) . \mathtt{btns}(2) . \mathtt{btns}(0)
$

## Circuit

<center>
  <iframe
    src="https://circuitverse.org/simulator/embed/binary-addition-d4e7867a-edd6-4df2-88b7-8c4f344ebf9f?theme=&display_title=false&clock_time=true&fullscreen=true&zoom_in_out=true"
    style="border-width: 2; border-style: solid; border-color: black;"
    id="binary_addition"
    height="600"
    width="700"
    allowFullScreen>
  </iframe>
</center>
