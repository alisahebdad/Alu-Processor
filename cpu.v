module cpu #(parameter MEM_WIDTH=16)(
    input  clk,rst,
    input  [MEM_WIDTH-1:0]data_bus_in,
    output reg [MEM_WIDTH-1:0]data_bus_out,
    output reg [5:0] addr_bus,
    output reg mem_write
    );

// ........................ data path .............................

reg ir_on_addr;


reg inc_pc,clr_pc,ld_pc;
wire [5:0] pc_out;
reg [5:0] pc_in;
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


reg ld_regFile;
wire [7:0] data_out_regFile;
reg [7:0]data_ld_regFile;
wire [1:0] reg_addrs;
assign reg_addrs = data_out_ir[MEM_WIDTH-4:MEM_WIDTH-5];
//assign reg_addrs = state == EXECUTE2 ? data_out_ir[MEM_WIDTH-6:MEM_WIDTH-7] : data_out_ir[MEM_WIDTH-4:MEM_WIDTH-5];

reg_file_single_port #(.WIDTH(8),.DEPTH(4)) regfile(
    .clk(clk),
    .rst(rst),      // synchronous reset
    .we(ld_regFile),       // write enable
    .addr(reg_addrs),     // SAME for read & write
    .wdata(data_ld_regFile),    // write data
    .rdata(data_out_regFile)     // read data
);

reg[2:0] alu_opcode;
wire alu_overflow;
reg [7:0] alu_b ;
wire [7:0] alu_y;

Alu #(.N(8)) alu(
    .opcode(alu_opcode),
    .A(data_out_regFile),
    .B(alu_b),
    .y(alu_y),
    .overflow(alu_overflow)
);  

// ........................ control unit ..........................
typedef enum logic [2:0] {
    RESET    = 3'b000,
    FETCH    = 3'b111,
    DECODE   = 3'b100,
    EXECUTE  = 3'b110,
    EXECUTE2 = 3'b010
} cpu_state;

typedef enum logic [2:0] {
    add_imdt = 3'b000,
    lda_addr = 3'b010,
    sta_addr = 3'b100,
    jmp_addr = 3'b110,
    no_op    = 3'b111,
    ld_imdt  = 3'b001,
    mov_acc  = 3'b011
} opcode;


cpu_state state;

always @(posedge clk,posedge rst) begin
    if (rst)
        state <= RESET;
    else
        case (state) 
            RESET:    state <= FETCH;
            FETCH:    state <= DECODE;
            DECODE:   state <= EXECUTE;
            EXECUTE:  state <= EXECUTE2;
            EXECUTE2: state <= FETCH;
        endcase
end 
wire [2:0] ir_opcode;
// wire []
assign ir_opcode = data_out_ir[MEM_WIDTH-1:MEM_WIDTH-3];





always @(ir_opcode,state) begin 
    case (state)
        DECODE:begin 
            case (ir_opcode)
                sta_addr: alu_opcode =  3'b100 ;
                add_imdt: alu_opcode = {1'b0,data_out_ir[MEM_WIDTH-6:MEM_WIDTH-7]};
                lda_addr: alu_opcode =  3'b100 ;
                jmp_addr: alu_opcode =  3'b100 ;
            endcase
        end
        default:begin 
            case (ir_opcode)
                sta_addr: alu_opcode = 3'b100;
                add_imdt: alu_opcode = {1'b0,data_out_ir[MEM_WIDTH-6:MEM_WIDTH-7]};
                lda_addr: alu_opcode = 3'b100;
                jmp_addr: alu_opcode = 3'b100;
            endcase
        end 
    endcase

end 


// fetch from memory  
always @(posedge clk) begin 
    inc_pc <= 0;
    ld_ir <= 0;
    clr_pc <= 0;
    ld_pc <= 0 ;
    mem_write <= 0;
    ld_regFile <= 0;
    case(state)
    RESET:begin 
        addr_bus <= 0;
        ld_ir <= 1; 
        // data_bus_out <= 0;

    end 
    FETCH:begin
        inc_pc <= 1;
        alu_b <= {2'b00,data_out_ir[5:0]};
    end 
    DECODE:begin 
        case (ir_opcode)
            sta_addr:begin
                $display("Decode[%d].sta_addr",pc_out);
                mem_write <= 1;
                data_bus_out <= data_out_regFile;
                addr_bus <= data_out_ir[5:0];
            end 
            lda_addr:begin 
                $display("Decode[%d].lda_addr - addr_bus : %d alu_opd: %d",pc_out,data_out_ir[5:0],alu_opcode);
                addr_bus <= data_out_ir[5:0];
            end 
            add_imdt:begin 
                $display("Decode[%d].add_imdt ALU: %d result: REG[%d] = %d",pc_out,alu_opcode,reg_addrs,alu_y);
                data_ld_regFile <= alu_y[7:0];
                ld_regFile <= 1;
            end 
            jmp_addr:begin 
                $display("Decode[%d].Jump to ",pc_out);
            end 
            no_op:begin 
                $display("Decode[%d].No Operation",pc_out);
            end 
            ld_imdt:begin 
                $display("Decode[%d].ld imdt",pc_out);
                data_ld_regFile <= data_out_ir[5:0];
                ld_regFile <= 1;
            end 
            mov_acc:begin 
                $display("Mov[%d] ",pc_out);
                
                

            end 
        endcase
    end 
    EXECUTE:begin 
        addr_bus <= pc_out;
        ld_ir <= 1; 
        case (ir_opcode)
            mov_acc: begin
                
            end
            sta_addr:begin
                // $display("Execute[%d].sta_addr",pc_out-1);
            end 
            lda_addr:begin 
                $display("Execute[%d].lda_addr alu_opcode: %d ,alu_y %d adrs_bus: %d",pc_out-1,alu_opcode,alu_y,addr_bus);
                
                data_ld_regFile <= data_bus_in;
                ld_regFile <= 1;
            end 
            add_imdt:begin 
                // $display("Execute[%d].add_imdt",pc_out-1);
            end 
            jmp_addr:begin 
                // $display("Execute[%d].Jump to ",pc_out-1);
                ld_pc <= 1;
                pc_in <= data_out_ir[5:0];
            end 
            no_op:begin 
                // $display("Execute[%d].No Operation",pc_out-1);
            end 
            ld_imdt:begin 

            end 
        endcase 
    end 

    EXECUTE2:begin 


    end 

    default:begin 

    end 

    endcase
end 

endmodule