FOBOS
=====

Flexible Open-source workBench fOr Side-channel analysis (FOBOS) is an "acquisition to analysis" solution which includes all necessary software to control the device under test (attack) (DUT), trigger the oscilloscope, obtain the measurements and analyze them using several power analysis techniques.

FOBOS splits the Side Channel Analysis (SCA) setup into a control board, a DUT, and the SCA workstation. The firmware for the control board can be found in the folder `control`. The hardware description language files required to adapt a cryptographic algorithm to a particular FOBOS DUT are in the folder `DUT`. The `hardware` folder on the other hand contains circuit board design files for FOBOS boards such as the FOBOS Shield and several FOBOS DUTs. The `software` folder contains the scripts to run FOBOS. These python scripts run partially on the SCA workstation within a Jupyter notebook and partially on the Pynq DUT. The `docs` folder contains the FOBOS documentation.

FOBOS Control Board
-------------------
* `control`
   VHDL sources for configuring the FOBOS Control Boards. Requires Xilinx Vivado 2020.2.
   * `pynqctrl`
     Using a Digilent Inc PYNQ-Z1 or TUL PYNQ-Z2 as control board and either the FOBOS Shield or an oscilloscope for measurements.
   * `ip-repo` 
     Modules used by either control board.

FOBOS DUT
---------
* `dut`
  VHDL sources for FOBOS wrapper and pin assignments to prepare a DUT for instantiating a target algorithm.
  * `fpga_wrapper`
    Source code of the FOBOS wrapper common to all FPGA targets and the constraint files for the supported DUTs.
  * `example_cores`
    Contains implementations of example algorithms required for the tutorials.
 
FOBOS Hardware
--------------
* `hardware`
  Printed Circuit Board design files for FOBOS boards. Requires KiCad.
  * `fobos-shield`
    FOBOS Shield is a data aqcuisition and benchmarking boad that can be attached to the PYNQ-Z1 board.
  * `fobos-shield-Z2`
    FOBOS Shield is a data aqcuisition and benchmarking boad that can be attached to the PYNQ-Z2 board.
  * `fobos-mtc`
    FOBOS Multi Target Connector allows simple connection of DUT boards with PMOD connectors to the FOBOS Shield.
  * `fobos-dut`
    Contains folders for each FOBOS DUT.

FOBOS Software
--------------
* `software`
  FOBOS is controlled by a series of Python 3 scripts. 

  * `foboslib` contains all common FOBOS functions.
  * `notebooks` contains Jupyter notebooks that run within Jupyter Lab on the SCA workstation.
  * `examples` contains command line examples that run on the SCA workstation.
  * `firmware` contains software that runs on FOBOS Control.

Documentation
-------------

* `docs` 
  Contains the sources for the Sphinx based documentation of FOBOS and the makefile to compile it.
  
License
-------

Copyright 2023 cryptographic Engineering Research Group (CERG)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



