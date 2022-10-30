# Project Creation

We aim to cope with different versions of Vivado (2019.1, 2021.1 etc) by creating a fresh project each time. We also need to create a piece of 'IP' (Intellectual Property) which means selecting the required IP from the catalogue and generating some products required for both simulation and synthesis. It matters little what this is, but for the curious its a Phase Locked Loop (PPL) primitive generated from the "Clock Wizard" so that we can manage the external clock on the clock pin correctly.

Execute the batch file [vivado_project.cmd](../design/vivado_project.cmd"), which will:

1. fire up Vivado,
2. create a project,
3. create the required IP,
4. generate the simulation model for the IP,
5. make ready for the first synthesis.

This instance of Vivado can be closed and re-opened using the [run_vivado.bat](./design/run_vivado.bat) batch file.
