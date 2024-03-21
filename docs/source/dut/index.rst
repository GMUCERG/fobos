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
   
   fbd-a7
   nexys3
   cw305

=========================================
Using the GMU LWC Hardware API with FOBOS
=========================================

This section describes how to use a cryptographic hardware implementation that adheres to the GMU LWC Hardware API 
with FOBOS. As part of FOBOS, we provide a wrapper for the GMU LWC Hardware API and a simple AES implementation that follows this API.

.. toctree::
   :maxdepth: 1

   lwc_hardware_api
   fobos_wrapper
   AES_example
   DUT_implementation


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


