module tb_mem;

    reg we;
    reg [5:0] addr;
    reg [15:0] din;
    wire [15:0] dout;

    memory_64x16 dut ( .writeEnable(we), .addr(addr), .din(din), .dout(dout));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_mem);
        // wait for memory to load
        #1;        
        // Read first few locations (async)
        addr = 0; #1 $display("mem[0] = %h", dout);
        addr = 1; #1 $display("mem[1] = %h", dout);
        addr = 2; #1 $display("mem[2] = %h", dout);

        // Write example
        addr = 3; din = 16'h1234; we = 1; #1
        addr = 4; din = 16'h4321; we = 1; #1
        addr = 5; din = 16'h70F0; we = 1; #1
        
        we = 0;
        // Read written value
        addr = 3;
        #1 $display("mem[3] after write = %h", dout);
        addr = 4;
        #1 $display("mem[3] after write = %h", dout);
        addr = 5;
        #1 $display("mem[3] after write = %h", dout);

        #20 $finish;
    end

endmodule
