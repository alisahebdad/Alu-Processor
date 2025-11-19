module memory_64x16 (
    input              writeEnable,
    input  [5:0]       addr,    // 6-bit for 64 rows
    input  [15:0]      din,
    output [15:0]      dout
);

    // 64 rows × 16 bits
    reg [15:0] mem [0:63];

    // Asynchronous read
    assign dout = mem[addr];

    // Synchronous write
    always @(*) begin
        if (writeEnable)
            mem[addr] <= din;
    end

    // Load memory content from file at simulation start
    initial begin
        $readmemb("mem_init.bin", mem);
        // or: $readmemb("mem_init.bin", mem); // for binary file
    end

endmodule
