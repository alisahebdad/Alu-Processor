module cpu #(parameter MEM_WIDTH=8)(
    input  clk,rst,
    input  [MEM_WIDTH-1:0]data_bus_in,
    output [MEM_WIDTH-1:0]data_bus_out,
    output reg [5:0] addr_bus,
    output reg mem_write
    );

// ........................ data path .............................

reg ir_on_addr;


reg inc_pc,clr_pc,ld_pc;
wire [5:0] pc_in,pc_out;
PC pc(
    .clk(clk),
    .rst(rst),
    .inc_pc(inc_pc),
    .clr_pc(clr_pc),
    .ld_pc(ld_pc),
    .data_in(pc_in),
    .data_out(pc_out)
    );



reg ld_ir;
reg [MEM_WIDTH-1:0]data_out_ir;

IR #(.N(MEM_WIDTH))ir(
    .clk(clk),
    .rst(rst),
    .ld_ir(ld_ir),
    .data_in(data_bus_in),
    .data_out(data_out_ir)
);


reg ld_ac;
wire [7:0] data_out_ac;
reg [7:0]data_ld_ac;
AC #(.N(8)) ac(
    .clk(clk),
    .rst(rst),
    .ld_ac(ld_ac),
    .data_in(data_ld_ac),
    .data_out(data_out_ac)
);

// module Alu #(parameter N = 8)(
//     input[2:0] opcode,input [N-1:0] A,B,
//     output reg [N-1:0] y,
//     output reg overflow)
reg[2:0] alu_opcode;
wire alu_overflow;
wire [7:0] alu_b = {2'b00,data_out_ir[5:0]};

// module Alu #(parameter N = 8)(
//     input[2:0] opcode,input [N-1:0] A,B,
//     output reg [N-1:0] y,
//     output reg overflow);


Alu #(.N(8)) alu(
    .opcode(alu_opcode),
    .A(data_out_ac),
    .B(alu_b),
    .y(data_bus_out),
    .overflow(alu_overflow)
);  



// ........................ control unit ..........................
typedef enum logic [1:0] {
    RESET   = 2'b00,
    FETCH   = 2'b01,
    DECODE  = 2'b10,
    EXECUTE = 2'b11
} cpu_state;

typedef enum logic [1:0] {
    add_imdt = 2'b00,
    lda_addr = 2'b01,
    sta_addr = 2'b10,
    jmp_addr = 2'b11
} opcode;


cpu_state state;

// always @(posedge clk) begin 
//     if (state == EXECUTE) begin 
//         inc_pc <= 1;
//     end else begin 
//         inc_pc <= 0;
//     end 
// end

always @(posedge clk,posedge rst) begin
    if (rst)
        state <= RESET;
    else
        case (state) 
            RESET: state <= FETCH;
            FETCH: state <= DECODE;
            DECODE: state <= EXECUTE;
            EXECUTE: state <= FETCH;
        endcase
end 

always @(data_out_ir) begin 
    if (state == DECODE) begin
        case (data_out_ir[7:6])
            sta_addr: alu_opcode = 3'b100;
            add_imdt: alu_opcode = 3'b000;
            lda_addr: alu_opcode = 3'b000;
            jmp_addr: alu_opcode = 3'b000;
        endcase
    end else alu_opcode = 3'b000;

end 


// fetch from memory  
always @(posedge clk) begin 
    if (state == RESET) begin 
        inc_pc <= 0;
        ir_on_addr = 0;
        addr_bus <= 0;
        ld_ir <= 1;
        clr_pc <= 0;
        ld_pc <= 0 ;
        mem_write <= 0;
        ld_ac <= 0;
    end else begin 
        case(state)
        FETCH:begin
            inc_pc <= 1;
            ld_ir <= 0;
            ld_ac <= 0;
        end 
        DECODE:begin 
            ld_ir <= 0;
            ld_ac <= 0;
            case (data_out_ir[7:6])
                sta_addr:begin
                    ir_on_addr <= 1;
                    mem_write <= 1;
                    addr_bus <= {2'b00,data_out_ir[5:0]};
                    
                end 
                lda_addr:begin 
                    ir_on_addr <= 1;
                    addr_bus <= {2'b00,data_out_ir[5:0]};

                end 
                add_imdt:begin 
                    
                    data_ld_ac <= data_bus_out;
                    ld_ac <= 1;
                end 
                jmp_addr:begin 

                end 

            endcase

            #1 inc_pc <= 0;



        end 

        EXECUTE:begin 
            ir_on_addr <= 0;
            ld_ac <= 0;
            addr_bus <= pc_out;
            ld_ir <= 1;  
            mem_write <= 0;          
        end 


        default:begin 

        end 

        endcase



        if (state == FETCH) begin 
            addr_bus <= pc_out;
            
        end else begin 
            inc_pc = 0;
            if (state == DECODE) begin 
                if (data_out_ir[7:6] == lda_addr || data_out_ir[7:6] == sta_addr) begin 
                    ir_on_addr = 1;
                end 

            end 

            
        end 
    end 
end 



endmodule