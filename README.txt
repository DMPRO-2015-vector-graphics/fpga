This project setup uses `make` to run the Xilinx tools. This makes it
possible to largely avoid using the Xilinx GUI, relying instead on an
editor with a smaller footprint such as emacs or vim for VHDL
coding. It is still necessary to use the Xilinx GUI for viewing RTL
schematics.

# QUICKSTART

Put your VHDL files in src/, and type `make`. This should start the
Xilinx tool flow. If your code has no errors, the resulting bitfile
will be stored in the products/ folder. 

Put your test files in test/, and type `make sim_<tb_name>` to start a
simulator running test/<tb_name>.vhd.

# FOLDER STRUCTURE

The folders herein contain the following:

src/          ---- Put your code in this folder. Arranging your code 
                   in subfolders within src/ should work.
test/         ---- Put your test benches here. Also store various test
                   setup files here: see section on simulation below.
supportFiles/ ---- Contains the support files, i.e. the exercise 
                   infrastructure
products/     ---- Notable intermediate and final products are stored 
                   here. Examples: RTL schematic (*.ngr) and bitfile (*.bit)
work/         ---- Working directory for Xilinx tools, which will be 
                   filled with intermediate files.

# MAKEFILE TARGETS

The following makefile targets are available:

gen               -- Generates a bitfile. Depends on par.
impl              -- Implements the design (translate, map, par). Depends on par.
par               -- Runs place and route. Depends on map.
map               -- Runs map. Depends on translate.
trans             -- Runs translate. Depends on synth, contraint files (*.ucf) and
                     .ngc files generated from .xco files.
synth             -- Synthesizes the design. Depends on prj.
prj               -- Generates project files from the source files in src/. Depends
                     on .vhd files generated from .xco files.
sim_%             -- Expects a test bench in test/%.vhd. Opens it in ISim, 
                     using wave file test/%.wcfg.
vcd_sim_%         -- Expects a test bench in test/%.vhd. Runs it with ISim 
                     in non-gui-mode, storing a waveform with all signals 
                     in products/%.vcd. This file can be opened using GTKWave.
timing_report     -- Generates a post-place-and-route timing report.

# EXAMPLES

Generate a bitfile for the design (stored in products/MIPSSystem.bit):
    `make`

Synthesize the design:
    `make synth`

View the RTL schematic of the design:
    1. Run `make synth`
    2. Open ISE (`/opt/Xilinx/launch-ise.sh`)
    3. Click "Open File" from the File menu (hotkey: Ctrl+O)
    4. Select the "products/MIPSSystem.ngr" file

Run the test bench "test/tb_MIPSProcessor.vhd":
    `make sim_tb_MIPSProcessor`

Generate a VCD file from running "test/tb_MIPSProcessor.vhd":
    `make vcd_sim_tb_MIPSProcessor`

# SIMULATION

Add new test benches to the test/ folder. Only add test bench
VHDL-files here; test utility files must be placed in src/.

## ISIM GUI-based simulation

To start the ISIM gui with test bench test/<tb_name>.vhd, run:
   `make sim_<tb_name>`

To reuse your wave configuration when restarting the simulation:
   - Select "yes" when ISim asks if you want to save changes to "Default.wcfg"
   - Save the file as "test/<tb_name>.wcfg"
       (Example: test/tb_MIPSProcessor.wcfg")

To select some commands to run whenever a simulation is started:
   - Create the file "test/<tb_name>.tcl"
       (Example: test/tb_MIPSProcessor.tcl)
   - Add simulation commands to the file as desired (e.g. "run all").

## VCD-based simulation

If the ISIM gui is laggy, an alternative is to have the simulator
produce a Value Change Dump (VCD) file: a plain text log of signal
activity. This file can be downloaded to your own computer, and
inspected using free software tools like GTKWave.

To run a test bench and produce a VCD file, run:
   `make vcd_sim_<tb_name>`

The VCD file will be placed in products/<tb_name>.vcd.

To configure the way in which the simulator is run (should hopefully
not be necessary): 
   1. Run `cp -v test/{default,<tb_name>}.conf`
   2. Edit the new test/<tb_name>.conf file as desired:

       - To change the unit for which signal activity is gathered,
         edit the first line. As an example, the tb_MIPSProcessor only
         gathers signals for the MIPSProcessor unit (instance name
         Processor) since the IP core memory modules were not amenable
         to VCD generation. Syntax: /<I1>/<I2>/.../<instance>, where
         I1 -> I2 -> ... -> instance is the path in the module
         hierarchy to the instance you wish to instrument, labeled
         with instance names.

       - To change the amount of time the simulation should be run
         for, edit the second line.
   
Take care that the line order is preserved, and that both lines are
present: the Makefile is quite brittle, and will only work if the new
configuration file matches the structure of test/default.conf exactly.

# REPORTS

The following reports are generated by the Makefile after different
stages of the build flow:

 - products/MIPSSystem.syr   
       Produced after synthesis. Contains synthesis warnings/errors,
       preliminary resource (LUT/register) use statistics, and
       preliminary timing data.

 - products/MIPSSystem_map.mrp
       Produced after map. Contains map warnings/errors (such as too
       large designs and unsynthesizable behaviour) and resource use
       statistics.

 - products/MIPSSystem.par
       Produced after place and route. Contains PaR warnings/errors,
       final resource report and simple timing analysis data. 

A more detailed timing report can be produced by running:
   `make timing_report`

This produces the following file:

 - products/MIPSSystem_postpar_timing.twr
       More detailed timing report run after place and route. Lists
       the three slowest path in the design and their slack (i.e. the
       margin by which the path meets the constraint of 24 MHz). A
       probable maximum frequency is listed near the bottom of the
       file (search for "Maximum frequency").
