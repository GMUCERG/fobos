Data flow description
---------------------

Test vectors are sent form PC one at a time to the control board which stores them briefly.
The control board starts sending the test vector to the DUT board through the interface described below.
The DUT wrapper then puts data in the correct FIFOs (PDI, SDI and RDI).
Once the DUT wrapper receives the start command from the controller, it de-asserts the function core reset signal and the function core will run and consume the data in the FIFOs. 
The output of the function core is stored in the DO fifo. 
Once the DO FIFO accumulates EXPECTED_OUTPUT bytes, the DUT wrapper will send this data to the control board which forwards it to the PC.


The DUT Wrapper <–> Function core interface
-------------------------------------------
The protocol follows a simple AXI stream protocol. The 'valid' signals indicates data from source are valid and 'ready' signals 
indicates destination is ready to use data. When both 'valid' and 'ready' signals are set to logic 1, data is transferred.
All the data signals shown in the listing below, are connected to the FIFOs PDI, SDI, RDI and DO.

The function core (victim) is instantiated as follows in the FOBOS_DUT.vhd file.

.. code-block:: vhdl


    victim: entity work.victim(behav)
        -- Choices for W and SW are independently any multiple of 4, defined in generics above
        generic map  (
            G_W          => W, -- ! pdi and do width (mulltiple of 4)
            G_SW         => SW -- ! sdi width (multiple of 4) 
        )
        port map(
            clk => clk,
            rst => start,  
            -- data signals
            pdi_data  => pdi_data,
            pdi_valid => pdi_valid,
            pdi_ready => pdi_ready,
            sdi_data => sdi_data,
            sdi_valid => sdi_valid,
            sdi_ready => sdi_ready,
            do_data => result_data,
            do_ready => result_ready,
            do_valid => result_valid

        --  ! if rdi_interface for side-channel protected versions is required,
        --  ! uncomment the rdi interface
        --  ,rdi_data => rdi_data,
        --  rdi_ready => rdi_ready,
        --  rdi_valid => rdi_valid
    );

The generic W is the PDI and DO width in bits.
The generic SW is the SDI width.


It is highly recommended that the DUT is tested using the capture/dut/fpga_dut/fobos_dut_tb.vhd test bench and ensure 
that the output is valid. 
This testbench needs one test vector to be stored in the file dinFile.txt and generates doutFile.txt output file.

Dummy DUT Example
-----------------

You can find an example dummy DUT in fobos/capture/dut/example_cores/dummy1.
This dummy core is used to test FOBOS DUT.
It simply echos back configurable number of words of the PDI sent in the test vector.
The dummy core in the listing below, echos seven 8-bit words of the PDI from the test vector received from the DUT wrapper.

.. code-block:: vhdl

    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    entity dummy is
        Generic(
            N        : integer := 8;
            NUMWORDS : integer := 7
        );
        port(clk       : in  STD_LOGIC;
             rst       : in  STD_LOGIC;
             pdi_data  : in  STD_LOGIC_VECTOR(N - 1 downto 0);
             pdi_valid : in  STD_LOGIC;
             pdi_ready : out STD_LOGIC;
             sdi_data  : in  STD_LOGIC_VECTOR(N - 1 downto 0);
             sdi_valid : in  STD_LOGIC;
             sdi_ready : out STD_LOGIC;
             do_data   : out STD_LOGIC_VECTOR(N - 1 downto 0);
             do_valid  : out STD_LOGIC;
             do_ready  : in  STD_LOGIC
            );
    end dummy;

    architecture behav of dummy is
        type state is (IDLE, RUN);
        signal current_state             : state;
        signal next_state                : state;
        signal cnt_clr, cnt_en, cnt_done : std_logic;
        signal cnt, next_cnt             : std_logic_vector(15 downto 0);

    begin

        ctrl : process(clk)
        begin
            if (rising_edge(clk)) then
                if (rst = '1') then
                    current_state <= IDLE;
                else
                    current_state <= next_state;
                end if;

            end if;

        end process;

        comb : process(current_state, pdi_valid, sdi_valid, do_ready, cnt_done)
        begin
            -- defaults
            pdi_ready <= '0';
            sdi_ready <= '0';
            do_valid  <= '0';
            cnt_clr   <= '0';
            cnt_en    <= '0';

            case current_state is
                when IDLE =>
                    cnt_clr <= '1';
                    if pdi_valid = '1' and sdi_valid = '1' and do_ready = '1' then
                        next_state <= RUN;
                    else
                        next_state <= IDLE;
                    end if;

                when RUN =>
                    if cnt_done = '1' then
                        next_state <= IDLE;
                    else
                        if pdi_valid = '1' and sdi_valid = '1' and do_ready = '1' then
                            pdi_ready <= '1';
                            sdi_ready <= '1';
                            do_valid  <= '1';
                            cnt_en    <= '1';
                        end if;
                        next_state <= RUN;
                    end if;

                when others =>
                    next_state <= IDLE;

            end case;

        end process;
        --do_data <= pdi_data xor sdi_data;
        do_data <= pdi_data;

        count : process(clk)
        begin
            if (rising_edge(clk)) then
                cnt <= next_cnt;
            end if;
        end process;
        next_cnt <= (others => '0') when cnt_clr = '1'
                    else cnt + 1 when cnt_en = '1'
                    else cnt;

        cnt_done <= '1' when (cnt = NUMWORDS) else '0';

    end behav;

Generating the dummy DUT bitstream
----------------------------------

This procedure describes how to generate the bitstream for the dummy DUT. You don't need to perform
this procedure to run the dummy example since the bitstream is already generated.
However, this procedure aims to show how to instantiate a function core in FOBOS DUT wrapper.


1. Create a project in Vivado (or ISE) and add all vhdl files from fobos/capture/dut/fpga_dut (except half_duplex_du.vhd)
and fobos/capture/dut/example_cores/dummy1.

2. Note that in FOBOS_DUT.vhd, the dummy dut is instantiated as follows:


.. code-block:: vhdl

    victim: entity work.dummy(behav)

    -- Choices for W and SW are independently any multiple of 4, defined in generics above

        generic map  (
            N          => 8,
            NUMWORDS        => 7
        )

    port map(
        clk => clk,
        rst => start,  --! The FOBOS_DUT start signal meets requirements 
                       --!for synchronous resets used in 
                       --! CAESAR HW Development Package AEAD

    -- data signals

        pdi_data  => pdi_data,
        pdi_valid => pdi_valid,
        pdi_ready => pdi_ready,

    sdi_data => sdi_data,
        sdi_valid => sdi_valid,
        sdi_ready => sdi_ready,

        do_data => result_data,
        do_ready => result_ready,
        do_valid => result_valid

    ----! if rdi_interface for side-channel protected versions is required, 
    ----! uncomment the rdi interface
    --  ,rdi_data => rdi_data,
    --  rdi_ready => rdi_ready,
    --	rdi_valid => rdi_valid

    );

3. Note that the W and SW (PDI and SDI width) generics in FOBOS_DUT.vhd are set to 8.
4. Add the constraint file for the DUT (see DUT Setup) fobos/capture/dut/fpga_dut.
5. Generate the bitstream.
6. Find your bitstream file FOBOS_DUT.bit in the Vivado/ISE project folders.

Running the dummy DUT example (on Nexys3 DUT)
---------------------------------------------

1. Make sure your hardware is setup properly and the DUT is connected to the control board.
2. Run the dummyDUTCapture.py script as follows::

    $ cd path-to-fobos/software
    $ python dummyDUTCapture.py

This script is preconfigured to use the fobos/workspace/DummyProject as a project folder.
The folder includes a pre-generated bitstream file that FOBOS will use to program the Nexys3 DUT.
This requires digilent Adept tool 'djtgcfg' to be installed and callable from the Linux shell.
The project folder also includes a pre-generated test vector file 'dinFile.txt'.
