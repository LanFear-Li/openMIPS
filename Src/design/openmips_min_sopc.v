`include "defines.v"

module openmips_min_sopc(
    input wire                  rst,                      
    input wire                  clk  
    );
    
    wire[`InstAddrBus]          inst_addr;
    wire                        rom_ce;
    wire[`InstBus]              inst;
     
    openmips openmips0(
        .clk(clk), .rst(rst),
        .rom_data_i(inst), .rom_addr_o(inst_addr), 
        .rom_ce_o(rom_ce)         
    );
    
    inst_rom inst_rom0(
        .inst(inst), .addr(inst_addr), 
        .ce(rom_ce)         
    );
    
endmodule
