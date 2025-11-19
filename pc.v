module PC #(parameter N = 6)(
    input clk,
    input rst,
    input inc_pc,
    input clr_pc,
    input ld_pc,
    input [N-1:0]data_in,
    output reg [N-1:0]data_out
);
    always @(posedge clk,rst) begin 
        if (rst) 
            data_out <= {N{1'b0}};
        else begin 
            if (clr_pc)
                data_out <= {N{1'b0}};
            else if (inc_pc) data_out <= data_out + 1;
            else if (ld_pc) data_out <= data_in;
            
        
        
        end 


    end 





endmodule