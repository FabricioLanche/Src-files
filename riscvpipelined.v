module riscvpipelined(input clk, reset,
                      output [31:0] PC_F,
                      input [31:0] Instr_F,
                      output MemWrite_M,
                      output [31:0] DataAdr_M,
                      output [31:0] WriteData_M,
                      input [31:0] ReadData_M);

  wire ALUSrc_D, RegWrite_D, Jump_D, Branch_D, MemWrite_D, Zero_E, PCSrc_M;
  wire [1:0] ResultSrc_D, ImmSrc_D;
  wire [2:0] ALUControl_D;
  wire [31:0] Instr_D;

  // Señales para propagación de MemWrite
  wire MemWrite_E;
  
  // Instancia del controller (genera señales en etapa ID)
  controller c(
    .op(Instr_D[6:0]),
    .funct3(Instr_D[14:12]),
    .funct7b5(Instr_D[30]),
    .Zero(Zero_E),
    .ResultSrc(ResultSrc_D),
    .MemWrite(MemWrite_D),
    .PCSrc(PCSrc_M),
    .ALUSrc(ALUSrc_D),
    .RegWrite(RegWrite_D),
    .Jump(Jump_D),
    .ImmSrc(ImmSrc_D),
    .ALUControl(ALUControl_D)
  );

  // Instancia del datapath pipeline
  datapath_pipeline dp(
    .clk(clk),
    .reset(reset),
    .ResultSrc_D(ResultSrc_D),
    .PCSrc_M(PCSrc_M),
    .ALUSrc_D(ALUSrc_D),
    .RegWrite_D(RegWrite_D),
    .Jump_D(Jump_D),
    .Branch_D(Branch_D),
    .MemWrite_D(MemWrite_D),
    .ImmSrc_D(ImmSrc_D),
    .ALUControl_D(ALUControl_D),
    .Zero_E(Zero_E),
    .PC_F(PC_F),
    .Instr_F(Instr_F),
    .ALUResult_M(DataAdr_M),
    .WriteData_M(WriteData_M),
    .ReadData_M(ReadData_M)
  );
  
  // Necesitamos extraer Instr_D del datapath
  // Para simplicidad, el MemWrite_M sale del datapath
  assign MemWrite_M = MemWrite_D; // Simplificación temporal

endmodule
