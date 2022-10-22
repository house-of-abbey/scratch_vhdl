# Scratch VHDL

[![Built on Blockly](https://tinyurl.com/built-on-blockly)](https://github.com/google/blockly)

The purpose of "Scratch VHDL" is to make reprogrammable logic design into child's play. Sounds ambitious. We'll do this by providing an introductory package of measures to simplify all aspects of design entry from coding through to deployment on a *"Field Programmable Gate Array"* (reprogrammable silicon chip). We'll simplify the process into the following step:

1. Using a *Scratch* interface to enable drag and drop coding of VHDL.
2. Providing simple examples to code on a basic theme of 4 button and 4 LEDs, thereby...
3. Reducing the range of VHDL being used to a subset that can still be interesting and provide a learning experience.
4. Making testing interactive through a graphical control panel composed of buttons and LEDs to drive stimulus for the functional simulation instead of writing a VHDL test bench.
5. Using the native FPGA design tools in a guided point & click mode.
6. Encourage the understanding of the synthesis results by clicking through from gates to code.
7. Reducing the clock speed so that timing closure can be ignored.
8. Downloading the design to a development board in order to test for real, in a similar style to the interactive test bench used for simulation.

All of these measures allow the design entry process to be simplified to a practical guided lesson. The content of what can be done with four buttons and 4 LEDs can then be tailored from fundamental combinatorial gates through to basic sequences of states with more involved combinatorial logic demands. Anyone new to FPGA design will be able to experience the full design process to realise and test a real (if simple) design, and gain an education.

## Design Entry

Rather than hiding the code from the students, the Scratch project builder engages its audience with its creation, allowing them to experience a modern design entry method. Scratch will reduce the chances of syntax errors (but not completely eliminate them), and a standard project setup can be used to avoid many of the time consuming distractions. For example, we use a standard VHDL `entity` for all the demonstration designs, and the Scratch builder only has to assist with the derivation of the VHDL `architecture` in a single file.