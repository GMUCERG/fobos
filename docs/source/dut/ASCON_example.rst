.. _ASCON_example:

=============
ASCON Example
=============

This example is based on the NIST LWC Hardware Reference Design of Ascon v1.2 by the Ascon team at
https://ascon.iaik.tugraz.at/index.html. We are using their **v1** implementation of Ascon-128 v1.2 which 
uses a 32-bit interface and computes one permutation per clock cycle. 

.. _tab_example-ascon:
.. table:: Technical Details of the **v1** implementation of Ascon-128 v1.2
    :align:   center

    +---------------------------------------+-----------+
    | Interface                             | LWC HW API|
    +---------------------------------------+-----------+
    | PDI width                             |         32|
    +---------------------------------------+-----------+
    | SDI width                             |         32|
    +---------------------------------------+-----------+
    | DO width                              |         32|
    +---------------------------------------+-----------+
    | Permutation rounds per clock cycle    |          1|
    +---------------------------------------+-----------+
    | Clock cycles for encrypting one block |          ?|
    | of Plaintext and one block of AD      |           |
    +---------------------------------------+-----------+


-----------------------
First Steps
-----------------------

Create a new directory for the ASCON DUT project for example ``ASCON-DUT``.
Clone the git repository of ASCON from https://github.com/ascon/ascon-hardware. 
Copy all files from the 
``dut/fpga_wrapper/src_rtl`` directory and the ``dut/fpga_wrapper/src_tb/core_wrapper_tb.vhd`` to this directory.
Additionally copy the constraint file that matches your DUT from the ``dut/fpga_wrapper/constraints`` directory.
Only modify the copied files. The example below assumes that you have installed FOBOS in ``/opt``
and that your DUT is the FOBOS FBD-A7.

.. code-block:: bash
    :caption: Command line example for copying all relevant files

    mkdir ASCON-DUT
    cd !$
    git clone https://github.com/ascon/ascon-hardware.git
    cp /opt/fobos/dut/fpga_wrapper/src_rtl/* .
    cp /opt/fobos/dut/fpga_wrapper/src_tb/core_wrapper_tb.vhd .
    cp /opt/fobos/dut/fpga_wrapper/constraints/FOBOS_Artix7.xdc .


-------------------------
Ascon Top Level Interface
-------------------------

The top level file of the LW Hardware API compatible implementation is 
``ascon-hardware/hardware/ascon_lwc/src_rtl/LWC/LWC.vhd``. 
Its interface is shown in :numref:`lst_lwc-top` which is very generic and 
features three AXI4-Stream compatible interfaces, one for plaintext (PDI), key (SDI), and ciphertext (DO) as 
well as a clock and reset input. This interface matches exactly the FOBOS wrapper's interface for the Crypto Core.
The width of the PDI matches the size of DO. This width and the width of SDI is specified in 
``ascon-hardware/hardware/ascon_lwc/src_rtl/v1/LWC_config_32.vhd`` shown in 
:numref:`lst_ascon_config_32`.

.. _lst_lwc-top:
.. code-block:: vhdl
    :caption: Entity declaration of the 32-bit Ascon Interface in LWC.vhd

    entity LWC is
        generic(
            G_DO_FIFO_DEPTH : natural := 1  -- 0: disable output FIFO, 1 or 2 (elastic FIFO)
        );
        port(
            --! Global ports
            clk       : in  std_logic;
            rst       : in  std_logic;
            --! Public data input
            pdi_data  : in  std_logic_vector(PDI_SHARES * W - 1 downto 0);
            pdi_valid : in  std_logic;
            pdi_ready : out std_logic;
            --! Secret data input
            sdi_data  : in  std_logic_vector(SDI_SHARES * SW - 1 downto 0);
            sdi_valid : in  std_logic;
            sdi_ready : out std_logic;
            --! Data out ports
            do_data   : out std_logic_vector(PDI_SHARES * W - 1 downto 0);
            do_last   : out std_logic;
            do_valid  : out std_logic;
            do_ready  : in  std_logic
            --! Random Input
    --        ;
    --        rdi_data  : in  std_logic_vector(RW - 1 downto 0);
    --        rdi_valid : in  std_logic;
    --        rdi_ready : out std_logic
        );
    end entity;

.. _lst_ascon_config_32:
.. code-block:: vhdl
    :caption: Configuration of LWC HW Interface in LWC_config_32.vhd
    
    package LWC_config is
        --! External bus: supported values are 8, 16 and 32 bits
        constant W          : positive := 32;
        --! currently only W=SW is supported
        constant SW         : positive := W;
        --! Change the default value ONLY in a masked implementation
        --! Number of PDI shares, 1 for a non-masked implementation
        constant PDI_SHARES : positive := 1;
        --! Number of SDI shares, 1 for a non-masked implementation
        --! Does not need to be the same as PDI_SHARES but this is the default
        constant SDI_SHARES : positive := PDI_SHARES;
        --! Width of RDI port in bits. Set to 0 if not used.
        constant RW         : natural  := 0;
        --! Assume an asynchronous and active-low reset.
        --! Can be set to `True` given that support for it is implemented in the CryptoCore
        constant ASYNC_RSTN : boolean := False;
    end package;

More information about the LWC Hardware API can be found in :numref:`lwc_hw_api`.

---------------------------
FOBOS Wrapper Configuration
---------------------------

The LWC Hardware API has an AXI interface and has to be instantiated as follows in the ``core_wrapper.vhd`` file around line 173.
Note that the reset signal has to be inverted.

.. _lst_ascon-wrapper:
.. code-block:: vhdl
    :caption: Port Map for Ascon in core_wrapper.vhd

    --=============================================
    -- BEGING USER CRYPTO  
    -- Instantiate your core here
    crypto_core : entity work.LWC(structure)
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

This ASCON implementation  follows the LWC Hardware API which uses a communications protocol. 
While FOBOS is agnostic to this protocol, FOBOS still has to know the maximum number of 32-bit words required 
for the test vectors that go to PDI, SDA and the size of the response on DO. 
For example, the PDI test vector can include several blocks of plaintext, associated data, and 
the nonce.
The FOBOS wrapper stores complete PDI and SDA 
test vectors before invoking the crypto core to process the data and stores the response before 
sending it back to FOBOS Control. 
The depth of the FIFOS has to be specified in ``FIFO_x_LOG2DEPTH``.
For example if your longest test vector is 768 bits long, you compute 
:math:`\lceil{\log_2 \frac{768}{32}}\rceil = \lceil{\log_2 24}\rceil = 5`.
For our example we pick 4.
This has to be defined in ``core_wrapper_pkg.vhd`` which is shown in :numref:`lst_ascon-wrapper-pkg`. 
The values for the Random Data Input (RDI) can be ignored as this is not an SCA protected implementation.

.. _lst_ascon-wrapper-pkg:
.. code-block:: vhdl
    :caption: FIFO definitions for Ascon in core_wrapper_pkg.vhd

    package core_wrapper_pkg is
        -- input fifos
        constant FIFO_0_WIDTH           : natural := 32     ;
        constant FIFO_0_LOG2DEPTH       : natural := 4      ;
        constant FIFO_1_WIDTH           : natural := 32     ;
        constant FIFO_1_LOG2DEPTH       : natural := 4      ;
        -- output fifo
        constant FIFO_OUT_WIDTH         : natural := 32     ;    
        constant FIFO_OUT_LOG2DEPTH     : natural := 4      ;
        -- random data
        constant RAND_WORDS             : natural := 8      ;
        constant FIFO_RDI_WIDTH         : natural := 64     ;
        constant FIFO_RDI_LOG2DEPTH     : natural := 3      ;  
    
    end core_wrapper_pkg;

.. note::

    The depth of a FIFO is :math:`2^{FIFO\_x\_LOG2DEPTH}`. For example if FIFO_x_LOG2DEPTH = 2, 
    the depth of the FIFO is :math:`2^2 = 4`.
    FIFO_x_LOG2DEPTH has to be equal or larger than 1, i.e. the minimum depth of the FIFO is 2.

----------------------------
Generating Bitstream for DUT
----------------------------

Create a project in Vivado e.g., ``ASCON-FBD-A7`` and add all source files that you copied in your project 
directory e.g., ``ASCON-DUT`` and the constraint file.
From the ASCON git repository you need all files of the LWC Hardware API Support package in 
``ascon-hardware/hardware/LWC_rtl`` and all files from the **v1** implementation in 
``ascon-hardware/hardware/ascon_lwc/src_rtl/v1``.

Select the FPGA device that is on your DUT. You can find that information in the DUT descriptions in 
:numref:`dut-board`.

Make sure that the file ``core_wrapper_tb.vhd`` is only used for Simulation. This can be set in the 
*Source File Properties* window.

Select the file *half_duplex_dut.vhd* as the top level. **Don't run synthesis yet!**

Some files use the 2008 standard of VHDL. Vivado 2022.1 does not detect this and will create error 
messages when synthesizing the code. Note: You don't need to use Vivado 2022.1 to implement the DUT, 
you can use newer versions but they might still create the same error. 

As it is too tedious to set the VHDL revision of all files that use the 2008 standard individually,
you can type the following command into the TCL Console of Vivado to apply this to all files.

.. code-block:: tcl

    set_property FILE_TYPE {VHDL 2008} [get_files *.vhd]

Now you can run Synthesis followed by Implementation and Generate Bitstream.

The resulting bit file will be in the directory ``~/ASCON-DUT/ASCON-FBD-A7/ASCON-FBD-A7.runs/impl_1`` by
the name of ``half_duplex_dut.bit``. Copy this file into your Jupyter Notebook directory, maybe under 
a more descriptive name.

.. code-block:: bash
    
    cp ~/ASCON-DUT/ASCON-FBD-A7/ASCON-FBD-A7.runs/impl_1 ~/notebooks/fobos/ascon_fbd-a7.bit



