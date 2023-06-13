LIBRARY ieee; USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

ENTITY controlunit IS
PORT (RX : OUT STD_LOGIC_VECTOR(0 TO 7);
		Ain, Gin, IRin, ADDRin, DOUTin, add_sub, INCR_in : OUT STD_LOGIC;
		z: IN STD_LOGIC;
		IR : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		S : OUT STD_LOGIC_VECTOR ( 3 DOWNTO 0);
		RESET, CLOCK : IN STD_LOGIC;
		DONE : BUFFER STD_LOGIC;
		W_D : OUT STD_LOGIC);
END ENTITY;	
	
ARCHITECTURE BEH OF controlunit IS
SIGNAL X: INTEGER;
SIGNAL I : STD_LOGIC_VECTOR(2 DOWNTO 0);

TYPE State_type IS (FETCH, T0, T1, T2, T3);
SIGNAL Tstep_Q, Tstep_D: State_type; -- Q ---> D

BEGIN
I <= IR( 8 DOWNTO 6);
X<=TO_INTEGER(UNSIGNED(IR(5 DOWNTO 3)));

statetable: PROCESS (Tstep_Q)
BEGIN
   CASE Tstep_Q IS
		WHEN FETCH =>
				Tstep_D <= T0;
				
      WHEN T0 => 
		
				Tstep_D <= T1;
			 -- data is loaded into IR in this time step
			
      WHEN T1 => 
			
			IF(DONE ='1') THEN
				Tstep_D <= FETCH;
			ELSE
				Tstep_D <= T2;
			END IF;
				
		WHEN T2 => 
			IF(DONE ='1') THEN
				Tstep_D <= FETCH;
			ELSE
				Tstep_D <= T3;
			END IF;
			
		WHEN T3 => 
			
			IF(DONE ='1') THEN
				Tstep_D <= FETCH;
			END IF;
		WHEN OTHERS => NULL;
   END CASE;
END PROCESS;

controlsignals: PROCESS (Tstep_Q, I, IR, X)
BEGIN
	RX <= (OTHERS => '0');
	IRin <='0';
	Ain <= '0';
	Gin <= '0';
	ADDRin <= '0';
	DOUTin <='0';
	W_D <='0';
	INCR_in <='0';
	DONE <='0';
	
	add_sub <= '0';
----- fix them
	
   CASE Tstep_Q IS
		WHEN FETCH =>
			  ADDRin <= '1';
			  S <= "0111";
			  	
      WHEN T0 => -- store DIN in IR as long as Tstep_Q = 0
           INCR_in <= '1';
			  IRin <= '1';
			  S <= "1001";
      WHEN T1 => -- define signals in time step T1
           CASE I IS
           WHEN "000" =>
					 S <= '0' & IR(2 DOWNTO 0);
					 DONE <= '1';
					 
					 RX(X) <= '1';
			  WHEN "001" =>
					 INCR_in <= '1';
					 ADDRin <= '1';
					 S <= "0111";					 
			  WHEN "010" =>
					 S <= '0' & IR(5 DOWNTO 3);
					 Ain <= '1';
			  WHEN "011" =>
					 S <= '0' & IR(5 DOWNTO 3);
					 Ain <= '1';
			  WHEN "100" =>
					 ADDRin <= '1';
					 S <= '0' & IR(2 DOWNTO 0);
			  WHEN "101" =>
					 ADDRin <= '1';
					 S <= '0' & IR(2 DOWNTO 0);
			  WHEN "110" =>
					 S <= "1000";
			  WHEN OTHERS => NULL;
           END CASE;
     WHEN T2 => -- define signals in time step T2
           CASE I IS
			  WHEN "001" =>
					 S <= "1001";
					 RX(X) <= '1';
					 DONE <='1';
           WHEN "010" =>
					 S <= '0' & IR( 2 DOWNTO 0);
					 Gin <='1';
				WHEN "011" =>
					 S <= '0' & IR( 2 DOWNTO 0);
					 Gin <='1';
					 add_sub <= '1';
				WHEN "100" =>
					 S <= "1001";
					 RX(X) <= '1';
					 DONE <='1';
				WHEN "101" =>
					 S <= '0' & IR(5 DOWNTO 3);
					 DOUTin <= '1';
				WHEN "110" =>
					 IF (z ='1') THEN
						  DONE <= '1';
					 END IF;	  
				WHEN OTHERS => NULL;
								 
           END CASE;
      WHEN T3 => -- define signals in time step T3
           CASE I IS
           WHEN "010" =>
					S <= "1000";
					
					RX(X) <= '1';
					DONE <= '1';
					
			  WHEN "011"=>
					S <= "1000";
					
					RX(X) <= '1';
					DONE <= '1';
			  WHEN "101" =>
					W_D <='1';
					DONE <='1';
			  WHEN "110" =>
					S <= '0' & IR( 2 DOWNTO 0);
					RX(X) <= '1';
					DONE <='1';
			  WHEN OTHERS => NULL;
           END CASE;
		WHEN OTHERS => NULL;
		
   END CASE;
END PROCESS;

fsmflipflops: PROCESS (CLOCK, RESET, Tstep_D)
BEGIN
	IF(RESET='1') THEN
		Tstep_Q <= T0;
	ELSIF rising_edge(CLOCK) THEN
		Tstep_Q <= Tstep_D;
	END IF;	
END PROCESS;
END ARCHITECTURE;