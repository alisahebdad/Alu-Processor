module tb_ir;
parameter N = 8;
reg clk,rst;
reg ld_ir;
reg [N-1:0] data_in;
wire [N-1:0] data_out;

// module IR #(parameter N = 8)(
//     input clk,
//     input rst,
//     input ld_ir,
//     input [N-1:0]data_in,
//     output reg [N-1:0]data_out
// );



IR cut(
    .clk(clk),
    .rst(rst),
    .ld_ir(ld_ir),
    .data_in(data_in),
    .data_out(data_out)
);

always begin
    #5 clk = ~clk;
end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_ir);
    clk = 0;
    #20
    rst = 1;
    #10
    rst = 0;
    #40
    ld_ir = 1;
    data_in = 8'b10101010;
    #10
    ld_ir = 0;
    data_in = 7;
    #10
    ld_ir = 1;
    data_in = 8'b11111111;
    #10

    #1000
    $finish;

end



endmodule