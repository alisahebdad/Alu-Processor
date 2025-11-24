module tb_cpu;
parameter MEM_WIDTH = 16;

reg clk;
reg rst;
wire [MEM_WIDTH-1:0] data_bus_in;
wire [MEM_WIDTH-1:0] data_bus_out;
wire [5:0] addr_bus;
wire mem_write;

cpu #(.MEM_WIDTH(MEM_WIDTH)) myCpu(
    .clk(clk),
    .rst(rst),
    .data_bus_in(data_bus_in),
    .data_bus_out(data_bus_out),
    .addr_bus(addr_bus),
    .mem_write(mem_write)
);

memory_64xN #(.MEM_WIDTH(MEM_WIDTH)) mainMemory
(
    .dout(data_bus_in),
    .din(data_bus_out),
    .addr(addr_bus),
    .writeEnable(writeEnable)
);


initial begin 
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_cpu);
    clk = 0;
    rst = 1;
    #14
    rst = 0;
    #1500;
    $finish;
end 

always begin 
    #5 clk = ~clk;
end



endmodule