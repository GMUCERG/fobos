library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dut_fwft_fifo is
    generic(
        G_W         : integer := 8; --! IO width
        G_LOG2DEPTH : integer := 4  --! log2 of the depth
    );
    port(
        clk         : in    std_logic;
        rst         : in    std_logic;
        din         : in    std_logic_vector(G_W - 1 downto 0);
        din_valid   : in    std_logic;
        din_ready   : out   std_logic;
        dout        : out   std_logic_vector(G_W - 1 downto 0);
        dout_valid  : out   std_logic;
        dout_ready  : in    std_logic
    );
end entity dut_fwft_fifo;

architecture behav of dut_fwft_fifo is

    constant DEPTH : integer := 2**G_LOG2DEPTH;

    type mem_arr is array (0 to DEPTH - 1) of std_logic_vector(G_W - 1 downto 0);
    signal mem              : mem_arr;

    -- Internal flags
    signal empty            : std_logic;
    signal full             : std_logic;
    -- signal wr_index         : integer range 0 to DEPTH - 1;
    -- signal rd_index         : integer range 0 to DEPTH - 1;

    signal wr_index         : unsigned(G_LOG2DEPTH-1 downto 0);
    signal rd_index         : unsigned(G_LOG2DEPTH-1 downto 0);

    signal entries          : integer range 0 to DEPTH;
    signal wr_fire          : std_logic;
    signal rd_fire          : std_logic;
begin

    full            <= '1' when (entries = DEPTH) else '0';
    empty           <= '1' when (entries =     0) else '0';
    din_ready       <= not full;
    dout_valid      <= not empty;

    wr_fire         <= din_valid and din_ready;
    rd_fire         <= dout_valid and dout_ready;

    ctrl : process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                wr_index    <= (others=>'0');
                rd_index    <= (others=>'0');
                entries     <= 0;
            else
                if (wr_fire and not rd_fire) then
                    wr_index <= wr_index + 1;
                    entries  <= entries + 1;
                elsif (not wr_fire and rd_fire) then
                    rd_index <= rd_index + 1;
                    entries <= entries - 1;
                elsif (wr_fire and rd_fire) then
                    wr_index <= wr_index + 1;
                    rd_index <= rd_index + 1;
                end if;

            end if;
        end if;
    end process ctrl;

    dout <= mem(to_integer(rd_index));

    mem_write: process(clk)
    begin
        if rising_edge(clk) then
            if (wr_fire) then
                mem(to_integer(wr_index)) <= din;
            end if;
        end if;
    end process mem_write;

end architecture behav;