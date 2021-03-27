`include "defines.v"

module hilo_reg(
    input wire                  clk,
    input wire                  rst,
    
    input wire                  we,     // register write enable signal
    input wire[`RegBus]         hi_i,   // input hi value
    input wire[`RegBus]         lo_i,   // input lo value
    
    output reg[`RegBus]         hi_o,   // output hi value 
    output reg[`RegBus]         lo_o    // output lo value
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;   
        end else if (we == `WriteEnable) begin
            hi_o = hi_i;
            lo_o = lo_i;           
        end
    end
endmodule
