module cpu #(parameter MEM_WIDTH=16)(
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
assign reg_addrs = data_out_ir[MEM_WIDTH-4:MEM_WIDTH-7];
reg_file_single_port #(.WIDTH(8),.DEPTH(8)) regfile(
    .clk(clk),
    .rst(rst),      // synchronous reset
    .we(ld_ac),       // write enable
    .addr(reg_addrs),     // SAME for read & write
    .wdata(data_ld_ac),    // write data
    .rdata(data_out_ac)     // read data
);



// AC #(.N(8)) ac(
//     .clk(clk),
//     .rst(rst),
//     .ld_ac(ld_ac),
//     .data_in(data_ld_ac),
//     .data_out(data_out_ac)
//  );

reg[2:0] alu_opcode;
wire alu_overflow;
wire [7:0] alu_b = {2'b00,data_out_ir[5:0]};
wire [7:0] alu_y;

Alu #(.N(8)) alu(
    .opcode(alu_opcode),
    .A(data_out_ac),
    .B(alu_b),
    .y(alu_y),
    .overflow(alu_overflow)
);  
assign data_bus_out = {{8{alu_y[7]}},alu_y[7:0]};


// ........................ control unit ..........................
typedef enum logic [2:0] {
    RESET    = 3'b000,
    FETCH    = 3'b010,
    DECODE   = 3'b100,
    EXECUTE  = 3'b110,
    EXECUTE2 = 3'b111
} cpu_state;

typedef enum logic [2:0] {
    add_imdt = 3'b000,
    lda_addr = 3'b010,
    sta_addr = 3'b100,
    jmp_addr = 3'b110
} opcode;


cpu_state state;

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
wire [2:0] ir_opcode;
// wire []
assign ir_opcode = data_out_ir[MEM_WIDTH-1:MEM_WIDTH-3];





always @(ir_opcode) begin 
    if (state == DECODE) begin
        case (ir_opcode)
            sta_addr: alu_opcode = 3'b100;
            add_imdt: alu_opcode = 3'b000;
            lda_addr: alu_opcode = 3'b000;
            jmp_addr: alu_opcode = 3'b000;
        endcase
    end else alu_opcode = 3'b000;

end 


// fetch from memory  
always @(posedge clk) begin 
    inc_pc <= 0;

    case(state)
    RESET:begin 
        addr_bus <= 0;
        ld_ir <= 1;
        clr_pc <= 0;
        ld_pc <= 0 ;
        mem_write <= 0;
        ld_ac <= 0;
    end 
    FETCH:begin
        inc_pc <= 1;
        ld_ir <= 0;
        ld_ac <= 0;
    end 
    DECODE:begin 
        ld_ir <= 0;
        ld_ac <= 0;
        case (ir_opcode)
            sta_addr:begin
                mem_write <= 1;
                addr_bus <= {2'b00,data_out_ir[5:0]};
            end 
            lda_addr:begin 
                addr_bus <= {2'b00,data_out_ir[5:0]};
            end 
            add_imdt:begin 
                data_ld_ac <= data_bus_out;
                ld_ac <= 1;
            end 
            jmp_addr:begin 
            end 
        endcase
    end 

    EXECUTE:begin 
        ld_ac <= 0;
        addr_bus <= pc_out;
        ld_ir <= 1;  
        mem_write <= 0;          
    end 

    default:begin 

    end 

    endcase
end 

endmodule