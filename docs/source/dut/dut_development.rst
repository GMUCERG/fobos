.. _DUT-development:

=================
Dummy DUT Example
=================

You can find an example dummy DUT in ``/dut/example_cores/dummy1``.
This dummy core is used to test the FOBOS DUT and is a great starting point for making your own hardware 
implementation of a cryptographic algorithm compatible with FOBOS.

The dummy core simply echos back configurable number of words of the PDI sent in the test vector.
Its listing is shown below. It echos four 32-bit words of the PDI from the test vector received from the DUT wrapper.

.. code-block:: vhdl

    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    entity dummy is
        Generic(
            N        : integer := 32;
            NUMWORDS : integer := 4
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

This procedure describes how to generate the bitstream for the dummy DUT. 

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
