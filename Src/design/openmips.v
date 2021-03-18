module openmips(
    input wire                  rst,                      
    input wire                  clk,                      
    
    input wire[`RegBus]         rom_data_i,               
    
    output wire[`RegBus]        rom_data_o,      
    output wire[`RegAddrBus]    rom_addr_o,          
    output wire                 rom_ce_o    
    );
    
    wire[`InstAddrBus]          pc;
    wire[`InstAddrBus]          id_pc_i;
    wire[`InstAddrBus]          id_inst_i;
    
    wire[`AluOpBus]             id_aluop_o; 
    wire[`AluSelBus]            id_alusel_o; 
    wire[`RegBus]               id_reg1_o;     
    wire[`RegBus]               id_reg2_o;      
    wire[`RegAddrBus]           id_wd_o;        
    wire                        id_wreg_o;
       
    wire[`AluOpBus]             ex_aluop_i; 
    wire[`AluSelBus]            ex_alusel_i; 
    wire[`RegBus]               ex_reg1_i;     
    wire[`RegBus]               ex_reg2_i;      
    wire[`RegAddrBus]           ex_wd_i;        
    wire                        ex_wreg_i;
    
    wire[`RegBus]               ex_wdata_o;      
    wire[`RegAddrBus]           ex_wd_o;          
    wire                        ex_wreg_o;

    wire[`RegBus]               mem_wdata_i;      
    wire[`RegAddrBus]           mem_wd_i;          
    wire                        mem_wreg_i;
    
    wire[`RegBus]               mem_wdata_o;      
    wire[`RegAddrBus]           mem_wd_o;          
    wire                        mem_wreg_o;   
    
    wire[`RegBus]               wb_wdata_i;      
    wire[`RegAddrBus]           wb_wd_i;          
    wire                        wb_wreg_i;   
    
    wire                        reg1_read;      
    wire                        reg2_read;      
    wire[`RegBus]               reg1_data;      
    wire[`RegBus]               reg2_data;      
    wire[`RegAddrBus]           reg1_addr; 
    wire[`RegAddrBus]           reg2_addr; 
    
    pc_reg pc_reg0(
        .clk(clk), .rst(rst), 
        
        .pc(pc), .ce(rom_ce_o)
    );
    
    if_id if_id0(
        .clk(clk), .rst(rst), 
        
        .if_pc(pc), .if_inst(rom_data_i),
        .id_pc(id_pc_i), .id_inst(id_inst_i)  
    );
    
    id id0(
        .rst(rst), .pc_i(id_pc), .inst_i(id_inst_i),
        
        .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
        .reg1_read_i(reg1_read), .reg2_read_i(reg2_read),
        .reg1_addr_i(reg1_addr), .reg2_addr_i(reg2_addr),
        
        .aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
        .wd_o(id_wd_o), .wreg_o(id_wreg_o)
    );
    
    regfile regfile0(
        .clk(clk), .rst(rst), 
        
        .waddr(wb_wd), .wdata(wb_wdata), .we(wb_wreg),
        .raddr1(reg1_addr), .rdata1(reg1_data), .re1(reg1_read),
        .raddr2(reg2_addr), .rdata2(reg2_data), .re2(reg2_read)
    );
    
    id_ex id_ex0(
        .clk(clk), .rst(rst), 
        
        .id_aluop(id_aluop_o), .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
        .id_wd(id_wd_o), .id_wreg(id_wreg_o),
        
        .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i)    
    );
    
    ex ex0(
        
    );
    
endmodule
