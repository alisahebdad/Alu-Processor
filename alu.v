module Alu #(parameter N = 8)(
    input[2:0] opcode,input [N-1:0] A,B,
    output reg [N-1:0] y,
    output reg overflow);
    always @(*) begin
        case (opcode)
            3'b000: y = A+B;
            3'b001: y = A-B;
            3'b010: y = A/B;
            3'b011: y = A*B; 
        endcase
    end
endmodule