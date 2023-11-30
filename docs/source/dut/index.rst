.. _dut-label:

*********
FOBOS DUT
*********

A DUT (Design Under Test) board must be connected to the control board to run SCA.

===============
Setup DUT Board
===============

This section describes how to connect the supported DUTs to FOBOS Control and how to modify the DUTs if needed.
FOBOS supports the following boards as DUT:


.. toctree::
   :maxdepth: 1
   
   nexys3
   cw305
   fbd-a7

=========================
DUT Algorithm Development
=========================

This section describes how to interface the DUT wrapper and the Function Core (victim).
The  Function Core (a.k.a victim), is the algorithm to be tested. The DUT wrapper is hardware that is instantiated on the same
FPGA as the function core and used to communication to the control board.
The function core is user provided. However, the DUT wrapper is included with FOBOS.
The DUT Wrapper handles communication to the control board and includes FIFOs to store input and output data.



.. toctree::
   :maxdepth: 1
   
   dut_development


