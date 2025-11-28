module memory_64xN #(parameter MEM_WIDTH=8)(
    input              writeEnable,
    input  [5:0]       addr,    // 6-bit for 64 rows
    input  [MEM_WIDTH-1:0]      din,
    output [MEM_WIDTH-1:0]      dout
);

    // 64 rows × 16 bits
    reg [MEM_WIDTH-1:0] mem [0:63];

    // Asynchronous read
    assign dout = mem[addr];

    // Synchronous write
    always @(*) begin
        if (writeEnable)begin 
            mem[addr] <= din;
            $display("mem[%d] = %d",addr,din);
        end 
    end

    // Load memory content from file at simulation start
    initial begin
        $readmemb("mem_init.bin", mem);
        // or: $readmemb("mem_init.bin", mem); // for binary file
    end

endmodule
