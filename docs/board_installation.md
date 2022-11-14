# Development Board Installation

See [Digilent Board Files for Zybo Z7](https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis) for the instructions to install the development board. These instructions cover

* Downloading the configuration files,
* Unzipping them and,
* Copying the correct subset of files to the correct location in your Vivado installation.

Any problems, refer to these instructions for setting any additional paths as there is more than one way to install the files. If there are any residual problems with the board files not being read from the correct location, try the following:

```tcl
# https://support.xilinx.com/s/question/0D52E00007Cj2ZHSAZ/how-to-properly-source-control-vivado-project?language=en_US
#
# Set the correct location for the Vivado board store
#
set_param board.repoPaths [get_property LOCAL_ROOT_DIR [xhub::get_xstores xilinx_board_store]]

# Also detailed at the following:
#
# https://github.com/Xilinx/XilinxBoardStore/wiki/Accessing-the-Board-Store-Repository
#
xhub::refresh_catalog [xhub::get_xstores xilinx_board_store]
```

References:
  * [How to properly source control Vivado project](https://support.xilinx.com/s/question/0D52E00007Cj2ZHSAZ/how-to-properly-source-control-vivado-project?language=en_US)
  * [Accessing the Board Store Repository](https://github.com/Xilinx/XilinxBoardStore/wiki/Accessing-the-Board-Store-Repository)
