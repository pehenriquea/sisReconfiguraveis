LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY alu_tp1 IS
	PORT (
		 a_in:   	IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 b_in:   	IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 c_in:   	IN STD_LOGIC;
		 op_sel: 	IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 bit_sel: 	IN STD_LOGIC_VECTOR(2 DOWNTO 0);

		 r_out:   	OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 c_out:   	OUT STD_LOGIC;
		 dc_out:   	OUT STD_LOGIC;
		 z_out:   	OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE arch OF alu_tp1 IS
	SIGNAL a_sign : 	STD_LOGIC_VECTOR(8 DOWNTO 0); 
	SIGNAL b_sign : 	STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL r_sign : 	STD_LOGIC_VECTOR(8 DOWNTO 0);
	
	SIGNAL bs_sign : 	STD_LOGIC_VECTOR(7 DOWNTO 0); 
	SIGNAL dc_sign : 	STD_LOGIC_VECTOR(4 DOWNTO 0); 
	SIGNAL z_sign : 	STD_LOGIC;
	                                                
	CONSTANT OP_XOR : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	CONSTANT OP_OR : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
	CONSTANT OP_AND : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
	CONSTANT OP_CLR : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
	CONSTANT OP_ADD : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
	CONSTANT OP_SUB : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
	CONSTANT OP_INC : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
	CONSTANT OP_DEC : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
	CONSTANT OP_PASS_A : 	STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
	CONSTANT OP_PASS_B : 	STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
	CONSTANT OP_COM : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
	CONSTANT OP_SWAP : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
	CONSTANT OP_BS : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
	CONSTANT OP_BC : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
	CONSTANT OP_RR : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
	CONSTANT OP_RL : 		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

BEGIN
	
	a_sign <= '0' & a_in; 
	b_sign <= '0' & b_in;
	
	WITH bit_sel SELECT 
		bs_sign <= 
			"00000001" WHEN "000", 
			"00000010" WHEN "001", 
			"00000100" WHEN "010", 
			"00001000" WHEN "011", 
			"00010000" WHEN "100", 
			"00100000" WHEN "101", 
			"01000000" WHEN "110",
			"10000000" WHEN "111"; 
			               
	dc_sign <= 
		('0' & a_sign(3 DOWNTO 0)) + ('0' & b_sign(3 DOWNTO 0)) WHEN op_sel = OP_ADD ELSE 
		('0' & a_sign(3 DOWNTO 0)) - ('0' & b_sign(3 DOWNTO 0)) WHEN op_sel = OP_SUB ELSE 
		"00000";
		
	WITH op_sel SELECT 
		r_sign <= 
			(a_sign XOR b_sign) 								WHEN OP_XOR,
			(a_sign OR b_sign) 									WHEN OP_OR,
			(a_sign AND b_sign) 								WHEN OP_AND,
			("000000000") 										WHEN OP_CLR,
			(a_sign + b_sign) 									WHEN OP_ADD,
			(a_sign - b_sign)									WHEN OP_SUB,
			(a_sign + 1)										WHEN OP_INC,
			(a_sign - 1)										WHEN OP_DEC,
			(a_sign)											WHEN OP_PASS_A,
			(b_sign)											WHEN OP_PASS_B,
			('0' & NOT a_in) 									WHEN OP_COM,
			('0' & a_sign(3 DOWNTO 0) & a_sign(7 DOWNTO 4)) 	WHEN OP_SWAP,
			('0' & bs_sign OR a_in)								WHEN OP_BS,
			('0' & (NOT bs_sign) AND a_in) 						WHEN OP_BC,
			(a_sign(0) & c_in & a_sign(7 DOWNTO 1)) 			WHEN OP_RR,
			(a_sign(7) & a_sign(6 DOWNTO 0) & c_in) 			WHEN OP_RL,
			("000000000")										WHEN OTHERS;
	
	r_out <= r_sign(7 DOWNTO 0); 
	
	c_out <= 
		NOT r_sign(8) WHEN op_sel = OP_SUB ELSE 
		r_sign(8); 
	 
	dc_out <= 
		dc_sign(4) WHEN op_sel = OP_ADD ELSE 
		NOT dc_sign(4) WHEN op_sel = OP_SUB ELSE 
		'0'; 
		
	WITH bit_sel SELECT 
		z_sign <= 
			a_in(0) WHEN "000", 
			a_in(1) WHEN "001", 
			a_in(2) WHEN "010", 
			a_in(3) WHEN "011", 
			a_in(4) WHEN "100", 
			a_in(5) WHEN "101", 
			a_in(6) WHEN "110", 
			a_in(7) WHEN "111";
			            
	z_out <= 
		z_sign WHEN op_sel = OP_BS OR op_sel = OP_BC ELSE 
		'1' WHEN r_sign(7 DOWNTO 0) = "00000000" ELSE 
		'0'; 
		
END arch;
