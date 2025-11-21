module PC #(parameter N = 6)(
    input clk,
    input rst,
    input inc_pc,
    input clr_pc,
    input ld_pc,
    input [N-1:0]data_in,
    output reg [N-1:0]data_out
);

always @(posedge clk,posedge rst) begin 
    if (rst || clr_pc) 
        data_out <= {N{1'b0}};
    else begin 
        if (ld_pc) 
            data_out <= data_in;
        else if (inc_pc) 
            data_out <= data_out + 1;
 
    end 
end 

endmodule