# Push Buttons

Very much the "Hello World!" application to make sure the end-to-end design flow works from code entry to testing the design on a development board.

Each toggle button lights a corresponding LED. That's it. This design introduces the Scratch VHDL method of design entry using an assignment in a clocked process. This means that each button is registered before driving an LED. This works with both push and toggle buttons in the controller.

An extension is to maintain the last selected push button after it is released. This amendment is more suitable to the push buttons as it means it is no longer possible to turn off all the LEDs with toggle buttons.
