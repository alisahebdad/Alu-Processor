module tb_Alu;
reg [2:0] opcode;
reg [7:0] A,B;
wire [7:0] y;

Alu #(.N(8)) cut(
    .opcode(opcode),
    .A(A),
    .B(B),
    .y(y)
);

integer i,j;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_Alu);
    
    opcode = 3'b000;
    for (j = 0; j < 4; j = j + 1) begin 
        for (i = 0; i < 10; i = i + 1) begin
            #10
            A = $random % 128;
            B = $random % 128;
            #10
            if (opcode == 0)
                $display(" %d + %d = %d(%d) , %s",A,B,A+B,y, A+B == y ? "correct" : "wrong!");
            if (opcode == 1)
                $display(" %d - %d = %d(%d) , %s",A,B,A-B,y, A-B == y ? "correct" : "wrong!");
            if (opcode == 2)
                $display(" %d / %d = %d(%d) , %s",A,B,A/B,y, A/B == y ? "correct" : "wrong!");
            if (opcode == 3)
                $display(" %d * %d = %d(%d) , %s",A,B,A*B,y, A*B == y ? "correct" : "wrong!");
            

        end 
        opcode = opcode + 1;
    end
    $finish;

end



endmodule