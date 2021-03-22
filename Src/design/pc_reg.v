`include "defines.v"

module pc_reg(
    input wire               clk,
    input wire               rst,
    output reg[`InstAddrBus] pc,    // program counter
    output reg               ce     
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;
        end else begin
            ce <= `ChipEnable;
        end
    end
    
     always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 32'h00000000;
        end else begin
            pc <= pc + 4;
        end
    end
endmodule
