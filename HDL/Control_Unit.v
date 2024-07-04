module Control_Unit(
    input clk,
	 input [6:0] Op,
    input [2:0] Funct3,
    input Funct7,
    input Zero,
    input IQF,

    output reg JALR, AUIPC, PCSrc, MemWrite, ALUSrc, RegWrite,
    output reg [2:0] Size,
    output reg [3:0] ALUControl,
    output reg [2:0] ImmSrc,
    output reg [1:0] ResultSrc
);

// Main Decoder
always @(*) begin
    // Default values
    JALR = 0;
    Size = 3'b000;
    AUIPC = 0;
    PCSrc = 0;
    ResultSrc = 2'b00;
    MemWrite = 0;
    ALUControl = 4'b0000;
    ALUSrc = 0;
    ImmSrc = 3'b000;
    RegWrite = 0;

    // Decode Op and Funct3
    if (Op == 7'b0000011) begin  // I-type Load instructions with op(3)
        if (Funct3 == 3'b000) begin //load byte
            JALR = 0;
            Size = 3'b011;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b01;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b001) begin //load half
            JALR = 0;
            Size = 3'b001;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b01;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;  
        end else if (Funct3 == 3'b010) begin // load word
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b01;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b100) begin // load byte unsigned
            JALR = 0;
            Size = 3'b100;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b01;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b101) begin // load half unsigned
            JALR = 0;
            Size = 3'b010;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b01;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end
    end // End of Op(3)
    else if (Op == 7'b0010011) begin  // I-type Arithmetic Immediate Instructions Op(19)
        if (Funct3 == 3'b000) begin  // Add Immediate
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b001) begin // Shift Left Logical Immediate
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0101;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b010) begin // Set Less Than Immediate
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b1000;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b011) begin // Set Less Than Immediate Unsigned
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b1001;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b100) begin // XOR Immediate
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0100;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b101 && Funct7 == 1'b0) begin // Shift Right Logical Immediate
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0110;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b101 && Funct7 == 1'b1) begin // Shift Right Arithmetic Immediate
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0111;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b110) begin // ORR Immediate
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0010;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end else if (Funct3 == 3'b111) begin // AND Immediate
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0011;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
        end
    end // End of Op(19)
    else if (Op == 7'b0010111) begin  // I-Type AUIPC instruction Op(23)
            JALR = 0;
            Size = 3'b000;
            AUIPC = 1;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b111;
            RegWrite = 1;
    end // End of Op(23)
    else if (Op == 7'b0100011) begin  // S-Type Store instruction Op(35)
        if (Funct3 == 3'b000) begin  // SB (Store Byte)
            JALR = 0;
            Size = 3'b011;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 1;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b001;
            RegWrite = 0;
        end else if (Funct3 == 3'b001) begin  // SB (Store Half word)
            JALR = 0;
            Size = 3'b001;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 1;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b001;
            RegWrite = 0;
        end else if (Funct3 == 3'b010) begin  // SB (Store Word)
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 1;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b001;
            RegWrite = 0;
        end
    end // End of Op(23)
    else if (Op == 7'b0110011) begin  // R-type Arithmetic Instructions with Op(51)
        if (Funct3 == 3'b000) begin
            if (Funct7 == 1'b0) begin // ADD 
                JALR = 0;
                Size = 3'b000;
                AUIPC = 0;
                PCSrc = 0;
                ResultSrc = 2'b00;
                MemWrite = 0;
                ALUControl = 4'b0000;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 1;  
            end else begin //SUB
                JALR = 0;
                Size = 3'b000;
                AUIPC = 0;
                PCSrc = 0;
                ResultSrc = 2'b00;
                MemWrite = 0;
                ALUControl = 4'b0001;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 1;
            end
        end 
        else if (Funct3 == 3'b001) begin // Shift Left Logical
                JALR = 0;
                Size = 3'b000;
                AUIPC = 0;
                PCSrc = 0;
                ResultSrc = 2'b00;
                MemWrite = 0;
                ALUControl = 4'b0101;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 1;  
        end 
        else if (Funct3 == 3'b010) begin // Set Less Than
                JALR = 0;
                Size = 3'b000;
                AUIPC = 0;
                PCSrc = 0;
                ResultSrc = 2'b00;
                MemWrite = 0;
                ALUControl = 4'b1000;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 1;  
        end 
        else if (Funct3 == 3'b011) begin // Set Less Than Unsigned
                JALR = 0;
                Size = 3'b000;
                AUIPC = 0;
                PCSrc = 0;
                ResultSrc = 2'b00;
                MemWrite = 0;
                ALUControl = 4'b1001;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 1;  
        end 
        else if (Funct3 == 3'b100) begin // XOR
                JALR = 0;
                Size = 3'b000;
                AUIPC = 0;
                PCSrc = 0;
                ResultSrc = 2'b00;
                MemWrite = 0;
                ALUControl = 4'b0100;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 1; 
        end 
        else if (Funct3 == 3'b101) begin 
                if (Funct7 == 1'b0) begin // Shift Right Logical 
                    JALR = 0;
                    Size = 3'b000;
                    AUIPC = 0;
                    PCSrc = 0;
                    ResultSrc = 2'b00;
                    MemWrite = 0;
                    ALUControl = 4'b0110;
                    ALUSrc = 0;
                    ImmSrc = 3'b000;
                    RegWrite = 1; 
                end else begin // Shift Right Arithmetic
                    JALR = 0;
                    Size = 3'b000;
                    AUIPC = 0;
                    PCSrc = 0;
                    ResultSrc = 2'b00;
                    MemWrite = 0;
                    ALUControl = 4'b0111;
                    ALUSrc = 0;
                    ImmSrc = 3'b000;
                    RegWrite = 1;
                end  
        end 
        else if (Funct3 == 3'b110) begin // ORR
                JALR = 0;
                Size = 3'b000;
                AUIPC = 0;
                PCSrc = 0;
                ResultSrc = 2'b00;
                MemWrite = 0;
                ALUControl = 4'b0010;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 1; 
        end 
        else if (Funct3 == 3'b111) begin // AND
                JALR = 0;
                Size = 3'b000;
                AUIPC = 0;
                PCSrc = 0;
                ResultSrc = 2'b00;
                MemWrite = 0;
                ALUControl = 4'b0011;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 1;  
        end 
    end //End of Op(51)
    else if (Op == 7'b0110111) begin  // U-Type LUI Instruction Op(55) 0110111
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b11;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 0;
            ImmSrc = 3'b111;
            RegWrite = 1;
    end //End of Op(55)
    else if (Op == 7'b1100011) begin  // B-Type Branch instruction Op(99)
        if (Funct3 == 3'b000) begin  // BEQ (Branch if Equal)
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = Zero;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0001;
            ALUSrc = 0;
            ImmSrc = 3'b010;
            RegWrite = 0;
        end else if (Funct3 == 3'b001) begin  // BNE (Branch if Not Equal)
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = ~Zero;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b0001;
            ALUSrc = 0;
            ImmSrc = 3'b010;
            RegWrite = 0;
        end else if (Funct3 == 3'b100) begin  // BLT (Branch less Than)
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = IQF;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b1000;
            ALUSrc = 0;
            ImmSrc = 3'b010;
            RegWrite = 0;
        end else if (Funct3 == 3'b101) begin  // BGE (Branch Greater Equal)
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = IQF;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b1010;
            ALUSrc = 0;
            ImmSrc = 3'b010;
            RegWrite = 0;
        end else if (Funct3 == 3'b110) begin  // BLTU (Branch less Than Unsigned)
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = IQF;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b1001;
            ALUSrc = 0;
            ImmSrc = 3'b010;
            RegWrite = 0;
        end else if (Funct3 == 3'b111) begin  //  BGEU (Branch Greater Equal Unsigned)
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = IQF;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b1011;
            ALUSrc = 0;
            ImmSrc = 3'b010;
            RegWrite = 0;
        end
    end //END of Op(99)
    else if (Op == 7'b1100111 && Funct3 == 3'b000) begin  // JALR instruction Op(103)
            JALR = 1;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b10;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            RegWrite = 1;
    end //END of Op(103) 
    else if (Op == 7'b1101111) begin  // J-Type JAL instruction
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 1;
            ResultSrc = 2'b10;
            MemWrite = 0;
            ALUControl = 4'b0000;
            ALUSrc = 0;
            ImmSrc = 3'b011;
            RegWrite = 1;
    end //End of Op(111)
    else if (Op == 7'b0001011 && Funct3 == 3'b100) begin  // I-Type EXTRA INSTRUCTION XORID
            JALR = 0;
            Size = 3'b000;
            AUIPC = 0;
            PCSrc = 0;
            ResultSrc = 2'b00;
            MemWrite = 0;
            ALUControl = 4'b1100;
            ALUSrc = 0;
            ImmSrc = 3'b000;
            RegWrite = 1;
    end //End of Op(111)
end
endmodule
