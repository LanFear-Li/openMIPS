`include "defines.v"

module openmips(
    input wire                  rst,                      
    input wire                  clk,                      
    
    input wire[`InstBus]        rom_data_i,               
        
    output wire[`InstAddrBus]   rom_addr_o,          
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
    
    wire                        ex_whilo_o;      
    wire[`RegBus]               ex_hi_o;          
    wire[`RegBus]               ex_lo_o;   

    wire[`RegBus]               mem_wdata_i;      
    wire[`RegAddrBus]           mem_wd_i;          
    wire                        mem_wreg_i;
  
    wire                        mem_whilo_i;      
    wire[`RegBus]               mem_hi_i;          
    wire[`RegBus]               mem_lo_i; 
        
    wire[`RegBus]               mem_wdata_o;      
    wire[`RegAddrBus]           mem_wd_o;          
    wire                        mem_wreg_o;   

    wire                        mem_whilo_o;      
    wire[`RegBus]               mem_hi_o;          
    wire[`RegBus]               mem_lo_o; 
        
    wire[`RegBus]               wb_wdata_i;      
    wire[`RegAddrBus]           wb_wd_i;          
    wire                        wb_wreg_i;   
    
    wire                        wb_whilo_i;      
    wire[`RegBus]               wb_hi_i;          
    wire[`RegBus]               wb_lo_i;  
        
    wire                        hilo_whilo_i;      
    wire[`RegBus]               hilo_hi_i;          
    wire[`RegBus]               hilo_lo_i;    
    
    wire                        hilo_whilo_o;      
    wire[`RegBus]               hilo_hi_o;          
    wire[`RegBus]               hilo_lo_o;         
    
    wire                        reg1_read;      
    wire                        reg2_read;      
    wire[`RegBus]               reg1_data;      
    wire[`RegBus]               reg2_data;      
    wire[`RegAddrBus]           reg1_addr; 
    wire[`RegAddrBus]           reg2_addr; 
    
    wire                        id_stallreq_ctrl;
    wire                        ex_stallreq_ctrl;
    
    wire[5:0]                   ctrl_stall;
    
    pc_reg pc_reg0(
        .clk(clk), .rst(rst), 
        
        .stall(ctrl_stall),
        
        .pc(rom_addr_o), .ce(rom_ce_o)
    );
    
    if_id if_id0(
        .clk(clk), .rst(rst), 
        
        .stall(ctrl_stall),
        
        .if_pc(rom_addr_o), .if_inst(rom_data_i),
        .id_pc(id_pc_i), .id_inst(id_inst_i)  
    );
    
    id id0(
        .rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i),
        
        .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
        .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
        
        .aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
        .wd_o(id_wd_o), .wreg_o(id_wreg_o),
        
        .ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o), .ex_wreg_i(ex_wreg_o),
        .mem_wdata_i(mem_wdata_o), .mem_wd_i(mem_wd_o), .mem_wreg_i(mem_wreg_o),
        
        .stallreq(id_stallreq_ctrl)
    );
    
    regfile regfile0(
        .clk(clk), .rst(rst), 
        
        .waddr(wb_wd_i), .wdata(wb_wdata_i), .we(wb_wreg_i),
        .raddr1(reg1_addr), .rdata1(reg1_data), .re1(reg1_read),
        .raddr2(reg2_addr), .rdata2(reg2_data), .re2(reg2_read)
    );
    
    id_ex id_ex0(
        .clk(clk), .rst(rst), 
        
        .stall(ctrl_stall),
        
        .id_aluop(id_aluop_o), .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
        .id_wd(id_wd_o), .id_wreg(id_wreg_o),
        
        .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i)    
    );
    
    ex ex0(
        .rst(rst),
        
        .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),
        
        .hi_i(hilo_hi_o), .lo_i(hilo_lo_o),
        .mem_whilo_i(mem_whilo_o), .mem_hi_i(mem_hi_o), .mem_lo_i(mem_lo_o),
        .wb_whilo_i(wb_whilo_i), .wb_hi_i(wb_hi_i), .wb_lo_i(wb_lo_i),
        
        .wdata_o(ex_wdata_o), .wd_o(ex_wd_o), .wreg_o(ex_wreg_o),
        .whilo_o(ex_whilo_o), .hi_o(ex_hi_o), .lo_o(ex_lo_o),
        
        .stallreq(ex_stallreq_ctrl)
    );
    
    ex_mem ex_mem0(
        .clk(clk), .rst(rst), 
        
        .stall(ctrl_stall),
        
        .ex_wdata(ex_wdata_o), .ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o),
        .ex_whilo(ex_whilo_o), .ex_hi(ex_hi_o), .ex_lo(ex_lo_o),
                
        .mem_wdata(mem_wdata_i), .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i),
        .mem_whilo(mem_whilo_i), .mem_hi(mem_hi_i), .mem_lo(mem_lo_i)
    );
    
    mem mem0(
        .rst(rst), 
          
        .wdata_i(mem_wdata_i), .wd_i(mem_wd_i), .wreg_i(mem_wreg_i),
        .whilo_i(mem_whilo_i), .hi_i(mem_hi_i), .lo_i(mem_lo_i),
        
        .wdata_o(mem_wdata_o), .wd_o(mem_wd_o), .wreg_o(mem_wreg_o),
        .whilo_o(mem_whilo_o), .hi_o(mem_hi_o), .lo_o(mem_lo_o)
    );
    
    mem_wb mem_wb0(
        .clk(clk), .rst(rst), 
                
        .stall(ctrl_stall),        
                
        .mem_wdata(mem_wdata_o), .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o),
        .mem_whilo(mem_whilo_o), .mem_hi(mem_hi_o), .mem_lo(mem_lo_o),

        .wb_wdata(wb_wdata_i), .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i),
        .wb_whilo(hilo_whilo_i), .wb_hi(hilo_hi_i), .wb_lo(hilo_lo_i)
    );
    
    hilo_reg hilo_reg0(
        .clk(clk), .rst(rst), 
                
        .we(hilo_whilo_i), .hi_i(hilo_hi_i), .lo_i(hilo_lo_i),

        .hi_o(hilo_hi_o), .lo_o(hilo_lo_o)     
    ); 
    
    ctrl ctrl0(
        .rst(rst), 
                
        .stallreq_from_id(id_stallreq_ctrl), .stallreq_from_ex(ex_stallreq_ctrl),

        .stall(ctrl_stall)   
    );
endmodule
