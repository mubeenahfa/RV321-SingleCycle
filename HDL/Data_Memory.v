module Memory#(
    BYTE_SIZE = 4,
    ADDR_WIDTH = 32
)(
    input clk,                    // Clock signal
    input WE,                     // Write Enable signal
    input [2:0] Size,             // 000 for word, 001 for signed half-word, 010 for unsigned half-word, 011 for signed byte, 100 for unsigned byte
    input [ADDR_WIDTH-1:0] ADDR,  // Address input
    input [(BYTE_SIZE*8)-1:0] WD, // Write Data input
    output reg [(BYTE_SIZE*8)-1:0] RD  // Read Data output
);

reg [7:0] mem [255:0];

always @* begin
    case(Size)
        3'b000: RD = {mem[ADDR+3], mem[ADDR+2], mem[ADDR+1], mem[ADDR]}; // Word read
        3'b001: RD = {{16{mem[ADDR+1][7]}}, mem[ADDR+1], mem[ADDR]}; // Signed half-word read
        3'b010: RD = {{16{1'b0}},mem[ADDR+1], mem[ADDR]}; // Unsigned half-word read
        3'b011: RD = {{24{mem[ADDR][7]}}, mem[ADDR]}; // Signed byte read
        3'b100: RD = {{24{1'b0}}, mem[ADDR]}; // Unsigned byte read
        default: RD = 32'b0; // Default case to handle unexpected Size values
    endcase
end

always @(posedge clk) begin
    if (WE) begin
			$display("Writing to address %h, data = %h", ADDR, WD);
        case(Size)
            3'b000: begin // Word write
                mem[ADDR] <= WD[7:0];
                mem[ADDR+1] <= WD[15:8];
                mem[ADDR+2] <= WD[23:16];
                mem[ADDR+3] <= WD[31:24];
            end
            3'b001: begin // Half-word write
                mem[ADDR] <= WD[7:0];
                mem[ADDR+1] <= WD[15:8];
            end
            3'b011: mem[ADDR] <= WD[7:0]; // Byte write
        endcase
    end
end

endmodule
