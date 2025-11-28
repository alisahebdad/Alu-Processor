module reg_file_single_port #(
    parameter WIDTH = 32,
    parameter DEPTH = 32
)(
    input  wire                     clk,
    input  wire                     rst,      // synchronous reset
    input  wire                     we,       // write enable
    input  wire [$clog2(DEPTH)-1:0] addr,     // SAME for read & write
    input  wire [WIDTH-1:0]         wdata,    // write data
    output wire [WIDTH-1:0]         rdata     // read data
);

    reg [WIDTH-1:0] reg_array [0:DEPTH-1];
    integer i;

    // synchronous reset and write
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < DEPTH; i = i + 1)
                reg_array[i] <= {WIDTH{1'b0}};
        end else if (we) begin
            $display("REGFILE[%d] = %d",addr,wdata);
            reg_array[addr] <= wdata;
        end
    end

    // asynchronous read
    assign rdata = reg_array[addr];

endmodule
