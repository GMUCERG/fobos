.. _tvgen-label:

Test Vector Generation
**********************

The user must prepare test vectors before running data acquisition. User defined scripts or scripts provided with FOBOS can be used.
The data acquisition scripts will send the test vectors one at a time and collect traces from the oscilloscope.

Cryptographic hardware interfaces typically use multiple data streams as input to cryptographic cores. 
For example, some algorithms might need plaintext/ciphertext, cryptographic keys, and random data. 
FOBOS uses a simple protocol to transfer test vectors containing these data streams to the DUT. This protocol 
is described in :numref:`dut-protocol`.

FOBOS provides a simple test vector generator called FobosTVGen. It uses a key and generates a configurable number 
of test vectors with random data. Furthermore, FOBOS has tools to convert test vectors 
that follow the Lightweight Cryptography Hardware API (LWC API) standard for use with FOBOS. 
An additional tool allows for the creation of test vectors for Test Vector Leakage Analysis (TVLA) of unprotected and 
protected implementations.

.. _fig_dut-block2:
.. figure::  ../figures/dut-block.png
   :align:   center
   :height: 350 px

   Block Diagram of FOBOS Wrapper for the DUT


.. toctree::
   :maxdepth: 1

   dut_protocol
   FobosTVGen
   CryptoTVGen
   TVLA_vectors






