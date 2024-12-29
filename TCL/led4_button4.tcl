#####################################################################################
#
#  Distributed under MIT Licence
#    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
#
#####################################################################################
#
# TCL script to display a simple interactive GUI for providing stimulus for RTL code
# based on design requiring only 4 buttons and 4 LEDs.
#
# To run this code, keep your compiled design open in Modelsim and run:
#
#   source {path\to\led4_button4.tcl}
#
# Reference:
#   https://blog.abbey1.org.uk/index.php/technology/tcl-tk-graphical-display-driven-by-a-vhdl
#   https://www.tutorialspoint.com/tcl-tk/
#   https://www.microsemi.com/document-portal/doc_view/136364-modelsim-me-10-4c-command-reference-manual-for-libero-soc-v11-7
#
# J D Abbey & P A Abbey, 14 October 2022
#
#####################################################################################

onerror {resume}

# Global variables
set off      #333
set width      30
set ledgap      8
set butgap      4
set fontsize   16
# Newer PC are too fast, slow them down
# Delay time in ms
set autostep_delay 100

# Don't amend these
set thisscript  [file normalize [info script]]
set thisdir     [file dirname $thisscript]
set winwidth    594; # [expr 60 + 40*$fontsize]
set winheight   280; # [expr 180 +  2*$fontsize]
set btnfontsize [expr $fontsize/2]
# Needs to be less than an "increment" ('incr' pulses 1 in 10 clock cycles in simulation, i.e. here, but 0.5s on the real FPGA)
set pushbtntime "50 ns"
# Signals
set clock   {/test_led4_button4/clk}
set incr    {/test_led4_button4/incr}
set leds    {/test_led4_button4/leds}
set buttons {/test_led4_button4/buttons}

# Allow the environment to define a variable with a path to a logo file to be placed in the GUI for branding.
if { [catch {[info exists $::env(SV_LOGO) ]}] } {
  set logo default
} else {
  if {[file exists $::env(SV_LOGO)]} {
    set logo $::env(SV_LOGO)
  } else {
    echo "WARNING - Logo file '$::env(SV_LOGO)' does not exist."
    set logo default
  }
}

proc LED {can {conf plain} {w 10} {value 0} {n 0} {col #f00} {ox 0} {oy 0}} {
  global off
  switch $conf {
    plain {
      if {$value == 1} {
        $can create rect \
          $ox $oy [expr $ox + $w] [expr $oy + $w] \
          -outline $col -fill $col
      }  {
        $can create rect \
          $ox $oy [expr $ox + $w] [expr $oy + $w] \
          -outline $off -fill $off
      }
      $can create text \
        [expr $ox + $w/2] [expr $oy + $w/2] \
        -fill #000 -text $n \
        -anchor c -font "Helvetica [expr $w*8/10] bold"
    }

    traffic {
      if {$value == 1} {
        $can create oval \
          $ox $oy [expr $ox + $w] [expr $oy + $w] \
          -outline $col -fill $col
      }  {
        $can create oval \
          $ox $oy [expr $ox + $w] [expr $oy + $w] \
          -outline $off -fill $off
      }
      $can create text \
        [expr $ox + $w/2] [expr $oy + $w/2] \
        -fill #000 -text $n \
        -anchor c -font "Helvetica [expr $w*8/10] bold"
    }

    filter {
      if {$value == 1} {
        $can create polygon \
                $ox         [expr $oy +   $w/2] \
          [expr $ox + $w/2]       $oy           \
          [expr $ox + $w/2] [expr $oy +   $w/3] \
          [expr $ox + $w  ] [expr $oy +   $w/3] \
          [expr $ox + $w  ] [expr $oy + 2*$w/3] \
          [expr $ox + $w/2] [expr $oy + 2*$w/3] \
          [expr $ox + $w/2] [expr $oy +   $w  ] \
          -outline $col -fill $col
      }  {
        $can create polygon \
                $ox         [expr $oy +   $w/2] \
          [expr $ox + $w/2]       $oy           \
          [expr $ox + $w/2] [expr $oy +   $w/3] \
          [expr $ox + $w  ] [expr $oy +   $w/3] \
          [expr $ox + $w  ] [expr $oy + 2*$w/3] \
          [expr $ox + $w/2] [expr $oy + 2*$w/3] \
          [expr $ox + $w/2] [expr $oy +   $w  ] \
          -outline $off -fill $off
      }
    }
  }
}

proc display {can {conf plain} {l0 0} {l1 0} {l2 0} {l3 0}} {
  global width ledgap fontsize on off butgap

  destroy $can

  switch $conf {
    plain {
      set canwidth    [expr $ledgap + 4*($width + $ledgap)]
      set canheight   [expr $ledgap*2 + $width]

      canvas $can -width $canwidth -height $canheight -background #000

      LED $can plain $width $l3 3 #f00       $ledgap                           $ledgap
      LED $can plain $width $l2 2 #f00 [expr $ledgap +      $width + $ledgap ] $ledgap
      LED $can plain $width $l1 1 #f00 [expr $ledgap + 2 * ($width + $ledgap)] $ledgap
      LED $can plain $width $l0 0 #f00 [expr $ledgap + 3 * ($width + $ledgap)] $ledgap

      pack $can -side bottom -pady $butgap -padx $butgap
    }

    traffic {
      set canheight   [expr $ledgap + 3*($width + $ledgap)]
      set canwidth    [expr $ledgap + 2*($width + $ledgap)]

      canvas $can -width $canwidth -height $canheight -background #000

      LED $can traffic $width $l0 0 #f00 [expr $width + $ledgap*2]       $ledgap
      LED $can traffic $width $l1 1 #ff0 [expr $width + $ledgap*2] [expr $ledgap +      $width + $ledgap ]
      LED $can traffic $width $l2 2 #0f0 [expr $width + $ledgap*2] [expr $ledgap + 2 * ($width + $ledgap)]
      LED $can filter  $width $l3 3 #0f0                $ledgap    [expr $ledgap + 2 * ($width + $ledgap)]

      pack $can -side bottom -padx $butgap -pady $butgap
    }
  }
}

# Setup the triggers to update the displayed controls
proc setup_monitor {} {
  global incr leds default toggle traffic togglebutton
  catch {nowhen updateDisplay}
  when -label updateDisplay "${incr} == '1'" {
    # Don't let the sim run away, we won't see the display update
    stop
    set leds_v [examine -radix bin $leds]
    display ${default}.ledframe.leds plain \
      [string index $leds_v 3] \
      [string index $leds_v 2] \
      [string index $leds_v 1] \
      [string index $leds_v 0]
    display ${toggle}.ledframe.leds plain \
      [string index $leds_v 3] \
      [string index $leds_v 2] \
      [string index $leds_v 1] \
      [string index $leds_v 0]
    display ${traffic}.ledframe.leds traffic \
      [string index $leds_v 3] \
      [string index $leds_v 2] \
      [string index $leds_v 1] \
      [string index $leds_v 0]
  }
  ${default}.buttons.button_0 configure -state normal
  ${default}.buttons.button_1 configure -state normal
  ${default}.buttons.button_2 configure -state normal
  ${default}.buttons.button_3 configure -state normal
  ${toggle}.buttons.button_0  configure -state normal
  ${toggle}.buttons.button_1  configure -state normal
  ${toggle}.buttons.button_2  configure -state normal
  ${toggle}.buttons.button_3  configure -state normal
  ${traffic}.buttons.button_0 configure -state normal
  ${traffic}.buttons.button_1 configure -state normal
  ${traffic}.buttons.button_2 configure -state normal
  ${traffic}.buttons.button_3 configure -state normal
  .controls.body.sim.step     configure -state normal
  .controls.body.sim.autostep configure -state normal
  # Reset if we're reloading
  array set togglebutton {
    0 0
    1 0
    2 0
    3 0
  }
}

# Disconnect the triggers from the displayed controls.
proc stop_monitor {} {
  global default toggle traffic
  catch {nowhen updateDisplay}
  ${default}.buttons.button_0 configure -state disabled
  ${default}.buttons.button_1 configure -state disabled
  ${default}.buttons.button_2 configure -state disabled
  ${default}.buttons.button_3 configure -state disabled
  ${toggle}.buttons.button_0  configure -state disabled
  ${toggle}.buttons.button_1  configure -state disabled
  ${toggle}.buttons.button_2  configure -state disabled
  ${toggle}.buttons.button_3  configure -state disabled
  ${traffic}.buttons.button_0 configure -state disabled
  ${traffic}.buttons.button_1 configure -state disabled
  ${traffic}.buttons.button_2 configure -state disabled
  ${traffic}.buttons.button_3 configure -state disabled
  .controls.body.sim.step     configure -state disabled
  .controls.body.sim.autostep configure -state disabled
}

proc display_cursor {} {
  global leds default toggle traffic
  set leds_v [examine -time [wave cursor time] -radix bin $leds]
  display ${default}.ledframe.leds plain \
    [string index $leds_v 3] \
    [string index $leds_v 2] \
    [string index $leds_v 1] \
    [string index $leds_v 0]
  display ${toggle}.ledframe.leds plain \
    [string index $leds_v 3] \
    [string index $leds_v 2] \
    [string index $leds_v 1] \
    [string index $leds_v 0]
  display ${traffic}.ledframe.leds traffic \
    [string index $leds_v 3] \
    [string index $leds_v 2] \
    [string index $leds_v 1] \
    [string index $leds_v 0]
}

proc step_cmd {} {
  global now
  .controls.body.sim.step configure -state disabled
  run -all
  wave seetime $now
  .controls.body.sim.step configure -state normal
}

# Reopen the simulation with the newly selected assembled instructions file
#  Parameters:
#   1. The file name (/path/file.o)
#   2. A switch as follows:
#      0 to load the 'test_interactive' configuration which uses the 'scratch' architecture for a user
#        generated CPU.
#      1 to load the 'test_cpu_interactive' configuration which uses the 'risc_cpu' architecture for
#        the non-Scratch example CPU for ease of debugging.
#
# Usage: change_asm {F:\Compile\ModelSim\projects\button_leds\instr_files\knight_rider_start_stop.o} 1
#
proc change_asm {{f} {conf 0}} {
  global thisscript
  quit -sim
  if {$conf == 0} {
    vsim -Grom_file_g=$f work.test_interactive
  } else {
    vsim -Grom_file_g=$f work.test_cpu_interactive
  }
  transcribe source "$thisscript"
}

# Select the assembled instructions file to execute in simulation.
proc change_asm_file_select {} {
  set file [tk_getOpenFile -initialdir {./instr_files} -filetypes {{bin {.o}}}]
  if {$file != ""} {
    change_asm $file
  }
}

set autostep 0
proc autostep_check {} {
  global autostep now autostep_delay
  .controls.body.sim.step configure -state disabled
  .controls.body.sim.atcursor configure -state disabled
  while {$autostep} {
    run -all
    wave seetime $now
    # Newer PC are too fast, slow them down
    after $autostep_delay
  }
  .controls.body.sim.step configure -state normal
  .controls.body.sim.atcursor configure -state normal
}

proc button_cmd {b {t "20 ns"}} {
  global buttons togglebutton
  force -deposit "${buttons}\[$b\]" 1 0, 0 $t
  set togglebutton($b) 0
}

proc checkbutton_cmd {b} {
  global buttons togglebutton
  force -deposit "${buttons}\[$b\]" $togglebutton($b) 0
}

# Switch to the desired GUI button tab for use.
#
proc get_button_tab {} {
  global app
  set bt 0
  catch {set bt [examine sim:/test_led4_button4/led4_button4_i/button_tab_c]}
  # 0 - No request
  # 1 - Push Switch tab
  # 2 - Toggle Switch tab
  # 3 - Traffic Lights tab
  switch $bt {
    1 {$app raise default}
    2 {$app raise toggle}
    3 {$app raise traffic}
  }
  return $bt
}

# Clean up from last time
destroy .controls
toplevel .controls

catch {image delete logo}
if {$logo != "default"} {
  label .controls.logo -image [image create photo logo -file "${logo}"]
} else {
  label .controls.logo -image [image create photo logo -width 200 -file "${thisdir}/icon_200w.png"]
}
pack .controls.logo -side left -fill x -expand 0 -padx 20 -pady 20

frame .controls.body
pack .controls.body -side right -fill x -expand 1

# Simulation Controls
frame .controls.body.sim       -border 2 -relief groove
pack  .controls.body.sim       -side top -pady 10
label .controls.body.sim.label -text "Sim Controls"
pack  .controls.body.sim.label -side top

button .controls.body.sim.reload \
  -text "Reload" \
  -font "Helvetica $btnfontsize bold" \
  -command {source $thisscript}
pack .controls.body.sim.reload -side left -pady $butgap -padx $butgap

button .controls.body.sim.asm \
  -text "Change ASM" \
  -font "Helvetica $btnfontsize bold" \
  -command {change_asm_file_select}
pack .controls.body.sim.asm -side left -pady $butgap -padx $butgap

button .controls.body.sim.step \
  -text "Step" \
  -font "Helvetica $btnfontsize bold" \
  -command {step_cmd}
pack .controls.body.sim.step -side left -pady $butgap -padx $butgap

checkbutton .controls.body.sim.autostep \
  -text "Autostep" \
  -font "Helvetica $btnfontsize bold" \
  -command {autostep_check} \
  -variable autostep \
  -onvalue  1 \
  -offvalue 0
pack .controls.body.sim.autostep -side left -pady $butgap -padx $butgap

button .controls.body.sim.atcursor \
  -text "At Cursor" \
  -font "Helvetica $btnfontsize bold" \
  -command {display_cursor}
pack .controls.body.sim.atcursor -side left -pady $butgap -padx $butgap

# Application Controls

# Keys
bind .controls <KeyPress-0> {button_cmd 0 $pushbtntime}
bind .controls <KeyPress-1> {button_cmd 1 $pushbtntime}
bind .controls <KeyPress-2> {button_cmd 2 $pushbtntime}
bind .controls <KeyPress-3> {button_cmd 3 $pushbtntime}

set app [NoteBook .controls.body.app -side bottom]
set default [$app insert 0 default -text "Push Switch"]
set toggle  [$app insert 1 toggle  -text "Toggle Switch"]
set traffic [$app insert 2 traffic -text "Traffic Lights"]

# Push switches (release immediately)
frame ${default}.ledframe       -border 2 -relief raised
pack  ${default}.ledframe       -side top -pady 0
label ${default}.ledframe.label -text "LEDs"
pack  ${default}.ledframe.label -side top

frame ${default}.buttons       -border 2 -relief ridge
pack  ${default}.buttons       -side bottom
label ${default}.buttons.label -text "Buttons"
pack  ${default}.buttons.label -side top

button ${default}.buttons.button_3 \
  -text " 3 " \
  -font "Helvetica $btnfontsize bold" \
  -command {button_cmd 3 $pushbtntime}
pack ${default}.buttons.button_3 -side left -pady $butgap -padx $butgap

button ${default}.buttons.button_2 \
  -text " 2 " \
  -font "Helvetica $btnfontsize bold" \
  -command {button_cmd 2 $pushbtntime}
pack ${default}.buttons.button_2 -side left -pady $butgap -padx $butgap

button ${default}.buttons.button_1 \
  -text "1 (stop)" \
  -font "Helvetica $btnfontsize bold" \
  -command {button_cmd 1 $pushbtntime}
pack ${default}.buttons.button_1 -side left -pady $butgap -padx $butgap

button ${default}.buttons.button_0 \
  -text "0 (start)" \
  -font "Helvetica $btnfontsize bold" \
  -command {button_cmd 0 $pushbtntime}
pack ${default}.buttons.button_0 -side left -pady $butgap -padx $butgap

display ${default}.ledframe.leds plain


# Toggle buttons (actually checkboxes)
frame ${toggle}.ledframe       -border 2 -relief raised
pack  ${toggle}.ledframe       -side top -padx 0
label ${toggle}.ledframe.label -text "LEDs"
pack  ${toggle}.ledframe.label -side top

frame ${toggle}.buttons       -border 2 -relief ridge
pack  ${toggle}.buttons       -side bottom
label ${toggle}.buttons.label -text "Buttons"
pack  ${toggle}.buttons.label -side top

checkbutton ${toggle}.buttons.button_3 \
  -text " 3 " \
  -font "Helvetica $btnfontsize bold" \
  -indicatoron 0 \
  -command {checkbutton_cmd 3} \
  -variable togglebutton(3) \
  -onvalue  1 \
  -offvalue 0
pack ${toggle}.buttons.button_3 -side left -padx $butgap -pady $butgap

checkbutton ${toggle}.buttons.button_2 \
  -text " 2 " \
  -font "Helvetica $btnfontsize bold" \
  -indicatoron 0 \
  -command {checkbutton_cmd 2} \
  -variable togglebutton(2) \
  -onvalue  1 \
  -offvalue 0
pack ${toggle}.buttons.button_2 -side left -padx $butgap -pady $butgap

checkbutton ${toggle}.buttons.button_1 \
  -text " 1 " \
  -font "Helvetica $btnfontsize bold" \
  -indicatoron 0 \
  -command {checkbutton_cmd 1} \
  -variable togglebutton(1) \
  -onvalue  1 \
  -offvalue 0
pack ${toggle}.buttons.button_1 -side left -padx $butgap -pady $butgap

checkbutton ${toggle}.buttons.button_0 \
  -text " 0 " \
  -font "Helvetica $btnfontsize bold" \
  -indicatoron 0 \
  -command {checkbutton_cmd 0} \
  -variable togglebutton(0) \
  -onvalue  1 \
  -offvalue 0
pack ${toggle}.buttons.button_0 -side left -padx $butgap -pady $butgap

display ${toggle}.ledframe.leds plain

# Traffic Lights
frame ${traffic}.ledframe       -border 2 -relief raised
pack  ${traffic}.ledframe       -side left -padx 0
label ${traffic}.ledframe.label -text "LEDs"
pack  ${traffic}.ledframe.label -side top

frame ${traffic}.buttons       -border 2 -relief ridge
pack  ${traffic}.buttons       -side right
label ${traffic}.buttons.label -text "Buttons"
pack  ${traffic}.buttons.label -side top

button ${traffic}.buttons.button_0 \
  -text "0 (start)" \
  -font "Helvetica $btnfontsize bold" \
  -command {button_cmd 0 $pushbtntime}
pack ${traffic}.buttons.button_0 -side top -padx $butgap -pady $butgap

button ${traffic}.buttons.button_1 \
  -text "1 (stop)" \
  -font "Helvetica $btnfontsize bold" \
  -command {button_cmd 1 $pushbtntime}
pack ${traffic}.buttons.button_1 -side top -padx $butgap -pady $butgap

button ${traffic}.buttons.button_2 \
  -text " 2 " \
  -font "Helvetica $btnfontsize bold" \
  -command {button_cmd 2 $pushbtntime}
pack ${traffic}.buttons.button_2 -side top -padx $butgap -pady $butgap

button ${traffic}.buttons.button_3 \
  -text " 3 " \
  -font "Helvetica $btnfontsize bold" \
  -command {button_cmd 3 $pushbtntime}
pack ${traffic}.buttons.button_3 -side top -padx $butgap -pady $butgap

display ${traffic}.ledframe.leds traffic

pack $app -side bottom
$app raise default

wm title .controls "Controls"
wm geometry .controls ${winwidth}x${winheight}+100+100
wm attributes .controls -topmost 1

# Setup sim
if {$now > 0} {
  restart -f
}
if {[runStatus] == "ready" || [runStatus] == "break"} {
  # Setup the triggers to update the displayed controls
  setup_monitor
  echo "NOTE - Trigger setup."
} {
  echo "WARNING - Load the design then call TCL 'setup_monitor'."
}
echo "NOTE - Use 'display_cursor' to update the display to the values shown under the cursor."
# Switch the tab used to display the buttons and LEDs to the one preferred by the active 'led4_button4' architecture
get_button_tab
run -all
view wave
wave seetime $now
