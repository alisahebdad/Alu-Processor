module IR #(parameter N = 8)(
    input clk,
    input rst,
    input ld_ir,
    input [N-1:0]data_in,
    output reg [N-1:0]data_out
);

always @(posedge clk,rst) begin 
    if (rst) 
        data_out <= {N{1'b0}};
    else begin 
        if (ld_ir) data_out <= data_in ;
    end 
end 

endmodule