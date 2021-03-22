`include "defines.v"

module ex(
    input wire                  rst,                      
    
    input wire[`AluOpBus]       aluop_i,      
    input wire[`AluSelBus]      alusel_i, 
    input wire[`RegBus]         reg1_i,     
    input wire[`RegBus]         reg2_i,      
    input wire[`RegAddrBus]     wd_i,        
    input wire                  wreg_i,       
    
    output reg[`RegBus]         wdata_o,      
    output reg[`RegAddrBus]     wd_o,          
    output reg                  wreg_o    
    );
    
    reg[`RegBus]                logic_res;
    reg[`RegBus]                shift_res;
    
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
            
            default : begin
                wdata_o = `ZeroWord;
            end
        endcase
    end
endmodule
