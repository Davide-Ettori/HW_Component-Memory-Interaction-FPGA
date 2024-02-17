library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is 
    port( 
        i_clk      : in std_logic; 
        i_rst      : in std_logic; 
        i_start    : in std_logic; 
        i_w        : in std_logic; 
        o_z0       : out std_logic_vector(7 downto 0); 
        o_z1       : out std_logic_vector(7 downto 0); 
        o_z2       : out std_logic_vector(7 downto 0); 
        o_z3       : out std_logic_vector(7 downto 0); 
        o_done     : out std_logic; 
        o_mem_addr : out std_logic_vector(15 downto 0); 
        i_mem_data : in std_logic_vector(7 downto 0); 
        o_mem_we   : out std_logic := '0';
        o_mem_en   : out std_logic := '1'
    ); 
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    signal count       : std_logic_vector(4 downto 0) := "00000";
    signal addr        : std_logic_vector(15 downto 0):= "0000000000000000";
    signal got_channel : std_logic := '0';
    signal one         : std_logic_vector(4 downto 0) := "00001";
    signal two         : std_logic_vector(4 downto 0) := "00010";
    signal sixteen     : std_logic_vector(4 downto 0) := "10000";
    signal ch_0        : std_logic := '0';
    signal ch_1        : std_logic := '0';
    signal memo_0      : std_logic_vector(7 downto 0) := "00000000"; 
    signal memo_1      : std_logic_vector(7 downto 0) := "00000000"; 
    signal memo_2      : std_logic_vector(7 downto 0) := "00000000";  
    signal memo_3      : std_logic_vector(7 downto 0) := "00000000"; 
    signal read_0      : std_logic := '0';
    signal read_1      : std_logic := '0';
    signal show        : std_logic := '0';
    signal tot         : std_logic_vector(4 downto 0) := "00000";
    signal index       : std_logic_vector(3 downto 0) := "0000";
    type s is (s0, s1, s2, s3, s4, s5, s6);
    signal cur_state, next_state : s := s0;

    begin
        o_mem_addr <= std_logic_vector(shift_right(unsigned(addr), to_integer(unsigned(sixteen - count + two))));
        tot <= sixteen - count + one;
        index <= tot(3 downto 0);
    -----------------------------------------------------------------------------------------------------------------------------------    
        read_channel : process(i_clk, i_rst, i_start) is
            begin
                if i_rst = '1' then ch_0 <= '0'; ch_1 <= '0';
                elsif rising_edge(i_clk) then
                    if read_1 = '1' and i_start = '1' then ch_1 <= i_w; end if;
                    if read_0 = '1' and i_start = '1' then ch_0 <= i_w; end if;
                 end if;
            end process read_channel;
         
         counter : process(i_clk, i_rst, i_start) is
            begin
                if i_rst = '1' then count <= "00000"; addr <= "0000000000000000";
                elsif rising_edge(i_clk) then
                    if i_start = '1' then count <= count + one; addr(to_integer(unsigned(index))) <= i_w; end if;
                    if show = '1' then count <= "00000"; addr <= "0000000000000000"; end if;
                end if;
         end process counter;
         
         save_output : process(i_clk, i_rst) is
            begin
                if i_rst = '1' then memo_0 <= "00000000"; memo_1 <= "00000000"; memo_2 <= "00000000"; memo_3 <= "00000000";
                elsif rising_edge(i_clk) then
                    if ch_1 = '0' and ch_0 = '0' and got_channel = '1' then memo_0 <= i_mem_data; end if;
                    if ch_1 = '0' and ch_0 = '1' and got_channel = '1' then memo_1 <= i_mem_data; end if;
                    if ch_1 = '1' and ch_0 = '0' and got_channel = '1' then memo_2 <= i_mem_data; end if;
                    if ch_1 = '1' and ch_0 = '1' and got_channel = '1' then memo_3 <= i_mem_data; end if;
                end if; 
         end process save_output;
         
         write_output : process(i_clk, i_rst) is
            begin
                if i_rst = '1' then o_z0 <= "00000000"; o_z1 <= "00000000"; o_z2 <= "00000000"; o_z3 <= "00000000";
                elsif rising_edge(i_clk) then
                    if show = '1' then o_z0 <= memo_0; o_z1 <= memo_1; o_z2 <= memo_2; o_z3 <= memo_3;
                    else o_z0 <= "00000000"; o_z1 <= "00000000"; o_z2 <= "00000000"; o_z3 <= "00000000"; end if;
                end if;
         end process write_output;
    -----------------------------------------------------------------------------------------------------------------------------------    
         refresh_fsm : process(i_clk, i_rst) is
            begin
                if i_rst = '1' then cur_state <= s0;
                elsif rising_edge(i_clk) then cur_state <= next_state; end if;
         end process refresh_fsm;
         
         run_fsm : process(cur_state, i_start) is
            begin
                case cur_state is
                    when s0 =>
                       got_channel <= '0';
                       show <= '0';
                       o_done <= '0';
                       read_0 <= '0';
                       read_1 <= '0';
                       if i_start = '0' then next_state <= s0;
                       else next_state <= s1; read_1 <= '1'; end if;
                    when s1 =>
                        next_state <= s2;
                        read_0 <= '1';
                        read_1 <= '0';
                        got_channel <= '0';
                        show <= '0';
                        o_done <= '0';
                    when s2 =>
                        next_state <= s3;
                        read_0 <= '0';
                        read_1 <= '0';
                        got_channel <= '1';
                        show <= '0';
                        o_done <= '0';
                    when s3 =>
                        read_0 <= '0';
                        read_1 <= '0';
                        got_channel <= '1';
                        show <= '0';
                        o_done <= '0';
                        if i_start = '1' then next_state <= s3;
                        else next_state <= s4; end if;
                    when s4 =>
                        next_state <= s5;
                        read_0 <= '0';
                        read_1 <= '0';
                        got_channel <= '1';
                        show <= '0';
                        o_done <= '0';
                    when s5 =>
                        next_state <= s6;
                        read_0 <= '0';
                        read_1 <= '0';
                        got_channel <= '0'; 
                        show <= '1'; 
                        o_done <= '0';
                    when s6 =>
                        next_state <= s0;
                        read_0 <= '0';
                        read_1 <= '0';
                        show <= '0';
                        o_done <= '1';
                        got_channel <= '0';
               end case;
         end process run_fsm;
end behavioral;