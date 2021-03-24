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
    output reg[`RegBus]         lo_o    
    );
    
    reg[`RegBus]                logic_res;
    reg[`RegBus]                shift_res;
    reg[`RegBus]                move_res;
    reg[`RegBus]                hi_res;
    reg[`RegBus]                lo_res;
    
    reg                         tmp;
    reg[4:0]                    i;
    
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
                    move_res    = hi_i;
                 end
                 `SUB_TYPE_MFLO: begin
                    move_res    = lo_i;
                 end
                 
                 default : begin
                    move_res    = `ZeroWord;
                 end
            endcase
        end
    end
    
   // type
   always @ (*) begin
        wd_o    = wd_i;
        wreg_o  = wreg_i;
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
            
            default : begin
                wdata_o = `ZeroWord;
            end
        endcase
    end

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
        
    // whilo_o check and enable
    always @ (*) begin
        if (rst == `RstEnable) begin
            whilo_o = `WriteDisable;
            hi_o    = `ZeroWord;
            lo_o    = `ZeroWord;
        end else if (alusel_i == `SUB_TYPE_MTHI) begin
            whilo_o = `WriteEnable;
            hi_o    = reg1_i;
            lo_o    = lo_res;
        end else if (alusel_i == `SUB_TYPE_MTLO) begin
            whilo_o = `WriteEnable;
            hi_o    = hi_res;
            lo_o    = reg1_i;
        end else begin
            whilo_o = `WriteDisable;
            hi_o    = `ZeroWord;
            lo_o    = `ZeroWord;
        end
    end
endmodule
