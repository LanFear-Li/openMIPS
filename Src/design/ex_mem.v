`include "defines.v"

module ex_mem(
    input wire                  rst,                      
    input wire                  clk,                      
    
    input wire[`RegBus]         ex_wdata,          
    input wire[`RegAddrBus]     ex_wd,        
    input wire                  ex_wreg,       
    
    input wire                  ex_whilo,      
    input wire[`RegBus]         ex_hi,          
    input wire[`RegBus]         ex_lo, 
    
    input wire[5:0]             stall,

    output reg[`RegBus]         mem_wdata,    
    output reg[`RegAddrBus]     mem_wd,          
    output reg                  mem_wreg,  
    
    output reg                  mem_whilo,      
    output reg[`RegBus]         mem_hi,          
    output reg[`RegBus]         mem_lo   
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_wdata   <= `ZeroWord;
            mem_wd      <= `NOPRegAddr;
            mem_wreg    <= `WriteDisable;
            mem_whilo   <= `WriteDisable;
            mem_hi      <= `ZeroWord;
            mem_lo      <= `ZeroWord;
        end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            mem_wdata   <= `ZeroWord;
            mem_wd      <= `NOPRegAddr;
            mem_wreg    <= `WriteDisable;
            mem_whilo   <= `WriteDisable;
            mem_hi      <= `ZeroWord;
            mem_lo      <= `ZeroWord;                   
        end else if (stall[3] == `NoStop) begin
            mem_wdata   <= ex_wdata;
            mem_wd      <= ex_wd;
            mem_wreg    <= ex_wreg; 
            mem_whilo   <= ex_whilo;
            mem_hi      <= ex_hi;
            mem_lo      <= ex_lo;    
        end
    end 
endmodule
