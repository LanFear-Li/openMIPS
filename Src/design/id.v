`include "defines.v"

module id(
    input wire                  rst,            // reset
    input wire[`InstAddrBus]    pc_i,           // order address
    input wire[`InstBus]        inst_i,         // order itself
    
    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,
    
    input wire[`RegBus]         ex_wdata_i,      
    input wire[`RegAddrBus]     ex_wd_i,          
    input wire                  ex_wreg_i,   
    
    input wire[`RegBus]         mem_wdata_i,      
    input wire[`RegAddrBus]     mem_wd_i,          
    input wire                  mem_wreg_i,
    
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
    
    output reg                  stallreq       // pipeline stall request   
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
            stallreq    = `NoStop;
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
            stallreq    = `NoStop;     
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
                    
                    `FUNCT_NOP_MOVN: begin
                        aluop_o     = `SUB_TYPE_MOVN;
                        alusel_o    = `TYPE_MOVE;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;
                        if (reg2_o != `ZeroWord) begin
                            wreg_o  = `WriteEnable;
                        end else begin
                            wreg_o  = `WriteDisable;
                        end                       
                    end
                    
                    `FUNCT_NOP_MOVZ: begin
                        aluop_o     = `SUB_TYPE_MOVZ;
                        alusel_o    = `TYPE_MOVE;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid; 
                        if (reg2_o == `ZeroWord) begin
                            wreg_o  = `WriteEnable;
                        end else begin
                            wreg_o  = `WriteDisable;
                        end                           
                    end
                        
                    `FUNCT_NOP_MFHI: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_MFHI;
                        alusel_o    = `TYPE_MOVE;
                        reg1_read_o = 1'b0;
                        reg2_read_o = 1'b0;
                        instvalid   = `InstValid;                      
                    end
                    
                    `FUNCT_NOP_MFLO: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_MFLO;
                        alusel_o    = `TYPE_MOVE;
                        reg1_read_o = 1'b0;
                        reg2_read_o = 1'b0;
                        instvalid   = `InstValid;                          
                    end
                    
                    `FUNCT_NOP_MTHI: begin
                        wreg_o      = `WriteDisable;
                        aluop_o     = `SUB_TYPE_MTHI;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b0;
                        instvalid   = `InstValid;                          
                    end
                    
                    `FUNCT_NOP_MTLO: begin
                        wreg_o      = `WriteDisable;
                        aluop_o     = `SUB_TYPE_MTLO;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b0;
                        instvalid   = `InstValid;                          
                    end
                    
                    `FUNCT_NOP_ADD: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_ADD;
                        alusel_o    = `TYPE_ARITH;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                         
                    end
                    
                    `FUNCT_NOP_ADDU: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_ADDU;
                        alusel_o    = `TYPE_ARITH;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                         
                    end
                    
                    `FUNCT_NOP_SUB: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_SUB;
                        alusel_o    = `TYPE_ARITH;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                         
                    end
                    
                    `FUNCT_NOP_SUBU: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_SUBU;
                        alusel_o    = `TYPE_ARITH;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                         
                    end
                    
                    `FUNCT_NOP_SLT: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_SLT;
                        alusel_o    = `TYPE_ARITH;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                         
                    end
                    
                    `FUNCT_NOP_SLTU: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_SLTU;
                        alusel_o    = `TYPE_ARITH;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                         
                    end
                    
                    `FUNCT_NOP_MULT: begin
                        wreg_o      = `WriteDisable;
                        aluop_o     = `SUB_TYPE_MULT;
                        alusel_o    = `TYPE_MUL;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                         
                    end
                    
                    `FUNCT_NOP_MULTU: begin
                        wreg_o      = `WriteDisable;
                        aluop_o     = `SUB_TYPE_MULTU;
                        alusel_o    = `TYPE_MUL;
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
            
            `OP_ADDI: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_ADD;
                alusel_o    = `TYPE_ARITH;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm         = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o        = inst_i[20:16];
            end 
            
            `OP_ADDIU: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_ADDU;
                alusel_o    = `TYPE_ARITH;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm         = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o        = inst_i[20:16];
            end 
            
            `OP_SLTI: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_SLT;
                alusel_o    = `TYPE_ARITH;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm         = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o        = inst_i[20:16];
                instvalid   = `InstValid; 
            end 
            
            `OP_SLTIU: begin
                wreg_o      = `WriteEnable;
                aluop_o     = `SUB_TYPE_SLTU;
                alusel_o    = `TYPE_ARITH;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm         = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o        = inst_i[20:16];
                instvalid   = `InstValid;
            end 
            
            `OP_SSPECIAL: begin
                if (shamt != 5'b00000) begin
                end else begin
                    case (funt)
                    `FUNCT_NOP_CLZ: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_CLZ;
                        alusel_o    = `TYPE_ARITH;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                        
                    end
                    
                    `FUNCT_NOP_CLO: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_CLO;
                        alusel_o    = `TYPE_ARITH;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                   
                    end
                    
                    `FUNCT_NOP_MUL: begin
                        wreg_o      = `WriteEnable;
                        aluop_o     = `SUB_TYPE_MUL;
                        alusel_o    = `TYPE_MUL;
                        reg1_read_o = 1'b1;
                        reg2_read_o = 1'b1;
                        instvalid   = `InstValid;                        
                    end
                    
                    default: begin
                    end
                    endcase
                end
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
    
    // reg1 pipeline issue
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
    
    // reg2 pipeline issue
    always @ (*) begin
        if (rst == `RstEnable) begin
            reg2_o  = `ZeroWord;
        end else if (reg2_read_o == 1'b1) begin
            if (reg2_addr_o == ex_wd_i && ex_wreg_i == 1'b1) begin
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
