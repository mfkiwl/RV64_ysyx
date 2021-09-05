

`include "defines.v"


module ram(input wire clk,
           input wire rst,
           input wire [7 : 0] inst_opcode,
           input wire [63 : 0] mem_addr,
           input wire mem_w_ena,
           input wire [63 : 0] mem_w_data,
           output reg [63 : 0] pc,
           output reg [31 : 0] inst,
           input wire mem_r_ena,
           output reg [63:0] mem_r_data);
    
    parameter PC_START_RESET = `PC_START - 4;
    reg   [`MEM_BUS]ram_w_mask;
    reg   [`MEM_BUS]ram_w_data;
    reg   [`MEM_BUS]ram_r_data;
    wire  [`MEM_BUS]ram_w_addr;
    wire  [`MEM_BUS]ram_r_addr;
    assign ram_w_addr = mem_addr - `PC_START;
    assign ram_r_addr = mem_addr - `PC_START;
    
    
    always @(*)begin
        case (inst_opcode)
            `INST_LD:begin
                
                mem_r_data = ram_r_data[63:0];
                    
            end

            `INST_LW,`INST_LWU:begin
                
                if (ram_r_addr[2] == 1'b0)begin
                    mem_r_data = {32'b0,ram_r_data[31:0]};
                    
                end
                else if (ram_w_addr[2] == 1'b1)begin
                    
                    mem_r_data = {32'b0,ram_r_data[63:32]};
                end
                else begin
                    
                    mem_r_data = 64'h0000_0000_0000_0000;
                end
                
            end

            `INST_LH,`INST_LHU:begin
                
                if (ram_r_addr[2] == 1'b0)begin
                    if (ram_r_addr[1] == 1'b0)begin
                        mem_r_data = {48'b0,ram_r_data[15:0]};
                    end
                    else begin
                        mem_r_data = {48'b0,ram_r_data[31:16]};
                    end
                    
                end
                else if (ram_w_addr[2] == 1'b1)begin
                    
                   if (ram_r_addr[1] == 1'b0)begin
                        mem_r_data = {48'b0,ram_r_data[47:32]};
                    end
                    else begin
                        mem_r_data = {48'b0,ram_r_data[63:48]};
                    end

                end
                else begin
                    
                    mem_r_data = 64'h0000_0000_0000_0000;
                end
                
            end

            `INST_LB,`INST_LBU:begin
                
                if (ram_r_addr[2] == 1'b0)begin
                    if (ram_r_addr[1] == 1'b0)begin
                        mem_r_data = ram_r_addr[0] == 1'b0 ? {56'b0,ram_r_data[7:0]} : {56'b0,ram_r_data[15:8]};
                    end
                    else begin
                        mem_r_data = ram_r_addr[0] == 1'b0 ? {56'b0,ram_r_data[23:16]} : {56'b0,ram_r_data[31:24]};
                        
                    end
                    
                end
                else if (ram_w_addr[2] == 1'b1)begin
                    
                   if (ram_r_addr[1] == 1'b0)begin
                        mem_r_data = ram_r_addr[0] == 1'b0 ? {56'b0,ram_r_data[39:32]} : {56'b0,ram_r_data[47:40]};
                    end
                    else begin
                        mem_r_data = ram_r_addr[0] == 1'b0 ? {56'b0,ram_r_data[55:48]} : {56'b0,ram_r_data[63:56]};
                        
                    end

                end
                else begin
                    
                    mem_r_data = 64'h0000_0000_0000_0000;
                end
                
            end
            default:
            begin
                mem_r_data = `ZERO_WORD;
            end
        endcase
    end
    
    always @(*)begin
        case(inst_opcode)
            `INST_SD:begin
                
                
                if (mem_w_ena != 1'b0 )begin
                    ram_w_mask = 64'hffff_ffff_ffff_ffff;
                    ram_w_data = {mem_w_data[63:0]};
                    
                end
                else begin
                    ram_w_mask = 64'h0000_0000_0000_0000;
                    ram_w_data = 64'h0000_0000_0000_0000;
                end
            end
            `INST_SW:begin
                
                
                if (mem_w_ena != 1'b0 && ram_w_addr[2] == 1'b0)begin
                    ram_w_mask = 64'h0000_0000_ffff_ffff;
                    ram_w_data = {32'b0,mem_w_data[31:0]};
                    
                end
                else if (mem_w_ena != 1'b0 && ram_w_addr[2] == 1'b1)begin
                    ram_w_mask = 64'hffff_ffff_0000_0000;
                    ram_w_data = {mem_w_data[31:0],32'b0};
                end
                else begin
                    ram_w_mask = 64'h0000_0000_0000_0000;
                    ram_w_data = 64'h0000_0000_0000_0000;
                end
            end
            `INST_SH:begin
                
                if (mem_w_ena != 1'b0 && ram_w_addr[2] == 1'b0)begin
                    if (ram_w_addr[1] == 1'b0)
                    begin
                        ram_w_mask = 64'h0000_0000_0000_ffff;
                        ram_w_data = {48'b0,mem_w_data[15:0]};
                    end
                    else begin
                        ram_w_mask = 64'h0000_0000_ffff_0000;
                        ram_w_data = {32'b0,mem_w_data[15:0],16'b0};
                    end
                    
                    
                end
                else if (mem_w_ena != 1'b0 && ram_w_addr[2] == 1'b1)begin
                    
                    if (ram_w_addr[1] == 1'b0)
                    begin
                        ram_w_mask = 64'h0000_ffff_0000_0000;
                        ram_w_data = {16'b0,mem_w_data[15:0],32'b0};
                    end
                    else begin
                        ram_w_mask = 64'hffff_0000_0000_0000;
                        ram_w_data = {mem_w_data[15:0],48'b0};
                    end
                    
                end
                end
            `INST_SB:begin
                
                if (mem_w_ena != 1'b0 && ram_w_addr[2] == 1'b0)begin
                    if (ram_w_addr[1] == 1'b0)
                    begin
                        ram_w_mask = ram_w_addr[0] == 1'b0 ? 64'h0000_0000_0000_00ff : 64'h0000_0000_0000_ff00;
                        ram_w_data = ram_w_addr[0] == 1'b0 ? {56'b0,mem_w_data[7:0]} : {48'b0,mem_w_data[7:0],8'b0};
                    end
                    else begin
                        ram_w_mask = ram_w_addr[0] == 1'b0 ? 64'h0000_0000_00ff_0000 : 64'h0000_0000_ff00_0000;
                        ram_w_data = ram_w_addr[0] == 1'b0 ? {40'b0,mem_w_data[7:0],16'b0} : {32'b0,mem_w_data[7:0],24'b0};
                    end
                    
                    
                end
                else if (mem_w_ena != 1'b0 && ram_w_addr[2] == 1'b1)begin
                    
                    if (ram_w_addr[1] == 1'b0)
                    begin
                        ram_w_mask = ram_w_addr[0] == 1'b0 ? 64'h0000_00ff_0000_0000 : 64'h0000_ff00_0000_0000;
                        ram_w_data = ram_w_addr[0] == 1'b0 ? {24'b0,mem_w_data[7:0],32'b0} : {16'b0,mem_w_data[7:0],40'b0};
                    end
                    else begin
                        ram_w_mask = ram_w_addr[0] == 1'b0 ? 64'h00ff_0000_0000_0000 : 64'hff00_0000_0000_0000;
                        ram_w_data = ram_w_addr[0] == 1'b0 ? {8'b0,mem_w_data[7:0],48'b0} : {mem_w_data[7:0],56'b0};
                    end
                    
                end
                else begin
                    ram_w_mask = 64'h0000_0000_0000_0000;
                    ram_w_data = 64'h0000_0000_0000_0000;
                end
            end
            
             default:
            begin
                ram_w_data = `ZERO_WORD;
                ram_w_mask = `ZERO_WORD;
            end
        endcase
    end
    
    // Access memory
    reg [63:0] idata;
    //reg [63:0] rdata;
    RAMHelper RAMHelper(
    .clk              (clk),
    .en               (1),
    .iIdx             ((pc - `PC_START) >> 3),
    .idata            (idata),
    .rIdx             (ram_r_addr >> 3),
    .rdata            (ram_r_data),
    .ren              (mem_r_ena),
    .wIdx             (ram_w_addr >> 3),
    .wdata            (ram_w_data),
    .wmask            (ram_w_mask),
    .wen              (mem_w_ena)
    );
    assign inst = pc[2] ? idata[63 : 32] : idata[31 : 0];
    
endmodule
