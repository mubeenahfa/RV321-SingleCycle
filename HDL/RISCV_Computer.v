module RISCV_Computer (
input clk, reset,
input [4:0] debug_reg_select,
output [31:0] debug_reg_out, PC, Result,SrcA_out,SrcB_out,Instruction,RD2_out,ALUResult_out
);

wire  JALR_wire, AUIPC_wire,ALUSrc_wire, PCSrc_wire, MemWrite_wire, RegWrite_wire;

wire [2:0] ImmSrc_wire;
wire [3:0] ALUControl_wire;
wire [2:0] Size_wire;
wire [1:0] ResultSrc_wire;
wire [2:0] Funct3_wire;
wire [6:0] Op_wire;
wire Funct7_wire,Z_wire, IQF_wire;



Datapath my_datapath (
		.clk(clk), 
		.reset(reset),
		
		.JALR(JALR_wire),
		.Size(Size_wire),
		.AUIPC(AUIPC_wire),
		.PCSrc(PCSrc_wire),
		.ResultSrc(ResultSrc_wire),
		
		.MemWrite(MemWrite_wire), 
		.ALUControl(ALUControl_wire),
		.ALUSrc(ALUSrc_wire),
		.ImmSrc(ImmSrc_wire),
		.RegWrite(RegWrite_wire),

		.Op(Op_wire),
		.Funct3(Funct3_wire),
		.Funct7(Funct7_wire),
		.Z(Z_wire),
		.IQF(IQF_wire),
		
		.Switches(debug_reg_select),
		.HEX_Debug(debug_reg_out),
		
		.PC_Out(PC),
		.Result(Result),
		.SrcA_out(SrcA_out),
		.SrcB_out(SrcB_out),
		.inst(Instruction),
		.RD2_out(RD2_out),
		.ALUResult_out(ALUResult_out)
		);

Control_Unit my_controller 
(		.clk(clk),
		.Op(Op_wire),
		.Funct3(Funct3_wire),
		.Funct7(Funct7_wire),
		.Zero(Z_wire),
		.IQF(IQF_wire),
		
		.JALR(JALR_wire), 
		.AUIPC(AUIPC_wire), 
		.PCSrc(PCSrc_wire),
		.MemWrite(MemWrite_wire),
		.ALUSrc(ALUSrc_wire),
		.RegWrite(RegWrite_wire),
		
		.Size(Size_wire),
		.ALUControl(ALUControl_wire),
		.ImmSrc(ImmSrc_wire),
		.ResultSrc(ResultSrc_wire)
);

endmodule