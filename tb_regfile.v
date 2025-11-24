module tb_reg_file_single_port;

    localparam WIDTH = 8;
    localparam DEPTH = 8;

    reg clk;
    reg rst;
    reg we;
    reg [$clog2(DEPTH)-1:0] addr;
    reg [WIDTH-1:0] wdata;
    wire [WIDTH-1:0] rdata;

    reg_file_single_port #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    // clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        we  = 0;
        addr = 0;
        wdata = 0;

        $display("=== Simulation Start ===");

        // reset
        #10 rst = 0;

        // write reg[5] = 55
        #10 we = 1; addr = 5; wdata = 55;

        // write reg[12] = 1200
        #10 addr = 7; wdata = 1200;

        #10 we = 0;

        // read reg[5]
        #10 addr = 5;
        #10 $display("Read reg[5] = %0d", rdata);

        // read reg[12]
        #10 addr = 7;
        #10 $display("Read reg[12] = %0d", rdata);

        #10 $display("=== Simulation Done ===");
        #10 $finish;
    end

endmodule
