`include "defines.v"

module regfile(
    input wire                  clk,
    input wire                  rst,
    
    input wire[`RegAddrBus]     waddr,  // write address
    input wire[`RegBus]         wdata,  // write data
    input wire                  we,     // write enable
    
    input wire[`RegAddrBus]     raddr1, // read address
    output reg[`RegBus]         rdata1, // read data
    input wire                  re1,    // read enable
    
    input wire[`RegAddrBus]     raddr2,
    output reg[`RegBus]         rdata2,
    input wire                  re2
    );
    
    reg[`RegBus] regs[0:`RegNum - 1];
    
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if (we == `WriteEnable && waddr != `RegNumLog2'h0) begin
                regs[waddr] <= wdata;
            end 
        end
    end 
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata1 <= `ZeroWord;
        end else if (raddr1 == `RegNumLog2'h0) begin
            rdata1 <= `ZeroWord;
        end else if (raddr1 == waddr && re1 == `ReadEnable && we == `WriteEnable) begin
            rdata1 <= wdata;
        end else if (re1 == `ReadEnable) begin
            rdata1 <= regs[raddr1];
        end begin
            rdata1 <= `ZeroWord;
        end 
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata2 <= `ZeroWord;
        end else if (raddr2 == `RegNumLog2'h0) begin
            rdata2 <= `ZeroWord;
        end else if (raddr2 == waddr && re2 == `ReadEnable && we == `WriteEnable) begin
            rdata2 <= wdata;
        end else if (re2 == `ReadEnable) begin
            rdata2 <= regs[raddr2];
        end begin
            rdata2 <= `ZeroWord;
        end 
    end
endmodule
