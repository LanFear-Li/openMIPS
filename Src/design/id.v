`include "defines.v"

module id(
    input wire                  rst,            // reset
    input wire[`InstAddrBus]    pc_i,           // order address
    input wire[`InstBus]        inst_i,         // order itself
    
    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,
    
    output reg                  reg1_read_o,
    output reg                  reg2_read_o,
    output reg[`RegAddrBus]     reg1_addr_o,
    output reg[`RegAddrBus]     reg2_addr_o,
    
    output reg[`AluOpBus]       aluop_o,        // order sub type
    output reg[`AluSelBus]      alusel_o,       // order type
    output reg[`RegBus]         reg1_o,         // first operator 
    output reg[`RegBus]         reg2_o,         // second operator 
    output reg[`RegAddrBus]     wd_o,           // write address
    output reg                  wreg_o,         // weite register
    
    input wire[`RegBus]         ex_wdata_i,      
    input wire[`RegAddrBus]     ex_wd_i,          
    input wire                  ex_wreg_i,   
    
    input wire[`RegBus]         mem_wdata_i,      
    input wire[`RegAddrBus]     mem_wd_i,          
    input wire                  mem_wreg_i   
    );
    
    wire[5:0]                   op          = inst_i[31:26];
    wire[5:0]                   shamt       = inst_i[10:6];
    wire[5:0]                   funt        = inst_i[5:0];
    wire[10:0]                  rs_check    = inst_i[31:21];
    reg[`RegBus]                imm;
    reg                         instvalid;
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            aluop_o     = `SUB_TYPE_NOP;
            alusel_o    = `TYPE_NOP;
            wd_o        = `NOPRegAddr;
            wreg_o      = `WriteDisable;
            instvalid   = `InstInvalid;
            reg1_read_o = 1'b0;
            reg2_read_o = 1'b0;
            reg1_addr_o = `NOPRegAddr;
            reg2_addr_o = `NOPRegAddr;
            imm         = `ZeroWord;
        end else begin
            aluop_o     = `SUB_TYPE_NOP;
            alusel_o    = `TYPE_NOP;
            wd_o        = inst_i[15:11];
            wreg_o      = `WriteDisable;
            instvalid   = `InstValid;
            reg1_read_o = 1'b0;
            reg2_read_o = 1'b0;
            reg1_addr_o = inst_i[25:21];
            reg2_addr_o = inst_i[20:16];
            imm         = `ZeroWord;       
        end
        
        case (op)   
            `OP_SPECIAL: begin
                if (shamt != 5'b00000) begin
                end else begin
                    case (funt)
                    `FUNCT_NOP_AND: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_AND;
                        alusel_o    = `TYPE_LOGIC;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                        
                    end
                    `FUNCT_NOP_OR: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_OR;
                        alusel_o    = `TYPE_LOGIC;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                          
                    end
                    `FUNCT_NOP_XOR: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_XOR;
                        alusel_o    = `TYPE_LOGIC;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                          
                    end
                    `FUNCT_NOP_NOR: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_NOR;
                        alusel_o    = `TYPE_LOGIC;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                          
                    end
                    
                    `FUNCT_NOP_SLLV: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_SLL;
                        alusel_o    = `TYPE_SHIFT;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                          
                    end
                    
                    `FUNCT_NOP_SRLV: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_SRL;
                        alusel_o    = `TYPE_SHIFT;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                          
                    end
                    
                    `FUNCT_NOP_SRAV: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_SRA;
                        alusel_o    = `TYPE_SHIFT;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                          
                    end
                    
                    `FUNCT_NOP_SYNC: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_NOP;
                        alusel_o    = `TYPE_NOP;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                          
                    end
                    default: begin
                    end
                    endcase
                end
            end
            
            `OP_ORI: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_OR;
                alusel_o    = `TYPE_LOGIC;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm         = inst_i[15:0];
                wd_o        = inst_i[20:16];
                instvalid   = `InstValid;
            end
            
            `OP_ANDI: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_AND;
                alusel_o    = `TYPE_LOGIC;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm         = inst_i[15:0];
                wd_o        = inst_i[20:16];
                instvalid   = `InstValid;
            end
            
            `OP_XORI: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_XOR;
                alusel_o    = `TYPE_LOGIC;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm         = inst_i[15:0];
                wd_o        = inst_i[20:16];
                instvalid   = `InstValid;
            end
 
            `OP_LUI: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_LUI;
                alusel_o    = `TYPE_LOGIC;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm         = inst_i[15:0];
                wd_o        = inst_i[20:16];
                instvalid   = `InstValid;
            end
            
            `OP_PREF: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_NOP;
                alusel_o    = `TYPE_NOP;
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                instvalid   = `InstValid;
            end 
                
            default: begin
            end
        endcase   
        
        if (rs_check == 11'b00000000000) begin
            case (funt)
                `FUNCT_NOP_SLL: begin
                    wreg_o      = `WriteEnable;
                    aluop_o     = `SUB_TYPE_SLL;
                    alusel_o    = `TYPE_SHIFT;
                    reg1_read_o = 1'b0;
                    reg2_read_o = 1'b1;
                    imm[4:0]       = inst_i[10:6];
                    instvalid   = `InstValid;
                end
                
                `FUNCT_NOP_SRL: begin
                    wreg_o      = `WriteEnable;
                    aluop_o     = `SUB_TYPE_SRL;
                    alusel_o    = `TYPE_SHIFT;
                    reg1_read_o = 1'b0;
                    reg2_read_o = 1'b1;
                    imm[4:0]    = inst_i[10:6];
                    instvalid   = `InstValid;
                end
                
                `FUNCT_NOP_SRA: begin
                    wreg_o      = `WriteEnable;
                    aluop_o     = `SUB_TYPE_SRA;
                    alusel_o    = `TYPE_SHIFT;
                    reg1_read_o = 1'b0;
                    reg2_read_o = 1'b1;
                    imm[4:0]    = inst_i[10:6];
                    instvalid   = `InstValid;
                end
         
                default: begin
                end
            endcase
        end     
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            reg1_o  = `ZeroWord;
        end else if (reg1_read_o == 1'b1) begin
            if (reg1_addr_o == ex_wd_i && ex_wreg_i == 1'b1) begin
                reg1_o  = ex_wdata_i;
            end else if (reg1_addr_o == mem_wd_i && mem_wreg_i == 1'b1) begin
                reg1_o  = mem_wdata_i;
            end else begin
                reg1_o  = reg1_data_i;
            end
        end else if (reg1_read_o == 1'b0) begin
            reg1_o  = imm;
        end else begin
            reg1_o  = `ZeroWord;
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            reg2_o  = `ZeroWord;
        end else if (reg2_read_o == 1'b1 && ex_wreg_i == 1'b1) begin
            if (reg2_addr_o == ex_wd_i) begin
                reg2_o  = ex_wdata_i;
            end else if (reg2_addr_o == mem_wd_i && mem_wreg_i == 1'b1) begin
                reg2_o  = mem_wdata_i;
            end else begin
                reg2_o  = reg2_data_i;
            end
        end else if (reg2_read_o == 1'b0) begin
            reg2_o  = imm;
        end else begin
            reg2_o  = `ZeroWord;
        end
    end
    
endmodule
