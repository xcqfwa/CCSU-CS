LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY fsm is 
    generic(N:integer:=50000; X:integer:=10 ; Y:integer:=100); -- pin21 100khz N for clk input freq
port(
	reset:in std_logic;-------------------------------复位reset 
	clk:in std_logic;--------------------------------100khz时钟信号
	clkcnt:out std_logic;--------------------------------1hz时钟信号
	clkfresh:out std_logic;--------------------------------10khz时钟信号
	test:out std_logic_vector(7 downto 0);--------------数码管显示的状态值
	mcode:out std_logic_vector(21 downto 0)--------------控制信号  
);
END fsm;


Architecture RTL of fsm is

TYPE State_type IS (A, B, C, D,E,F);  -- 定义状态
SIGNAL State : State_Type;    -- 创建信号 
SIGNAL stest: std_logic_vector(7 downto 0);--------------数码管显示的状态值
signal ctick,clk_state,clk_fresh:std_logic;
BEGIN 

-- 产生2hz clk 
PROCESS(clk) --产生1hz信号ctick
variable cnt1 : INTEGER RANGE 0 TO N -1; 
BEGIN 
	IF clk='1' AND clk'event THEN 
		IF cnt1=N -1 THEN 
			cnt1:=0; 
		ELSE 
			IF 	cnt1<N/2 THEN 
				ctick<='1'; 
			ELSE 
				ctick<='0';
			END IF; 
			cnt1:=cnt1+1; 
		END IF; 
	END IF; 
end process; 

PROCESS(ctick) --产生1hz信号clk_state
BEGIN 
	IF (reset ='0') THEN
       clk_state<='0';
	ELSIF ctick='1' AND ctick'event THEN 
		clk_state<=not clk_state; 
	END IF; 
end process; 


-- 产生10khz clk  clk_fresh
PROCESS(clk) --产生10Khz信号 
variable cnt1 : INTEGER RANGE 0 TO X -1; 
BEGIN 
	IF rising_edge(clk) THEN 
		IF cnt1=X -1 THEN 
			cnt1:=0; 
		ELSE 
			IF 	cnt1<X/2 THEN 
				clk_fresh<='1'; 
			ELSE 
				clk_fresh<='0'; 
			END IF; 
			cnt1:=cnt1+1; 
		END IF; 
	END IF; 
end process; 

  PROCESS (clk_state, reset) 
  BEGIN 
  --21sw-20r4-19r5-18alu-17pc|16r1-15r2-14r4-13r5-12ar|11m-10cn-9s38s27s16s0|5pcclr-4pcld-3pcen|2memen-1mw-0mr

    If (reset = '0') THEN            -- 复位reset，复位状态为A
		State <= A;
		mcode <="1111100000000000100100";--   什么都不做
		stest <="00000000";
    ELSIF rising_edge(clk_state) THEN    
		CASE State IS
			WHEN A => 
				mcode <="0111100000000000101100";--  k=>PC
				stest <="00000001";
				State <= B; 

			WHEN B => 
				mcode <="1111000001000000111100";--  pc=>AR pc+1=>pc
				stest <="00000010";
				State <= C; 
		
			WHEN C => 
				mcode <="1111101000000000100101";--  M[AR]=>dR2
				stest <="00000011";
				State <= D; 

			WHEN D => 
				mcode <="1111000001000000111100";--  pc=>AR pc+1=>pc
				stest <="00000100";
				State <= E; 
		
			WHEN E => 
				mcode <="1111110000000000100101";--  --  M[AR]=>dR1
				stest <="00000101";
				State <= F; 
			
			WHEN F=> 
				mcode <="1110100010000110100100";--  R1-R2
				stest <="00000110";
				State <= A; 
			
			WHEN others =>
				stest <="00000001";
				State <= A;
		END CASE; 
    END IF; 
    
END PROCESS;
test <=stest;
clkcnt <= ctick;
clkfresh<=clk_fresh;
END rtl;

 
