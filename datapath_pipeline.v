module datapath_pipeline(
    input clk, reset,
    // Señales de control desde controller (etapa ID)
    input [1:0] ResultSrc_D,
    input PCSrc_M, // PCSrc viene de etapa MEM
    input ALUSrc_D, RegWrite_D, Jump_D, Branch_D, MemWrite_D,
    input [1:0] ImmSrc_D,
    input [2:0] ALUControl_D,
    // Salidas
    output Zero_E,
    output [31:0] PC_F,
    input [31:0] Instr_F,
    output [31:0] ALUResult_M, WriteData_M,
    input [31:0] ReadData_M
);

  // ========== ETAPA IF (Instruction Fetch) ==========
  wire [31:0] PCNext_F, PCPlus4_F;
  wire [31:0] PCTarget_M; // Viene de etapa MEM
  
  flopr #(32) pcreg(
    .clk(clk), 
    .reset(reset), 
    .d(PCNext_F), 
    .q(PC_F)
  );
  
  adder pcadd4(
    .a(PC_F), 
    .b(32'd4), 
    .y(PCPlus4_F)
  );
  
  mux2 #(32) pcmux(
    .d0(PCPlus4_F), 
    .d1(PCTarget_M), 
    .s(PCSrc_M), 
    .y(PCNext_F)
  );

  // ========== Registro IF/ID ==========
  wire [31:0] PC_D, Instr_D;
  
  ifid_reg ifid(
    .clk(clk), 
    .reset(reset),
    .PC_F(PC_F), 
    .Instr_F(Instr_F),
    .PC_D(PC_D), 
    .Instr_D(Instr_D)
  );

  // ========== ETAPA ID (Instruction Decode) ==========
  wire [31:0] RD1_D, RD2_D, ImmExt_D;
  wire [31:0] Result_W; // Viene de etapa WB
  wire [4:0] Rd_W;
  wire RegWrite_W;
  
  regfile rf(
    .clk(clk), 
    .we3(RegWrite_W), 
    .a1(Instr_D[19:15]), 
    .a2(Instr_D[24:20]), 
    .a3(Rd_W), 
    .wd3(Result_W), 
    .rd1(RD1_D), 
    .rd2(RD2_D)
  );
  
  extend ext(
    .instr(Instr_D[31:7]), 
    .immsrc(ImmSrc_D), 
    .immext(ImmExt_D)
  );

  // ========== Registro ID/EX ==========
  wire [31:0] PC_E, RD1_E, RD2_E, ImmExt_E;
  wire [4:0] Rs1_E, Rs2_E, Rd_E;
  wire RegWrite_E, MemWrite_E, Jump_E, Branch_E, ALUSrc_E;
  wire [1:0] ResultSrc_E;
  wire [2:0] ALUControl_E;
  
  idex_reg idex(
    .clk(clk), 
    .reset(reset),
    .PC_D(PC_D), 
    .RD1_D(RD1_D), 
    .RD2_D(RD2_D), 
    .ImmExt_D(ImmExt_D),
    .Rs1_D(Instr_D[19:15]), 
    .Rs2_D(Instr_D[24:20]), 
    .Rd_D(Instr_D[11:7]),
    .RegWrite_D(RegWrite_D), 
    .MemWrite_D(MemWrite_D), 
    .Jump_D(Jump_D), 
    .Branch_D(Branch_D), 
    .ALUSrc_D(ALUSrc_D),
    .ResultSrc_D(ResultSrc_D),
    .ALUControl_D(ALUControl_D),
    .PC_E(PC_E), 
    .RD1_E(RD1_E), 
    .RD2_E(RD2_E), 
    .ImmExt_E(ImmExt_E),
    .Rs1_E(Rs1_E), 
    .Rs2_E(Rs2_E), 
    .Rd_E(Rd_E),
    .RegWrite_E(RegWrite_E), 
    .MemWrite_E(MemWrite_E), 
    .Jump_E(Jump_E), 
    .Branch_E(Branch_E), 
    .ALUSrc_E(ALUSrc_E),
    .ResultSrc_E(ResultSrc_E),
    .ALUControl_E(ALUControl_E)
  );

  // ========== ETAPA EX (Execute) ==========
  wire [31:0] SrcB_E, ALUResult_E, PCPlus4_E, PCTarget_E;
  wire PCSrc_E;
  
  mux2 #(32) srcbmux(
    .d0(RD2_E), 
    .d1(ImmExt_E), 
    .s(ALUSrc_E), 
    .y(SrcB_E)
  );
  
  alu alu(
    .a(RD1_E), 
    .b(SrcB_E), 
    .alucontrol(ALUControl_E), 
    .result(ALUResult_E), 
    .zero(Zero_E)
  );
  
  adder pcadd4_e(
    .a(PC_E), 
    .b(32'd4), 
    .y(PCPlus4_E)
  );
  
  adder pcaddbranch(
    .a(PC_E), 
    .b(ImmExt_E), 
    .y(PCTarget_E)
  );
  
  // Cálculo de PCSrc en etapa EX
  assign PCSrc_E = (Branch_E & Zero_E) | Jump_E;

  // ========== Registro EX/MEM ==========
  wire [4:0] Rd_M;
  wire RegWrite_M, MemWrite_M_internal;
  wire [1:0] ResultSrc_M;
  wire [31:0] PCPlus4_M;
  
  exmem_reg exmem(
    .clk(clk), 
    .reset(reset),
    .ALUResult_E(ALUResult_E), 
    .WriteData_E(RD2_E), 
    .PCPlus4_E(PCPlus4_E), 
    .PCTarget_E(PCTarget_E),
    .Rd_E(Rd_E),
    .RegWrite_E(RegWrite_E), 
    .MemWrite_E(MemWrite_E),
    .ResultSrc_E(ResultSrc_E),
    .PCSrc_E(PCSrc_E),
    .ALUResult_M(ALUResult_M), 
    .WriteData_M(WriteData_M), 
    .PCPlus4_M(PCPlus4_M), 
    .PCTarget_M(PCTarget_M),
    .Rd_M(Rd_M),
    .RegWrite_M(RegWrite_M), 
    .MemWrite_M(MemWrite_M_internal),
    .ResultSrc_M(ResultSrc_M),
    .PCSrc_M(PCSrc_M)
  );

  // ========== ETAPA MEM (Memory) - señales ya están en registros ==========
  // ReadData_M viene como input (desde dmem)

  // ========== Registro MEM/WB ==========
  wire [31:0] ALUResult_W, ReadData_W, PCPlus4_W;
  wire [1:0] ResultSrc_W;
  
  memwb_reg memwb(
    .clk(clk), 
    .reset(reset),
    .ALUResult_M(ALUResult_M), 
    .ReadData_M(ReadData_M), 
    .PCPlus4_M(PCPlus4_M),
    .Rd_M(Rd_M),
    .RegWrite_M(RegWrite_M),
    .ResultSrc_M(ResultSrc_M),
    .ALUResult_W(ALUResult_W), 
    .ReadData_W(ReadData_W), 
    .PCPlus4_W(PCPlus4_W),
    .Rd_W(Rd_W),
    .RegWrite_W(RegWrite_W),
    .ResultSrc_W(ResultSrc_W)
  );

  // ========== ETAPA WB (Write Back) ==========
  mux3 #(32) resultmux(
    .d0(ALUResult_W), 
    .d1(ReadData_W), 
    .d2(PCPlus4_W), 
    .s(ResultSrc_W), 
    .y(Result_W)
  );

endmodule
