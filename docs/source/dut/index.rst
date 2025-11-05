.. _dut-label:

*********
FOBOS DUT
*********

A DUT (Design Under Test) board must be connected to the control board to run SCA.

.. _dut-board:
===============
Setup DUT Board
===============

This section describes how to connect the supported DUTs to FOBOS Control and how to modify the DUT Boards if needed.
FOBOS supports the following boards as DUT:


.. toctree::
   :maxdepth: 1
   
   fbd-a7
   nexys3
   cw305

===================
FOBOS DUT Interface
===================

This section describes how to interface a cryptographic hardware implementation with FOBOS. As part of FOBOS, we provide a wrapper for implementations that follow a simple AXI stream protocol interface such as the GMU LWC Hardware API interface as described in :numref:`lwc_hw_api`.

.. toctree::
   :maxdepth: 1

   fobos_wrapper
   gmu_lwc_api


.. _algorithm-implementation:
=================================
Example Algorithm Implementations
=================================

This section describes how to compile the provided example *AES* for use with FOBOS, as well as a GMU LWC Hardware API compatible implementation of *ASCON* from the Ascon Team, and the *dummy DUT* that we provide. The dummy DUT is a great starting point for making your own hardware implementation of a cryptographic algorithm compatible with FOBOS.

.. toctree::
   :maxdepth: 1

   AES_example
   ASCON_example
   dut_development


