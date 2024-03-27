.. _AES_example:

===========
AES Example
===========

As part of FOBOS, we provide a simple AES-128 implementation in VHDL. The VHDL code for this AES implementation is 
provided in the directory ``dut/example_cores/AES-128``. The block diagram of this implementation is shown in 
:numref:`fig_AES-block`. 

.. _fig_AES-block:
.. figure::  ../figures/aes128.png
   :align:   center
   :height: 100 px

   Block Diagram of the Example AES Implementation

-----------------------
AES Top Level Interface
-----------------------



---------------------------
FOBOS Wrapper Configuration
---------------------------

The AES example has an AXI-wrapper interface.
The AES example has to be instantiated as follows in the ``core_wrapper.vhd`` file around line 173.
These are the default settings for this file.

.. code-block:: vhdl

    --=============================================
    -- BEGING USER CRYPTO  
    -- Instantiate your core here
    crypto_core : entity work.aes_axi(behav)
    port map(
    	clk         => clk,
    	rst         => not crypto_input_en,
        -- data signals
    	pdi_data    => crypto_di0_data,
    	pdi_valid   => crypto_di0_valid,
    	pdi_ready   => crypto_di0_ready,

        sdi_data    => crypto_di1_data,
    	sdi_valid   => crypto_di1_valid,
    	sdi_ready   => crypto_di1_ready,

    	do_data     => crypto_do_data,
    	do_ready    => crypto_do_ready,
    	do_valid    => crypto_do_valid

        --! if rdi_interface for side-channel protected versions is required, uncomment the rdi interface
        -- ,rdi_data => crypto_rdi_data,
        -- rdi_ready => crypto_rdi_ready,
        -- rdi_valid => crypto_rdi_valid
    );
    -- END USER CRYPTO
    --=============================================


The example AES expects one block of plaintext or 128-bit, and one 128-bit key on the input. These have to 
be placed on *FIFO_0* and *FIFO_1* respectively. As the width of PDI and SDI are 128-bit, the width of 
these FIFOs have to match and they have to be only one word deep.
The output of this AES is also 128-bit wide, hence *FIFO_OUT* also has to be 128-bit wide and one word deep.
This has to be defined in ``core_wrapper_pkg.vhd`` which is shown below. This is also the default configuration 
of this file.

.. code-block:: vhdl

    package core_wrapper_pkg is
        -- input fifos
        constant FIFO_0_WIDTH           : natural := 128    ;
        constant FIFO_0_LOG2DEPTH       : natural := 1      ;
        constant FIFO_1_WIDTH           : natural := 128    ;
        constant FIFO_1_LOG2DEPTH       : natural := 1      ;
        -- output fifo
        constant FIFO_OUT_WIDTH         : natural := 128    ;    
        constant FIFO_OUT_LOG2DEPTH     : natural := 1      ;
        -- random data
        constant RAND_WORDS             : natural := 8      ;
        constant FIFO_RDI_WIDTH         : natural := 64     ;
        constant FIFO_RDI_LOG2DEPTH     : natural := 3      ;  
    
    end core_wrapper_pkg;


----------------------------
Generating Bitstream for DUT
----------------------------
