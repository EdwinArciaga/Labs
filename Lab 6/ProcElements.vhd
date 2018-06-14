--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
	Port(	selector: in std_logic;
			In0, In1: in std_logic_vector(31 downto 0);
			Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
-- Add your code here
	with selector select Result <= In0 when '0',
					In1 when others;
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
           opcode : in  STD_LOGIC_VECTOR (6 downto 0);
           funct3  : in  STD_LOGIC_VECTOR (2 downto 0);
           funct7  : in  STD_LOGIC_VECTOR (6 downto 0);
           Branch : out  STD_LOGIC_VECTOR(1 downto 0);
           MemRead : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           ALUCtrl : out  STD_LOGIC_VECTOR(4 downto 0);
           MemWrite : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC;
           ImmGen : out STD_LOGIC_VECTOR(1 downto 0));
end Control;
 
 architecture Boss of Control is

signal fin: std_logic_vector(13 downto 0);

 begin
 -- Add your code here
		fin <=	"000000000001ZZ" when funct7 = "0000000" and funct3 = "000" and opcode = "0110011" else -- add
			"000000100001ZZ" when funct7 = "0100000" and funct3 = "000" and opcode = "0110011" else -- sub
			"000000010001ZZ" when funct7 = "0000000" and funct3 = "111" and opcode = "0110011" else -- and
			"000000011001ZZ" when funct7 = "0000000" and funct3 = "110" and opcode = "0110011" else -- or
			"000000001011ZZ" when funct7 = "0000000" and funct3 = "001" and opcode = "0110011" else -- sll	
			"00000000101101" when funct7 = "0000000" and funct3 = "001" and opcode = "0010011" else -- slli		 
			"000001001011ZZ" when funct7 = "0000000" and funct3 = "101" and opcode = "0110011" else -- slr
			"00000100101101" when funct7 = "0000000" and funct3 = "101" and opcode = "0010011" else -- srli
			"00000000001101" when funct3 = "000" and opcode = "0010011" else -- addi
			"00000001101101" when funct3 = "110" and opcode = "0010011" else -- ori
			"00000001001101" when funct3 = "111" and opcode = "0010011" else -- andi
			"00010110001101" when funct3 = "010" and opcode = "0000011" else -- lw			 
			"00101010011010" when funct3 = "010" and opcode = "0100011" else -- sw
			"01001000000000" when funct3 = "000" and opcode = "1100011" else -- beq
			"10000100000000" when funct3 = "001" and opcode = "1100011" else -- bne
			"00000111101111" when opcode = "0110111" else -- lui 
			"11111111111111";	


	Branch <= fin(13 downto 12);
	MemRead <= fin(11);
	MemtoReg <= fin(10);
	ALUCtrl <= fin(9 downto 5);
	MemWrite <= fin(4);	
	ALUSrc <= fin(3);
	RegWrite <= not(clk) and fin(2);
	ImmGen <= fin(1 downto 0);	

end architecture Boss;
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;

architecture executive of ProgramCounter is

begin
-- Add your code here
	Process(Reset,Clock)
	begin	
 		if Reset = '1' then
			PCout <= X"003FFFFC"; -- start address
		elsif rising_edge(Clock) then 
			PCout <= PCin; -- holds address
		end if;
	end process; 
end executive;
--------------------------------------------------------------------------------
