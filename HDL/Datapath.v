// Datapath.v
module Datapath(
    input clk, 
	 input reset,
	 
	 input JALR,
	 input [2:0] Size,
	 input AUIPC,
	 input PCSrc,
	 input [1:0] ResultSrc,
	 input MemWrite,
	 input [3:0] ALUControl,
	 input ALUSrc,
	 input [2:0] ImmSrc,
	 input RegWrite,
	 
	 
	 output [6:0] Op,
	 output [2:0] Funct3,
	 output Funct7,
	 output Z,
	 output IQF,
	 
	 input [4:0] Switches,
	 output [31:0] HEX_Debug,
	 output [31:0] PC_Out,
	 output [31:0] Result,
	 output [31:0] SrcA_out, 
	 output [31:0] SrcB_out,
	 output [31:0] inst,
	 output [31:0] RD2_out,
	 output [31:0] ALUResult_out
	 
);
assign inst=Instr;

wire [31:0] Instr;
wire [31:0] PCPlus4; 
wire [31:0] PCTarget;

wire [31:0] PCNext;

wire [31:0] WriteData;
wire [31:0] mux1_out;
wire [4:0] A1;
wire [4:0] A2;
wire [4:0] A3;
wire [31:0] WD3;
wire [31:0] RD1;
wire [31:0] RD2;

wire [31:0] ImmExt;
wire [31:0] SrcA;
wire [31:0] SrcB;

wire [31:0] ReadData;
wire [31:0] ALUResult;

wire [31:0] Const_Four;

wire [31:0] PC_Current;









Mux_2to1 #(32) MUX1 
	(
        .input_0(PCPlus4),
        .input_1(PCTarget),
        .select(PCSrc),
        .output_value(mux1_out)
    );
Mux_2to1 #(32) MUX2 
	(
        .input_0(mux1_out),
        .input_1(ALUResult),
        .select(JALR),
        .output_value(PCNext)
    );
	
Register_reset #(32) PC 
(
	.clk(clk),
	.reset(reset),
	.DATA(PCNext),
	.OUT(PC_Current)
);

Inst_Memory  #(4,32) My_memory 
(
	.ADDR(PC_Current),
	.RD(Instr)
);

Adder  #(32) My_Adder1 
(
		.DATA_A(PC_Current),
		.DATA_B(Const_Four),
		.OUT(PCPlus4)
);

Register_file  #(32) My_RegisterFile 

(
		.clk(clk), 
		.write_enable(RegWrite), 
		.reset(reset),
		.Source_select_0(A1), 
		.Source_select_1(A2), 
		.Debug_Source_select(Switches), 
		.Destination_select(A3),
		.DATA(WD3), 
		.out_0(RD1), 
		.out_1(RD2), 
		.Debug_out(HEX_Debug)
);

Extender My_Extender 
		(
			.Extended_data(ImmExt),
			.DATA(Instr [31:7]),
			.select(ImmSrc)
		);
	
Mux_2to1 #(32) MUX3 
	(
        .input_0(RD1),
        .input_1(PC_Current),
        .select(AUIPC),
        .output_value(SrcA)
    );
Mux_2to1 #(32) MUX4
	(
        .input_0(RD2),
        .input_1(ImmExt),
        .select(ALUSrc),
        .output_value(SrcB)
    );
ALU #(32) My_ALU 
	(
		.control(ALUControl),
		.DATA_A(SrcA),
		.DATA_B(SrcB),
		.OUT(ALUResult),
		.Z(Z),
		.IQF(IQF)
	);

Adder  #(32) My_Adder2 
(
		.DATA_A(PCPlus4),
		.DATA_B(ImmExt),
		.OUT(PCTarget)
);

Memory #(4,32) Data_Memory 
	(
			.clk(clk),
			.WE(MemWrite),
			.Size(Size),
			.ADDR(ALUResult),
			.WD(WriteData),
			.RD(ReadData) 
	);
Mux_4to1 #(32) MUX5 
	(
        .input_0(ALUResult),
        .input_1(ReadData),
		  .input_2(PCPlus4),
		  .input_3(ImmExt),
        .select(ResultSrc),
        .output_value(WD3)
    );


Constant4 #(32,4)My_Constant_Four
(
	.const_value(Const_Four)
);


assign Op = Instr [6:0];
assign Funct3 = Instr [14:12];
assign Funct7 = Instr [30];
assign A1 = Instr [19:15];
assign A2 = Instr [24:20];
assign A3 = Instr [11:7];
assign WriteData = RD2;
assign PC_Out = PC_Current;
assign Result = WD3;
assign SrcA_out= SrcA;
assign SrcB_out= SrcB;
assign  RD2_out= RD2;
assign ALUResult_out=ALUResult;
endmodule
