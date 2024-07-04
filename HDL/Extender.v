module Extender (
    output reg [31:0]Extended_data,
    input [24:0]DATA,
    input [2:0]select
);

always @(*) begin
    case (select)
        3'b000: Extended_data = {{20{DATA[24]}}, DATA[24:13]};
		  3'b001: Extended_data = {{20{DATA[24]}}, DATA[24:18], DATA[4:0]};
		  3'b010: Extended_data = {{20{DATA[24]}}, DATA[0], DATA[23:18], DATA[4:1], 1'b0};
		  3'b011: Extended_data = {{12{DATA[24]}}, DATA[12:5], DATA[13], DATA[23:14], 1'b0};
		  3'b111: Extended_data ={DATA[24:5],12'b0};
        default: Extended_data = 32'd0;
    endcase
end
    
endmodule
