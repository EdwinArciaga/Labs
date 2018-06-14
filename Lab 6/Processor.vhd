library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
   	     Port( clk : in  STD_LOGIC;
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
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     ALUCtrl: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;


-- Program Counter Output

	signal Branch  : std_logic_vector(1 downto 0);
	signal MemRead : std_logic;
	signal MemtoReg: std_logic;
	signal ALUCtrl : std_logic_vector(4 downto 0);
	signal MemWrite: std_logic;
	signal ALUSrc  : std_logic;
	signal RegWrite: std_logic;
	signal ImmGen  : std_logic_vector(1 downto 0);

	signal mux_1: std_logic_vector(31 downto 0);
	signal mux_2: std_logic_vector(31 downto 0);
	signal mux_3: std_logic_vector(31 downto 0);

	signal PCo: std_logic_vector(31 downto 0);
	signal dout: std_logic_vector(31 downto 0);

	signal add_1: std_logic_vector(31 downto 0);
	signal add_2: std_logic_vector(31 downto 0);

	signal c1: std_logic;
	signal c2: std_logic;

	signal ReadData: std_logic_vector(31 downto 0);
	signal ReadData1: std_logic_vector(31 downto 0);
	signal ReadData2: std_logic_vector(31 downto 0);
	
	signal aluo: std_logic_vector(31 downto 0);
	signal none: std_logic;
	signal noteq: std_logic;
	
	signal immgeno   : std_logic_vector(31 downto 0);  
	signal touch : std_logic_vector(29 downto 0);
begin

	touch <= "0000"& aluo(27 downto 2);

	with none & Branch select
		noteq <= 		'0' when "-00",
					'0' when "001", 
					'1' when "101", 
					'1' when "010", 
					'0' when others; 
	
	with ImmGen & dout(31) select
	immgeno <=	"11111111111111111111" & dout(7) & dout(30 downto 25) & dout(11 downto 8) & '0' when "001", -- B type
                        "00000000000000000000" & dout(7) & dout(30 downto 25) & dout(11 downto 8) & '0' when "000", -- B type
			"1" & dout(30 downto 12) & "000000000000" when "111", -- U type
                        "0" & dout(30 downto 12) & "000000000000" when "110", -- U type
			"111111111111111111111" & dout(30 downto 20) when "011",  -- I type
                        "000000000000000000000" & dout(30 downto 20) when "010",  -- I type
		        "111111111111111111111" & dout(30 downto 25) & dout(11 downto 7) when "101",  -- S type
                        "000000000000000000000" & dout(30 downto 25) & dout(11 downto 7) when "100",  -- S type
            		"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" when others;

	imem: instructionRAM port map(reset, clock, PCo(31 downto 2), dout);

	mux1: BusMux2to1 port map(ALUSrc, ReadData2, immgeno, mux_1);
	mux2: BusMux2to1  port map(MemtoReg, aluo, ReadData, mux_2);
	mux3: BusMux2to1   port map(noteq, add_1, add_2, mux_3);
	
	add1: adder_subtracter port map(PCo, "00000000000000000000000000000100", '0', add_1, c1);
	add2: adder_subtracter port map(PCo, immgeno, '0', add_2, c2); 
	
	counter: ProgramCounter port map(reset, clock, mux_3, PCo);
	
	alur: ALU port map(ReadData1, mux_1, aluctrl, none, aluo);

	Cntrl: Control port map(clock, dout(6 downto 0), dout(14 downto 12), dout(31 downto 25), Branch, MemRead, MemtoReg, ALUCtrl,MemWrite,ALUSrc, RegWrite, ImmGen);

	reg1: Registers port map(dout(19 downto 15), dout(24 downto 20), dout(11 downto 7), mux_2, RegWrite, ReadData1, ReadData2);

	DMem: RAM port map(reset, clock, MemRead, MemWrite, touch, ReadData2, ReadData);
 
end holistic;

