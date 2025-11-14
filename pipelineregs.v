// Registros de Pipeline para RISC-V Pipelined Processor

// Registro IF/ID - separa Instruction Fetch de Instruction Decode
module ifid_reg(input clk, reset,
                input [31:0] PC_F, Instr_F,
                output reg [31:0] PC_D, Instr_D);
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      PC_D <= 32'b0;
      Instr_D <= 32'b0;
    end else begin
      PC_D <= PC_F;
      Instr_D <= Instr_F;
    end
  end
endmodule

// Registro ID/EX - separa Instruction Decode de Execute
module idex_reg(input clk, reset,
                input [31:0] PC_D, RD1_D, RD2_D, ImmExt_D,
                input [4:0] Rs1_D, Rs2_D, Rd_D,
                input RegWrite_D, MemWrite_D, Jump_D, Branch_D, ALUSrc_D,
                input [1:0] ResultSrc_D,
                input [2:0] ALUControl_D,
                output reg [31:0] PC_E, RD1_E, RD2_E, ImmExt_E,
                output reg [4:0] Rs1_E, Rs2_E, Rd_E,
                output reg RegWrite_E, MemWrite_E, Jump_E, Branch_E, ALUSrc_E,
                output reg [1:0] ResultSrc_E,
                output reg [2:0] ALUControl_E);
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      PC_E <= 32'b0;
      RD1_E <= 32'b0;
      RD2_E <= 32'b0;
      ImmExt_E <= 32'b0;
      Rs1_E <= 5'b0;
      Rs2_E <= 5'b0;
      Rd_E <= 5'b0;
      RegWrite_E <= 1'b0;
      MemWrite_E <= 1'b0;
      Jump_E <= 1'b0;
      Branch_E <= 1'b0;
      ALUSrc_E <= 1'b0;
      ResultSrc_E <= 2'b0;
      ALUControl_E <= 3'b0;
    end else begin
      PC_E <= PC_D;
      RD1_E <= RD1_D;
      RD2_E <= RD2_D;
      ImmExt_E <= ImmExt_D;
      Rs1_E <= Rs1_D;
      Rs2_E <= Rs2_D;
      Rd_E <= Rd_D;
      RegWrite_E <= RegWrite_D;
      MemWrite_E <= MemWrite_D;
      Jump_E <= Jump_D;
      Branch_E <= Branch_D;
      ALUSrc_E <= ALUSrc_D;
      ResultSrc_E <= ResultSrc_D;
      ALUControl_E <= ALUControl_D;
    end
  end
endmodule

// Registro EX/MEM - separa Execute de Memory
module exmem_reg(input clk, reset,
                 input [31:0] ALUResult_E, WriteData_E, PCPlus4_E, PCTarget_E,
                 input [4:0] Rd_E,
                 input RegWrite_E, MemWrite_E, Zero_E,
                 input [1:0] ResultSrc_E,
                 input PCSrc_E,
                 output reg [31:0] ALUResult_M, WriteData_M, PCPlus4_M, PCTarget_M,
                 output reg [4:0] Rd_M,
                 output reg RegWrite_M, MemWrite_M,
                 output reg [1:0] ResultSrc_M,
                 output reg PCSrc_M);
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      ALUResult_M <= 32'b0;
      WriteData_M <= 32'b0;
      PCPlus4_M <= 32'b0;
      PCTarget_M <= 32'b0;
      Rd_M <= 5'b0;
      RegWrite_M <= 1'b0;
      MemWrite_M <= 1'b0;
      ResultSrc_M <= 2'b0;
      PCSrc_M <= 1'b0;
    end else begin
      ALUResult_M <= ALUResult_E;
      WriteData_M <= WriteData_E;
      PCPlus4_M <= PCPlus4_E;
      PCTarget_M <= PCTarget_E;
      Rd_M <= Rd_E;
      RegWrite_M <= RegWrite_E;
      MemWrite_M <= MemWrite_E;
      ResultSrc_M <= ResultSrc_E;
      PCSrc_M <= PCSrc_E;
    end
  end
endmodule

// Registro MEM/WB - separa Memory de Write Back
module memwb_reg(input clk, reset,
                 input [31:0] ALUResult_M, ReadData_M, PCPlus4_M,
                 input [4:0] Rd_M,
                 input RegWrite_M,
                 input [1:0] ResultSrc_M,
                 output reg [31:0] ALUResult_W, ReadData_W, PCPlus4_W,
                 output reg [4:0] Rd_W,
                 output reg RegWrite_W,
                 output reg [1:0] ResultSrc_W);
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      ALUResult_W <= 32'b0;
      ReadData_W <= 32'b0;
      PCPlus4_W <= 32'b0;
      Rd_W <= 5'b0;
      RegWrite_W <= 1'b0;
      ResultSrc_W <= 2'b0;
    end else begin
      ALUResult_W <= ALUResult_M;
      ReadData_W <= ReadData_M;
      PCPlus4_W <= PCPlus4_M;
      Rd_W <= Rd_M;
      RegWrite_W <= RegWrite_M;
      ResultSrc_W <= ResultSrc_M;
    end
  end
endmodule
