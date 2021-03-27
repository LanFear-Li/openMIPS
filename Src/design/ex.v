`include "defines.v"

module ex(
    input wire                  rst,                      
    
    input wire[`AluOpBus]       aluop_i,      
    input wire[`AluSelBus]      alusel_i, 
    input wire[`RegBus]         reg1_i,     
    input wire[`RegBus]         reg2_i,      
    input wire[`RegAddrBus]     wd_i,        
    input wire                  wreg_i,       
    
    input wire[`RegBus]         hi_i,      
    input wire[`RegBus]         lo_i,     
    
    // pipeline issue in memory
    input wire                  mem_whilo_i,      
    input wire[`RegBus]         mem_hi_i,          
    input wire[`RegBus]         mem_lo_i, 
    
    // pipeline issue in writeback
    input wire                  wb_whilo_i,      
    input wire[`RegBus]         wb_hi_i,          
    input wire[`RegBus]         wb_lo_i,  
        
    output reg[`RegBus]         wdata_o,      
    output reg[`RegAddrBus]     wd_o,          
    output reg                  wreg_o,
    
    output reg                  whilo_o,      
    output reg[`RegBus]         hi_o,          
    output reg[`RegBus]         lo_o,
    
    output reg                  stallreq        // pipeline stall request    
    );
    
    reg[`RegBus]                logic_res;
    reg[`RegBus]                shift_res;
    reg[`RegBus]                move_res;
    reg[`RegBus]                arith_res;
    reg[`DoubleRegBus]          mul_res;
    
    reg[`RegBus]                hi_res;
    reg[`RegBus]                lo_res;
    
    reg                         tmp;
    reg[`RegBus]                i;
    reg[`RegBus]                count;
   
    wire                        of_check;           // overflow check
    
    wire[`RegBus]               reg1_i_not;  
    wire[`RegBus]               reg2_i_mux;         // correct reg2 data
    wire[`RegBus]               sum_res;            // temp storage of result
    
    reg[`RegBus]                multiplicand;
    reg[`RegBus]                multiplier;
    wire[`DoubleRegBus]         temp_mul_res;
   
    // get hi/lo update for pipeline
    always @ (*) begin
        if (rst == `RstEnable) begin
            hi_res = `ZeroWord;
            lo_res = `ZeroWord;
        end else if (mem_whilo_i == `WriteEnable) begin
            hi_res = mem_hi_i;
            lo_res = mem_lo_i;
        end else if (wb_whilo_i == `WriteEnable) begin
            hi_res = wb_hi_i;
            lo_res = wb_lo_i;            
        end else begin
            hi_res = hi_i;
            lo_res = lo_i;
        end
    end
    
    // sub type logic
    always @ (*) begin
        if (rst == `RstEnable) begin
            logic_res   = `ZeroWord;
        end else begin
            case (aluop_i)
                 `SUB_TYPE_AND: begin
                    logic_res   = reg1_i & reg2_i;
                 end
                 
                 `SUB_TYPE_OR: begin
                    logic_res   = reg1_i | reg2_i;
                 end
                 
                 `SUB_TYPE_XOR: begin
                    logic_res   = reg1_i ^ reg2_i;
                 end
                 
                 `SUB_TYPE_NOR: begin
                    logic_res   = ~(reg1_i | reg2_i);
                 end
                 
                 `SUB_TYPE_LUI: begin
                    logic_res[31:16] = reg2_i[15:0]; 
                 end
                 
                 default : begin
                    logic_res   = `ZeroWord;
                 end
            endcase
        end
    end
    
    // sub type shift
    always @ (*) begin
        if (rst == `RstEnable) begin
            shift_res   = `ZeroWord;
        end else begin
            case (aluop_i)
                 `SUB_TYPE_SLL: begin
                    shift_res   = reg2_i << reg1_i[4:0]; 
                 end
                 
                 `SUB_TYPE_SRL: begin
                    shift_res   = reg2_i >> reg1_i[4:0];
                 end 
                 
                 `SUB_TYPE_SRA: begin
                    tmp = reg2_i[31];
                    shift_res   = reg2_i >> reg1_i[4:0];
                    for (i = 1; i <= reg1_i[4:0]; i = i + 1) begin
                        shift_res[31 - i + 1] = tmp;
                    end
                 end
                 
                 default : begin
                    shift_res   = `ZeroWord;
                 end
            endcase
        end
    end
       
    // sub type move
    always @ (*) begin
        if (rst == `RstEnable) begin
            move_res    = `ZeroWord;
        end else begin
            case (aluop_i)
                 `SUB_TYPE_MOVN: begin
                    move_res    = reg1_i;
                 end
                 
                 `SUB_TYPE_MOVZ: begin
                    move_res    = reg1_i;
                 end
                 
                 `SUB_TYPE_MFHI: begin
                    move_res    = hi_res;
                 end
                 
                 `SUB_TYPE_MFLO: begin
                    move_res    = lo_res;
                 end
                 
                 default: begin
                    move_res    = `ZeroWord;
                 end
            endcase
        end
    end
    
    // decide the op num (sub, subu, slt, others)
    assign reg2_i_mux = (aluop_i == `SUB_TYPE_SUB) || (aluop_i == `SUB_TYPE_SUBU) || (aluop_i == `SUB_TYPE_SLT) ? (~reg2_i) + 1 : reg2_i;
    
    assign sum_res = reg1_i + reg2_i_mux;
    
    // check data overflow for add, addi, sub, subi
    assign of_check = (!reg1_i[31] && !reg2_i_mux[31] && sum_res[31]) || (reg1_i[31] && reg2_i_mux[31] && !sum_res[31]);
    
    assign reg1_i_not = ~reg1_i;
    
    // sub type arith
    always @ (*) begin
        if (rst == `RstEnable) begin
            arith_res    = `ZeroWord;
        end else begin
            case (aluop_i)
                 `SUB_TYPE_ADD: begin
                    arith_res   = sum_res;
                 end
                 
                 `SUB_TYPE_ADDU: begin
                    arith_res   = sum_res;
                 end
                 
                 `SUB_TYPE_SUB: begin
                    arith_res   = sum_res;
                 end
                 
                 `SUB_TYPE_SUBU: begin
                    arith_res   = sum_res;
                 end
                 
                 `SUB_TYPE_SLT: begin
                    if (reg1_i[31] && !reg2_i[31]) begin
                        arith_res = 1;
                    end else if (!reg1_i[31] && !reg2_i[31] && sum_res[31]) begin
                        arith_res = 1;
                    end else if (reg1_i[31] && reg2_i[31] && sum_res[31]) begin
                        arith_res = 1;
                    end else begin
                        arith_res = 0;
                    end 
                 end
                 
                 `SUB_TYPE_SLTU: begin
                    if (reg1_i < reg2_i) begin
                        arith_res = `OneWord;
                    end else begin
                        arith_res = `ZeroWord;
                    end
                 end
                 
                 `SUB_TYPE_CLZ: begin
                    arith_res = (reg1_i[31] ? 0 : 
                                reg1_i[30] ? 1 :
                                reg1_i[29] ? 2 : 
                                reg1_i[28] ? 3 :
                                reg1_i[27] ? 4 : 
                                reg1_i[26] ? 5 :
                                reg1_i[25] ? 6 : 
                                reg1_i[24] ? 7 :
                                reg1_i[23] ? 8 : 
                                reg1_i[22] ? 9 :
                                reg1_i[31] ? 10 : 
                                reg1_i[20] ? 11 :
                                reg1_i[19] ? 12 : 
                                reg1_i[18] ? 13 :
                                reg1_i[17] ? 14 : 
                                reg1_i[16] ? 15 :
                                reg1_i[15] ? 16 : 
                                reg1_i[14] ? 17 :
                                reg1_i[13] ? 18 : 
                                reg1_i[12] ? 19 :
                                reg1_i[11] ? 20 : 
                                reg1_i[10] ? 21 :
                                reg1_i[9] ? 22 : 
                                reg1_i[8] ? 23 :
                                reg1_i[7] ? 24 : 
                                reg1_i[6] ? 25 :
                                reg1_i[5] ? 26 : 
                                reg1_i[4] ? 27 :
                                reg1_i[3] ? 28 : 
                                reg1_i[2] ? 29 :
                                reg1_i[1] ? 30 : 
                                reg1_i[0] ? 31 : 32);      
                 end
                 
                 `SUB_TYPE_CLO: begin
                    arith_res = (reg1_i_not[31] ? 0 : 
                                reg1_i_not[30] ? 1 :
                                reg1_i_not[29] ? 2 : 
                                reg1_i_not[28] ? 3 :
                                reg1_i_not[27] ? 4 : 
                                reg1_i_not[26] ? 5 :
                                reg1_i_not[25] ? 6 : 
                                reg1_i_not[24] ? 7 :
                                reg1_i_not[23] ? 8 : 
                                reg1_i_not[22] ? 9 :
                                reg1_i_not[31] ? 10 : 
                                reg1_i_not[20] ? 11 :
                                reg1_i_not[19] ? 12 : 
                                reg1_i_not[18] ? 13 :
                                reg1_i_not[17] ? 14 : 
                                reg1_i_not[16] ? 15 :
                                reg1_i_not[15] ? 16 : 
                                reg1_i_not[14] ? 17 :
                                reg1_i_not[13] ? 18 : 
                                reg1_i_not[12] ? 19 :
                                reg1_i_not[11] ? 20 : 
                                reg1_i_not[10] ? 21 :
                                reg1_i_not[9] ? 22 : 
                                reg1_i_not[8] ? 23 :
                                reg1_i_not[7] ? 24 : 
                                reg1_i_not[6] ? 25 :
                                reg1_i_not[5] ? 26 : 
                                reg1_i_not[4] ? 27 :
                                reg1_i_not[3] ? 28 : 
                                reg1_i_not[2] ? 29 :
                                reg1_i_not[1] ? 30 : 
                                reg1_i_not[0] ? 31 : 32);  
                 end
                 
                 default: begin
                    arith_res   = `ZeroWord;
                 end
            endcase
        end
    end    
   
    // for mul, mult and multu instruction
    // correct the multiplicand
    always @ (*) begin
        if (aluop_i == `SUB_TYPE_MUL && reg1_i[31] == 1'b1) begin
            multiplicand = ~(reg1_i) + 1;
        end else if (aluop_i == `SUB_TYPE_MULT && reg1_i[31] == 1'b1) begin
            multiplicand = ~(reg1_i) + 1;
        end else begin
            multiplicand = reg1_i;
        end
    end
    
    // correct the multiplier
    always @ (*) begin
        if (aluop_i == `SUB_TYPE_MUL && reg2_i[31] == 1) begin
            multiplier = ~(reg2_i) + 1;
        end else if (aluop_i == `SUB_TYPE_MULT && reg2_i[31] == 1) begin
            multiplier = ~(reg2_i) + 1;
        end else begin
            multiplier = reg2_i;
        end
    end
    
    assign temp_mul_res = multiplicand * multiplier;
    
    // correct the temp_mul_res
    always @ (*) begin
        if (rst == `RstEnable) begin
            mul_res = {`ZeroWord, `ZeroWord};
        end else if (aluop_i == `SUB_TYPE_MUL || aluop_i == `SUB_TYPE_MULT) begin
            if (reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mul_res = ~(temp_mul_res) + 1;
            end else begin
                mul_res = temp_mul_res;
            end 
        end else begin
            mul_res = temp_mul_res;
        end
    end
   
   // type
   always @ (*) begin
        wd_o        = wd_i;
        stallreq    = `NoStop;
        
        // check overflow state
        if ((aluop_i == `SUB_TYPE_ADD || aluop_i == `SUB_TYPE_SUB) && of_check == 1'b1) begin
            wreg_o = `WriteDisable;
        end else begin
            wreg_o = wreg_i;
        end
        
        case (alusel_i)
            `TYPE_LOGIC: begin
                wdata_o = logic_res;
            end
            
            `TYPE_SHIFT: begin
                wdata_o = shift_res;
            end
            
            `TYPE_MOVE: begin
                wdata_o = move_res;
            end
            
            `TYPE_ARITH: begin
                wdata_o = arith_res;
            end
            
            `TYPE_MUL: begin
                wdata_o = mul_res[31:0];
            end
            
            default : begin
                wdata_o = `ZeroWord;
            end
        endcase
    end
        
    // whilo_o check and enable
    always @ (*) begin
        if (rst == `RstEnable) begin
            whilo_o = `WriteDisable;
            hi_o    = `ZeroWord;
            lo_o    = `ZeroWord;
        end else if (aluop_i == `SUB_TYPE_MTHI) begin
            whilo_o = `WriteEnable;
            hi_o    = reg1_i;
            lo_o    = lo_res;
        end else if (aluop_i == `SUB_TYPE_MTLO) begin
            whilo_o = `WriteEnable;
            hi_o    = hi_res;
            lo_o    = reg1_i;
        end else if (aluop_i == `SUB_TYPE_MULT) begin
            whilo_o = `WriteEnable;
            hi_o    = mul_res[63:32];
            lo_o    = mul_res[31:0];
        end else if (aluop_i == `SUB_TYPE_MULTU) begin
            whilo_o = `WriteEnable;
            hi_o    = mul_res[63:32];
            lo_o    = mul_res[31:0];
        end else begin
            whilo_o = `WriteDisable;
            hi_o    = `ZeroWord;
            lo_o    = `ZeroWord;
        end
    end
endmodule
