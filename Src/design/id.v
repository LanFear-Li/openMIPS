`include "defines.v"

module id(
    input wire                  rst,            // reset
    input wire[`InstAddrBus]    pc_i,           // order address
    input wire[`InstBus]        inst_i,         // order itself
    
    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,
    
    output reg[`RegBus]         reg1_read_o,
    output reg[`RegBus]         reg2_read_o,
    output reg[`RegAddrBus]     reg1_addr_o,
    output reg[`RegAddrBus]     reg2_addr_o,
    
    output reg[`AluOpBus]       aluop_o,        // order sub type
    output reg[`AluSelBus]      alusel_o,       // order type
    output reg[`RegBus]         reg1_o,         // first operator 
    output reg[`RegBus]         reg2_o,         // second operator 
    output reg[`RegAddrBus]     wd_o,           // write address
    output reg                  wreg_o          // weite register
    );
    
    wire[5:0] op = inst_i[31:26];
    reg[`RegBus] imm;
    reg instvalid;
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            aluop_o     <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o        <= `NOPRegAddr;
            wreg_o      <= `WriteDisable;
            instvalid   <= `InstInvalid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            imm         <= `ZeroWord;
        end else begin
            aluop_o     <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o        <= inst_i[15:11];
            wreg_o      <= `WriteDisable;
            instvalid   <= `InstValid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_i[25:21];
            reg2_addr_o <= inst_i[20:16];
            imm         <= `ZeroWord;          
        end
        
        case (op) 
            `EXE_ORI: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <= inst_i[15:0];
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end
            
            default: begin
            end
        endcase        
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
        end else if (reg1_read_o == 1'b0) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
endmodule
