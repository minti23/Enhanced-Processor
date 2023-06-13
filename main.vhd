LIBRARY ieee; USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.ALL;

ENTITY main IS
PORT ( 
		 R0out, R1out, ADDRout, DATAOUT, IRout : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 Din : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		 LED: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		 DATAROM : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 RESETN: IN STD_LOGIC;
		 CLOCK : IN STD_LOGIC;
		 DONE : BUFFER STD_LOGIC;
		 BusWires : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0));
END main;

ARCHITECTURE Behavior OF main IS

	COMPONENT DFFp 
	PORT ( CLK: IN STD_LOGIC;
			 D: IN STD_LOGIC;
			 Q: OUT STD_LOGIC;
			 RESET: IN STD_LOGIC;
			 EN: IN STD_LOGIC);
	END COMPONENT;
	
	COMPONENT ninebitregis IS
	PORT ( D: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			 CLK: IN STD_LOGIC;
			 RESET: IN STD_LOGIC;
			 Q: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			 EN: IN STD_LOGIC);
	END COMPONENT;
	
	COMPONENT R7_REG IS
	PORT (
        clk, rst, en, incr : IN STD_LOGIC;
        D : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        Q : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0)
    );
	END COMPONENT;
	
	COMPONENT MUX 
	PORT ( S: IN STD_LOGIC_VECTOR ( 3 DOWNTO 0);
			 OUTMUX: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			 R0: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 R1: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 R2: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 R3: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 R4: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 R5: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 R6: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 R7: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 G: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 Din: IN STD_LOGIC_VECTOR ( 8 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT controlunit 
	PORT (RX : OUT STD_LOGIC_VECTOR(0 TO 7);
		Ain, Gin, IRin, ADDRin, DOUTin, add_sub, INCR_in: OUT STD_LOGIC;
		z: IN STD_LOGIC;
		IR : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		S : OUT STD_LOGIC_VECTOR ( 3 DOWNTO 0);
		RESET, CLOCK : IN STD_LOGIC;
		DONE : BUFFER STD_LOGIC;
		W_D : OUT STD_LOGIC);
	END COMPONENT;	
	COMPONENT AddSub IS
	PORT (
	 A, B : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
	 add_sub : IN STD_LOGIC;
	 C : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
			);
END COMPONENT;

	COMPONENT myROM 
		 GENERIC (
			  addr_width : INTEGER := 128; -- store 32 elements
			  addr_bits : INTEGER := 7; -- required bits to store 128 elements
			  data_width : INTEGER := 9 -- each element has 10-bits
		 );
		 PORT (
			  addr : IN STD_LOGIC_VECTOR(addr_bits - 1 DOWNTO 0);
			  dataOut : OUT STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0);
			  dataIn : IN STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0);
			  WE, clk : IN STD_LOGIC
		 );
	END COMPONENT;

	
SIGNAL add_sub: STD_LOGIC;
	
SIGNAL REGIN : STD_LOGIC_VECTOR(0 TO 7);
SIGNAL A, G, SUM, DOUT, LED_s : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL Ain, Gin, IRin, ADDRin, DOUTin, ENLED, RESET, INCR_in, W_D, WE: STD_LOGIC;
SIGNAL R0, R1, R2, R3, R4, R5, R6, R7, IR ,ADDR, DATA: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL z: STD_LOGIC;
SIGNAL S : STD_LOGIC_VECTOR(3 DOWNTO 0);

-------------------------------------------------------------------------------------
--SIGNAL R0out, R1out, ADDRout, DATAOUT, IRout : STD_LOGIC_VECTOR(8 DOWNTO 0);
--SIGNAL DATAROM : STD_LOGIC_VECTOR(8 DOWNTO 0);
--SIGNAL DONE : STD_LOGIC;
--SIGNAL BusWires : STD_LOGIC_VECTOR(8 DOWNTO 0);
--SIGNAL RESETN: STD_LOGIC;	
BEGIN
R0out <= R0;
R1out <= R1;
IRout <= IR;
ADDRout <= ADDR; 
DATAROM <= DATA;
DATAOUT <= DOUT;
RESET <= NOT(RESETN);
z <= '1' WHEN SIGNED(BusWires) = 0 ELSE '0';
LED <= '0' & LED_s;

WE <= '1' WHEN ADDR(8 DOWNTO 7) = "00" AND W_D = '1' ELSE '0';
ENLED <= '1' WHEN ADDR(8 DOWNTO 7) = "01" AND W_D = '1' ELSE '0';

i0AddSub : AddSub PORT MAP(A, BusWires, add_sub, SUM);

i0ninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, R0, REGIN(0));
i1ninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, R1, REGIN(1));
i2ninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, R2, REGIN(2));
i3ninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, R3, REGIN(3));
i4ninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, R4, REGIN(4));
i5ninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, R5, REGIN(5));
i6ninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, R6, REGIN(6));
i7R7_REG: R7_REG PORT MAP(CLOCK, RESET, REGIN(7), INCR_in, BusWires, R7);
Aninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, A, Ain);
Gninebitregis: ninebitregis PORT MAP(SUM, CLOCK, RESET, G, Gin);
IRninebitregis: ninebitregis PORT MAP(DATA, CLOCK, RESET, IR, IRin);
ADDRninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, ADDR, ADDRin);
DOUTninebitregis: ninebitregis PORT MAP(BusWires, CLOCK, RESET, DOUT, DOUTin); -- d,clk,reset,q,en

LEDninebitregis : ninebitregis PORT MAP(DOUT, CLOCK, RESET, LED_s, ENLED);

i0MUX: MUX PORT MAP(S,BusWires, R0, R1, R2, R3 ,R4, R5, R6 ,R7, G, DATA);

i0CTRLUNIT: controlunit PORT MAP(REGIN,Ain, Gin, IRin, ADDRin, DOUTin, add_sub, INCR_IN, z, IR,S,RESET,CLOCK,DONE,W_D);

i0myROM : myROM PORT MAP (ADDR(6 DOWNTO 0), DATA, DOUT, WE, CLOCK);

END Behavior;


--- data = din
