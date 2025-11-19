module tb_pc;
reg clk,rst;
reg inc_pc,clr_pc,ld_pc;
reg [5:0] data_in;
wire [5:0] data_out;

PC cut(
    .clk(clk),
    .rst(rst),
    .inc_pc(inc_pc),
    .clr_pc(clr_pc),
    .ld_pc(ld_pc),
    .data_in(data_in),
    .data_out(data_out)
);

always begin
    #5 clk = ~clk;
end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_pc);
    clk = 0;
    #20
    rst = 1;
    #10
    rst = 0;
    inc_pc = 1;
    #40
    inc_pc = 0;
    clr_pc = 1;
    #10
    clr_pc = 0;
    ld_pc = 1;
    data_in = 7;
    #10
    ld_pc = 0;

    #1000
    $finish;

end



endmodule