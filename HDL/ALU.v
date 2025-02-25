module ALU #(parameter WIDTH=32)
    (
      input [3:0] control,
      input signed [WIDTH-1:0] DATA_A,
      input signed [WIDTH-1:0] DATA_B,
      output reg [WIDTH-1:0] OUT,
      output reg IQF, Z
    );
    localparam ADD=4'b0000, // OUT = DATA_A + DATA_B
              SUB=4'b0001, // OUT = DATA_A - DATA_B , Z is set to 1 if answer is 0
              ORR=4'b0010, // OUT = DATA_A | DATA_B
              AND=4'b0011, // OUT = DATA_A & DATA_B
              XOR=4'b0100, // OUT = DATA_A ^ DATA_B
              LSL=4'b0101, // OUT = DATA_A << DATA_B
              LSR=4'b0110, // OUT = DATA_A >> DATA_B
              ASR=4'b0111, // OUT = DATA_A >>> DATA_B
              SLT=4'b1000, // OUT = (DATA_A < DATA_B) ? 1 : 0 , IQF is set to 1 if inequality is true else 0
              SLTU=4'b1001, // OUT = (DATA_A unsigned < DATA_B unsigned) ? 1 : 0 , IQF is set to 1 if inequality is true else 0
              GEQ=4'b1010, // OUT = (DATA_A >= DATA_B) ? 1 : 0 , IQF is set to 1 if inequality is true else 0
              GEQU=4'b1011, // OUT = (DATA_A unsigned >= DATA_B unsigned) ? 1 : 0, IQF is set to 1 if inequality is true else 0
              XORID=4'b1100; // OUT = DATA_B ^ student id1 ^ student id2

    always @(*) begin
        case(control)
            ADD: begin
                OUT = DATA_A + DATA_B;
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            SUB: begin
                OUT = DATA_A - DATA_B;
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            ORR: begin
                OUT = DATA_A | DATA_B;
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            AND: begin
                OUT = DATA_A & DATA_B;
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            XOR: begin
                OUT = DATA_A ^ DATA_B;
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            LSL: begin
                OUT = DATA_A << DATA_B [4:0];
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            LSR: begin
                OUT = DATA_A >> DATA_B [4:0];
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            ASR: begin
                OUT = DATA_A >>> DATA_B [4:0]; // Unsigned right shift
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            SLT: begin
                OUT = (DATA_A < DATA_B) ? 1 : 0;
                IQF = (DATA_A < DATA_B) ? 1'b1 : 1'b0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            SLTU: begin
                OUT = ($unsigned(DATA_A) < $unsigned(DATA_B)) ? 1 : 0; // Assuming unsigned comparison
                IQF = ($unsigned(DATA_A) < $unsigned(DATA_B)) ? 1'b1 : 1'b0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            GEQ: begin
                OUT = (DATA_A >= DATA_B) ? 1 : 0;
                IQF = (DATA_A >= DATA_B) ? 1'b1 : 1'b0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            GEQU: begin
                OUT = ($unsigned(DATA_A) >= $unsigned(DATA_B)) ? 1 : 0; // Unsigned comparison
                IQF = ($unsigned(DATA_A) >= $unsigned(DATA_B)) ? 1'b1 : 1'b0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            XORID: begin
                OUT = DATA_A ^ 32'h00003EE2;
                IQF = 0;
                Z = (OUT == 0) ? 1'b1 : 1'b0;
            end
            default: begin
                OUT = 0; // Default output
                IQF = 0; // Default IQF
                Z = 0; // Default Z flag
            end
        endcase
    end
endmodule
