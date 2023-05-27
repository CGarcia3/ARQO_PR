--------------------------------------------------------------------------------
-- Procesador RISC V uniciclo curso Arquitectura Ordenadores 2022
-- Initial Release G.Sutter jun 2022
-- 
-- Carlos Garcia Toledano
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.RISCV_pack.ALL;

ENTITY processorRV IS
  PORT (
    Clk : IN STD_LOGIC; -- Reloj activo en flanco subida
    Reset : IN STD_LOGIC; -- Reset asincrono activo nivel alto
    -- Instruction memory
    IAddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Direccion Instr
    IDataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Instruccion leida
    -- Data memory
    DAddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Direccion
    DRdEn : OUT STD_LOGIC; -- Habilitacion lectura
    DWrEn : OUT STD_LOGIC; -- Habilitacion escritura
    DDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato escrito
    DDataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0) -- Dato leido
  );
END processorRV;

ARCHITECTURE rtl OF processorRV IS

  COMPONENT alu_RV
    PORT (
      OpA : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- Operando A
      OpB : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- Operando B
      Control : IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- Codigo de control=op. a ejecutar
      Result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); -- Resultado
      SignFlag : OUT STD_LOGIC; -- Sign Flag
      carryOut : OUT STD_LOGIC; -- Carry bit
      ZFlag : OUT STD_LOGIC -- Flag Z
    );
  END COMPONENT;

  COMPONENT reg_bank
    PORT (
      Clk : IN STD_LOGIC; -- Reloj activo en flanco de subida
      Reset : IN STD_LOGIC; -- Reset as�ncrono a nivel alto
      A1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Direcci�n para el puerto Rd1
      Rd1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato del puerto Rd1
      A2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Direcci�n para el puerto Rd2
      Rd2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato del puerto Rd2
      A3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Direcci�n para el puerto Wd3
      Wd3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dato de entrada Wd3
      We3 : IN STD_LOGIC -- Habilitaci�n de la escritura de Wd3
    );
  END COMPONENT reg_bank;

  COMPONENT control_unit
    PORT (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
      -- Seniales para el PC
      Branch : OUT STD_LOGIC; -- 1 = Ejecutandose instruccion branch
      -- Seniales relativas a la memoria
      ResultSrc : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00 salida Alu; 01 = salida de la mem.; 10 PC_plus4
      MemWrite : OUT STD_LOGIC; -- Escribir la memoria
      MemRead : OUT STD_LOGIC; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : OUT STD_LOGIC; -- 0 = oper.B es registro, 1 = es valor inm.
      AuipcLui : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- 0 = PC. 1 = zeros, 2 = reg1.
      ALUOp : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- Tipo operacion para control de la ALU
      -- señal generacion salto
      Ins_jalr : OUT STD_LOGIC; -- 0=any instrucion, 1=jalr
      -- Seniales para el GPR
      RegWrite : OUT STD_LOGIC -- 1 = Escribir registro
    );
  END COMPONENT;

  COMPONENT alu_control IS
    PORT (
      -- Entradas:
      ALUOp : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- Codigo de control desde la unidad de control
      Funct3 : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- Campo "funct3" de la instruccion (I(14:12))
      Funct7 : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- Campo "funct7" de la instruccion (I(31:25))     
      -- Salida de control para la ALU:
      ALUControl : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) -- Define operacion a ejecutar por la ALU
    );
  END COMPONENT alu_control;

  COMPONENT Imm_Gen IS
    PORT (
      instr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      imm : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT Imm_Gen;

  SIGNAL Alu_Op1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Alu_Op2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Alu_ZERO : STD_LOGIC;
  SIGNAL Alu_SIGN : STD_LOGIC;
  SIGNAL AluControl : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL reg_RD_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL branch_true : STD_LOGIC;
  SIGNAL PC_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL PC_plus4 : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL Instruction : STD_LOGIC_VECTOR(31 DOWNTO 0); -- La instrucción desde lamem de instr
  SIGNAL Inm_ext : STD_LOGIC_VECTOR(31 DOWNTO 0); -- La parte baja de la instrucción extendida de signo
  SIGNAL reg_RS, reg_RT : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL dataIn_Mem : STD_LOGIC_VECTOR(31 DOWNTO 0); -- From Data Memory
  SIGNAL Addr_Branch : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL Ctrl_Jalr, Ctrl_Branch, Ctrl_MemWrite, Ctrl_MemRead, Ctrl_ALUSrc, Ctrl_RegWrite : STD_LOGIC;

  --Ctrl_RegDest,
  SIGNAL Ctrl_ALUOP : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL Ctrl_PcLui : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL Ctrl_ResSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);

  SIGNAL Addr_jalr : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL Addr_Jump_dest : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL desition_Jump : STD_LOGIC;
  SIGNAL Alu_Res : STD_LOGIC_VECTOR(31 DOWNTO 0);
  -- Instruction filds
  SIGNAL Funct3 : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL Funct7 : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL RS1, RS2, RD : STD_LOGIC_VECTOR(4 DOWNTO 0);

  --IF/ID
    signal pc_plus4_IF: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal pc_reg_IF: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal instruction_IF: STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal pc_plus4_ID: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal pc_reg_ID: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal instruction_ID: STD_LOGIC_VECTOR(31 DOWNTO 0);

  --ID/EX 
    signal ctrl_jalr_ID: STD_LOGIC;
    signal ctrl_branch_ID: STD_LOGIC;
    signal ctrl_ResSrc_ID: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal ctrl_MemRead_ID: STD_LOGIC;
    signal ctrl_MemWrite_ID: STD_LOGIC;
    signal ctrl_AluOP_ID: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal ctrl_PcLui_ID: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal ctrl_AluSrc_ID: STD_LOGIC;
    signal ctrl_RegWrite_ID: STD_LOGIC;
    signal reg_rd1_ID: STD_LOGIC_VECTOR(31 downto 0);
    signal reg_rd2_ID: STD_LOGIC_VECTOR(31 downto 0);
    signal reg_a3_ID: STD_LOGIC_VECTOR(4 downto 0); 
    signal inm_ext_ID: STD_LOGIC_VECTOR(31 downto 0);
    signal funct3_ID: STD_LOGIC_VECTOR(2 downto 0); 
    signal funct7_ID: STD_LOGIC_VECTOR(6 downto 0); 

    signal ctrl_jalr_EX: STD_LOGIC;
    signal ctrl_branch_EX: STD_LOGIC;
    signal ctrl_ResSrc_EX: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal ctrl_MemRead_EX: STD_LOGIC;
    signal ctrl_MemWrite_EX: STD_LOGIC;
    signal ctrl_AluOP_EX: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal ctrl_PcLui_EX: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal ctrl_AluSrc_EX: STD_LOGIC;
    signal ctrl_RegWrite_EX: STD_LOGIC;
    signal reg_rd1_EX: STD_LOGIC_VECTOR(31 downto 0);
    signal reg_rd2_EX: STD_LOGIC_VECTOR(31 downto 0);
    signal reg_a3_EX: STD_LOGIC_VECTOR(4 downto 0); 
    signal inm_ext_EX: STD_LOGIC_VECTOR(31 downto 0);
    signal funct3_EX: STD_LOGIC_VECTOR(2 downto 0); 
    signal funct7_EX: STD_LOGIC_VECTOR(6 downto 0); 

    signal pc_plus4_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal pc_reg_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);

  --EX/MEM
    --A3, rd2, AluRes, PcPlus4, CTRL varios, PcReg depende de donde este el mux
    signal addr_jump_dest_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal desition_jump_EX: STD_LOGIC;
    signal alu_res_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal addr_jump_dest_MEM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal desition_jump_MEM: STD_LOGIC;
    signal pc_plus4_MEM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ctrl_ResSrc_MEM: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal ctrl_MemRead_MEM: STD_LOGIC;
    signal ctrl_MemWrite_MEM: STD_LOGIC;
    signal ctrl_RegWrite_MEM: STD_LOGIC;
    signal alu_res_MEM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal reg_rd2_MEM: STD_LOGIC_VECTOR(31 downto 0);
    signal reg_a3_MEM: STD_LOGIC_VECTOR(4 downto 0); 
    
  --MEM_WB
    signal mem_rd_data_MEM: STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal pc_plus4_WB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ctrl_ResSrc_WB: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal ctrl_RegWrite_WB: STD_LOGIC;
    signal mem_rd_data_WB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal alu_res_WB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal reg_a3_WB: STD_LOGIC_VECTOR(4 downto 0); 

  --Forwarding
    signal forward_A: STD_LOGIC_VECTOR(1 downto 0);
    signal forward_B: STD_LOGIC_VECTOR(1 downto 0);

    signal reg_a1_EX: STD_LOGIC_VECTOR(4 downto 0);
    signal reg_a2_EX: STD_LOGIC_VECTOR(4 downto 0);

    signal forward_A_mux: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal forward_B_mux: STD_LOGIC_VECTOR(31 DOWNTO 0);

  --Load hazard
    signal hazard_ld: STD_LOGIC;


BEGIN

  PC_next <= addr_Jump_dest_MEM WHEN desition_jump_MEM = '1' ELSE PC_plus4;
  -- Program Counter
  PC_reg_proc : PROCESS (Clk, Reset, hazard_ld)
  BEGIN
    IF Reset = '1' THEN
      PC_reg <= (22 => '1', OTHERS => '0'); -- 0040_0000
    ELSIF rising_edge(Clk) and hazard_ld = '0' THEN
      PC_reg <= PC_next;
    END IF;
  END PROCESS;
  

  PC_plus4 <= PC_reg + 4;
  IAddr <= PC_reg;
  --Instruction <= IDataIn;

  pc_plus4_IF <= PC_plus4;
  pc_reg_IF <= PC_reg;
  instruction_IF <= IDataIn;

  ----------------------------------------
  ----------------IF/ID-------------------
  ----------------------------------------
  IF_ID : process (Clk, Reset, hazard_ld)
	begin
		if Reset = '1' then
			instruction_ID 	<= (others => '0');
			pc_plus4_ID		<= (others => '0');
			pc_reg_ID   <= (others => '0');
		elsif rising_edge(Clk) and hazard_ld = '0' then
			-- IF/ID
			instruction_ID 	<= instruction_IF;
			pc_plus4_ID		<= pc_plus4_IF;
			pc_reg_ID   <= pc_reg_IF;
		end if;
	end process;


  --Funct3 <= instruction(14 DOWNTO 12); -- Campo "funct3" de la instruccion
  --Funct7 <= instruction(31 DOWNTO 25); -- Campo "funct7" de la instruccion
  --RD <= Instruction(11 DOWNTO 7);
  --RS1 <= Instruction(19 DOWNTO 15);
  --RS2 <= Instruction(24 DOWNTO 20);

  funct3_ID <= instruction_ID(14 DOWNTO 12); -- Campo "funct3" de la instruccion
  Funct7_ID <= instruction_ID(31 DOWNTO 25); -- Campo "funct7" de la instruccion
  reg_a3_ID <= instruction_ID(11 DOWNTO 7);
  RS1 <= instruction_ID(19 DOWNTO 15);
  RS2 <= instruction_ID(24 DOWNTO 20);


  RegsRISCV : reg_bank
  PORT MAP(
    Clk => Clk,
    Reset => Reset,
    A1 => RS1, --Instruction(19 downto 15), --rs1
    Rd1 => reg_rd1_ID,
    A2 => RS2, --Instruction(24 downto 20), --rs2
    Rd2 => reg_rd2_ID,
    A3 => reg_a3_WB, --Instruction(11 downto 7),,
    Wd3 => reg_RD_data, --------------------CHECK----------------------------------CHECK-----------CHECK-----------CHECK-----------CHECK------------------------------
    We3 => ctrl_RegWrite_WB
  );

  UnidadControl : control_unit
  PORT MAP(
    OpCode => instruction_ID(6 DOWNTO 0),
    -- Señales para el PC
    --Jump   => CONTROL_JUMP,
    Branch => ctrl_branch_ID,
    -- Señales para la memoria
    ResultSrc => ctrl_ResSrc_ID,
    MemWrite => ctrl_MemWrite_ID,
    MemRead => ctrl_MemRead_ID,
    -- Señales para la ALU
    ALUSrc => ctrl_ALUSrc_ID,
    AuipcLui => ctrl_PcLui_ID,
    ALUOP => ctrl_AluOP_ID,
    -- señal generacion salto
    Ins_jalr => ctrl_jalr_ID, -- 0=any instrucion, 1=jalr
    -- Señales para el GPR
    RegWrite => ctrl_RegWrite_ID
  );

  inmed_op : Imm_Gen
  PORT MAP(
    instr => instruction_ID,
    imm => inm_ext_ID
  );


  ----------------------------------------
  ----------------ID/EX-------------------
  ----------------------------------------
  ID_EX : process (Clk, Reset, hazard_ld) -----------CHECK-----HAZARD-----------------------------------------------------------------------------------
	begin
		if Reset = '1' then
      ctrl_jalr_EX	<= '0';
      ctrl_branch_EX	<= '0';
      ctrl_ResSrc_EX 	<= (others => '0');
      ctrl_MemRead_EX	<= '0';
      ctrl_MemWrite_EX	<= '0';
      ctrl_AluOP_EX 	<= (others => '0');
      ctrl_PcLui_EX 	<= (others => '0');
      ctrl_AluSrc_EX	<= '0';
      ctrl_RegWrite_EX	<= '0';
      reg_rd1_EX 	<= (others => '0');
      reg_rd2_EX 	<= (others => '0');
      reg_a3_EX 	<= (others => '0');
      inm_ext_EX 	<= (others => '0');
      funct3_EX 	<= (others => '0');
      funct7_EX 	<= (others => '0');

      pc_plus4_EX	<= (others => '0');
      pc_reg_EX	<= (others => '0');

		elsif rising_edge(Clk) then
      if hazard_ld = '1' then
        ctrl_RegWrite_EX	<= '0';
        reg_a3_EX 	<= (others => '0');

      elsif hazard_ld = '0' then
        ctrl_jalr_EX	<= ctrl_jalr_ID;
        ctrl_branch_EX	<= ctrl_branch_ID;
        ctrl_ResSrc_EX 	<= ctrl_ResSrc_ID;
        ctrl_MemRead_EX	<= ctrl_MemRead_ID;
        ctrl_MemWrite_EX	<= ctrl_MemWrite_ID;
        ctrl_AluOP_EX 	<= ctrl_AluOP_ID;
        ctrl_PcLui_EX 	<= ctrl_PcLui_ID;
        ctrl_AluSrc_EX	<= ctrl_AluSrc_ID;
        ctrl_RegWrite_EX	<= ctrl_RegWrite_ID;
        reg_rd1_EX 	<= reg_rd1_ID;
        reg_rd2_EX 	<= reg_rd2_ID;
        reg_a3_EX 	<= reg_a3_ID;
        inm_ext_EX 	<= inm_ext_ID;
        funct3_EX 	<= funct3_ID;
        funct7_EX 	<= funct7_ID;

        pc_plus4_EX	<= pc_plus4_ID;
        pc_reg_EX	<= pc_reg_ID;

        reg_a1_EX <= instruction_ID(19 DOWNTO 15);
        reg_a2_EX <= instruction_ID(24 DOWNTO 20);
        end if;
		end if;
	end process;


  Alu_control_i : alu_control
  PORT MAP(
    -- Entradas:
    ALUOp => ctrl_AluOP_EX, -- Codigo de control desde la unidad de control
    Funct3 => funct3_EX, -- Campo "funct3" de la instruccion
    Funct7 => funct7_EX, -- Campo "funct7" de la instruccion
    -- Salida de control para la ALU:
    ALUControl => AluControl -- Define operacion a ejecutar por la ALU
  );

  Alu_RISCV : alu_RV
  PORT MAP(
    OpA => Alu_Op1,
    OpB => Alu_Op2,
    Control => AluControl,
    Result => alu_res_EX,
    Signflag => Alu_SIGN,
    carryOut => OPEN,
    Zflag => Alu_ZERO
  );


  Addr_Branch <= pc_reg_EX + inm_ext_EX;
  Addr_jalr <= reg_rd1_EX + inm_ext_EX;

  branch_true <= '1' WHEN (((funct3_EX = BR_F3_BEQ) AND (Alu_ZERO = '1')) OR
    ((funct3_EX = BR_F3_BNE) AND (Alu_ZERO = '0')) OR
    ((funct3_EX = BR_F3_BLT) AND (Alu_SIGN = '1')) OR
    ((funct3_EX = BR_F3_BGT) AND (Alu_SIGN = '0'))) ELSE
    '0';

  desition_jump_EX <= ctrl_jalr_EX OR (ctrl_branch_EX AND branch_true);

  addr_jump_dest_EX <= Addr_jalr WHEN ctrl_jalr_EX = '1' ELSE
    Addr_Branch WHEN ctrl_branch_EX = '1' ELSE
    (OTHERS => '0');


  Alu_Op1 <= pc_reg_EX WHEN ctrl_PcLui_EX = "00" ELSE -------------------------------------FORWARDING------------------------------------------------------------
    (OTHERS => '0') WHEN ctrl_PcLui_EX = "01" ELSE
    forward_A_mux; -- any other 

  Alu_Op2 <= forward_B_mux WHEN ctrl_AluSrc_EX = '0' ELSE
    inm_ext_EX;


  ----------------------------------------
  ----------------EX/MEM-------------------
  ----------------------------------------
  EX_MEM : process (Clk, Reset)
	begin
		if Reset = '1' then
      addr_jump_dest_MEM 	<= (others => '0');
      desition_jump_MEM	<= '0';
      pc_plus4_MEM 	<= (others => '0');
      ctrl_ResSrc_MEM 	<= (others => '0');
      ctrl_MemRead_MEM 	<= '0';
      ctrl_MemWrite_MEM	<= '0';
      ctrl_RegWrite_MEM	<= '0';
      alu_res_MEM 	<= (others => '0');
      reg_rd2_MEM 	<= (others => '0');
      reg_a3_MEM 	<= (others => '0');

		elsif rising_edge(Clk) then
      addr_jump_dest_MEM 	<= addr_jump_dest_EX;
      desition_jump_MEM	<= desition_jump_EX;
      pc_plus4_MEM 	<= pc_plus4_EX;
      ctrl_ResSrc_MEM 	<= ctrl_ResSrc_EX;
      ctrl_MemRead_MEM 	<= ctrl_MemRead_EX;
      ctrl_MemWrite_MEM	<= ctrl_MemWrite_EX;
      ctrl_RegWrite_MEM	<= ctrl_RegWrite_EX;
      alu_res_MEM 	<= alu_res_EX;
      reg_rd2_MEM 	<= reg_rd2_EX;
      reg_a3_MEM 	<= reg_a3_EX;
		end if;
	end process;



  DAddr <= alu_res_MEM;
  DDataOut <= reg_rd2_MEM;
  DWrEn <= ctrl_MemWrite_MEM;
  dRdEn <= ctrl_MemRead_MEM;
  mem_rd_data_MEM <= DDataIn;


  ----------------------------------------
  ----------------MEM/WB-------------------
  ----------------------------------------
  MEM_WB : process (Clk, Reset)
	begin
		if Reset = '1' then
      pc_plus4_WB 	<= (others => '0');
      ctrl_ResSrc_WB 	<= (others => '0');
      ctrl_RegWrite_WB 	<= '0';
      mem_rd_data_WB 	<= (others => '0');
      alu_res_WB 	<= (others => '0');
      reg_a3_WB 	<= (others => '0');

		elsif rising_edge(Clk) then
      pc_plus4_WB 	<= pc_plus4_MEM;
      ctrl_ResSrc_WB 	<= ctrl_ResSrc_MEM;
      ctrl_RegWrite_WB 	<= ctrl_RegWrite_MEM;
      mem_rd_data_WB 	<= mem_rd_data_MEM;
      alu_res_WB 	<= alu_res_MEM;
      reg_a3_WB 	<= reg_a3_MEM;
		end if;
	end process; 


  reg_RD_data <= mem_rd_data_WB WHEN ctrl_ResSrc_WB = "01" ELSE
    pc_plus4_WB WHEN ctrl_ResSrc_WB = "10" ELSE
    alu_res_WB; -- When 00


  ----------------------------------------
  -------------FORWARDING ALU-------------
  ----------------------------------------
  forward_A <= "10" when (ctrl_RegWrite_MEM = '1' and (reg_a3_MEM /= 0) and (reg_a3_MEM = reg_a1_EX)) else -- Ex hazard
              "01" when (ctrl_RegWrite_WB = '1' and (reg_a3_WB /= 0) and not (ctrl_RegWrite_MEM = '1' 
                                                                              and (reg_a3_MEM /= 0) 
                                                                              and (reg_a3_MEM = reg_a1_EX)) 
                                                and (reg_a3_WB = reg_a1_EX)) else  -- Mem hazard
              "00";

  forward_B <= "10" when (ctrl_RegWrite_MEM = '1' and (reg_a3_MEM /= 0) and (reg_a3_MEM = reg_a2_EX)) else -- Ex hazard
              "01" when (ctrl_RegWrite_WB = '1' and (reg_a3_WB /= 0) and not (ctrl_RegWrite_MEM = '1' 
                                                                              and (reg_a3_MEM /= 0) 
                                                                              and (reg_a3_MEM = reg_a2_EX)) 
                                                and (reg_a3_WB = reg_a2_EX)) else  -- Mem hazard
              "00";

  forward_A_mux <= reg_rd1_EX when forward_A = "00" else
                  alu_res_MEM when forward_A = "10" else
                  reg_RD_data when forward_A = "01";

  forward_B_mux <= reg_rd2_EX when forward_B = "00" else
                  alu_res_MEM when forward_B = "10" else
                  reg_RD_data when forward_B = "01";

  ----------------------------------------
  ---------------LOAD HAZARD--------------
  ----------------------------------------
  hazard_ld <= '1' when (ctrl_MemRead_EX = '1') and ((reg_a3_EX = instruction_ID(19 DOWNTO 15)) or (reg_a3_EX = instruction_ID(24 DOWNTO 20))) else
                '0';
 


END ARCHITECTURE;