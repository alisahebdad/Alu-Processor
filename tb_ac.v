module tb_ac;
parameter N = 8;
reg clk,rst;
reg ld_ac;
reg [N-1:0] data_in;
wire [N-1:0] data_out;


AC cut(
    .clk(clk),
    .rst(rst),
    .ld_ac(ld_ac),
    .data_in(data_in),
    .data_out(data_out)
);

always begin
    #5 clk = ~clk;
end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_ac);
    clk = 0;
    #20
    rst = 1;
    #10
    rst = 0;
    #40
    ld_ac = 1;
    data_in = 8'b10101010;
    #10
    ld_ac = 0;
    data_in = 7;
    #10
    ld_ac = 1;
    data_in = 8'b11111111;
    #10

    #1000
    $finish;

end



endmodule