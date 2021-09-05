
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */
/* verilator lint_off PINMISSING */
/* verilator lint_off UNOPTFLAT */
//--xuezhen--

`include "defines.v"

module id_stage(input wire rst,
                input wire clk,
                input wire [31 : 0]inst,
                input wire [`REG_BUS]rs1_data,
                input wire [`REG_BUS]rs2_data,
                output reg  inst_j_en,
                output reg  inst_jr_en,
                output wire rs1_r_ena,
                output wire [4 : 0]rs1_r_addr,
                output wire rs2_r_ena,
                output wire [4 : 0]rs2_r_addr,
                output wire rd_w_ena,
                output wire [4 : 0]rd_w_addr,
                output wire mem_w_ena,
                output wire mem_r_ena,
                output wire [4 : 0]inst_type,
                output wire [7 : 0]inst_opcode,
                output wire [`REG_BUS]op1,
                output wire [`REG_BUS]op2,
                output wire i_skip);
    
    
    /* wire inst_addi = ~opcode[2] & ~opcode[3] & opcode[4] & ~opcode[5] & ~opcode[5]
     & ~func3[0] & ~func3[1] & ~func3[2];
     
     // arith inst: 10000; logic: 01000;
     // load-store: 00100; j: 00010;  sys: 000001
     assign inst_type[4] = (rst == 1'b1) ? 0 : inst_addi;
     
     assign inst_opcode[0] = (rst == 1'b1) ? 0 : inst_addi;
     assign inst_opcode[1] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[2] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[3] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[4] = (rst == 1'b1) ? 0 : inst_addi;
     assign inst_opcode[5] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[6] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[7] = (rst == 1'b1) ? 0 : 0;
     
     // I-type
     wire [6  : 0]opcode;
     wire [4  : 0]rd;
     wire [2  : 0]func3;
     wire [4  : 0]rs1;
     wire [11 : 0]imm;
     assign opcode = inst[6  :  0];
     assign rd     = inst[11 :  7];
     assign func3  = inst[14 : 12];
     assign rs1    = inst[19 : 15];
     assign imm    = inst[31 : 20];
     
     
     assign rs1_r_ena  = (rst == 1'b1) ? 0 : inst_type[4];
     assign rs1_r_addr = (rst == 1'b1) ? 0 : (inst_type[4] == 1'b1 ? rs1 : 0);
     assign rs2_r_ena  = 0;
     assign rs2_r_addr = 0;
     
     assign rd_w_ena  = (rst == 1'b1) ? 0 : inst_type[4];
     assign rd_w_addr = (rst == 1'b1) ? 0 : (inst_type[4] == 1'b1 ? rd  : 0);
     
     assign op1 = (rst == 1'b1) ? 0 : (inst_type[4] == 1'b1 ? rs1_data : 0);
     assign op2 = (rst == 1'b1) ? 0 : (inst_type[4] == 1'b1 ? { {52{imm[11]}}, imm } : 0);
     */
    wire [6  : 0]opcode = inst[6  :  0];
    wire [4  : 0]rd     = inst[11 :  7];
    wire [2  : 0]func3  = inst[14 : 12];
    wire [4  : 0]rs1    = inst[19 : 15];
    wire [11 : 0]imm    = inst[31 : 20];
    wire [19 : 0]U_imm  = inst[31 : 12];
    wire [6  : 0]func7  = inst[31 : 25];
    wire [4  : 0]rs2    = inst[24 : 20];
    wire [11:0] SB_imm  = {inst[31], inst[7], inst[30:25], inst[11:8]};
    wire [19:0] J_imm   = {inst[31], inst[19:12], inst[20], inst[30:21]};
    wire[11:0] S_imm   = {inst[31:25], inst[11:7]};
    integer fd;
    reg [7:0]counter  ;

    // initial begin
    //     fd = $fopen("/home/lsy/proj/log.txt","w");
    //     counter = 8'h00;
    // end
    always @(negedge clk) begin
        if (i_skip == 1)begin
            $write("%s",rs1_data[7:0]);

        end
    end

    always @(*) begin
        if (rst == 1'b1) begin
            rs1_r_ena  = 1'b0;
                    rs1_r_addr = 0;
                    rs2_r_ena  = 0;
                    rs2_r_addr = 0;
                    rd_w_ena   = 1'b0;
                    rd_w_addr  = 0;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_jr_en = 1'b0;
                    inst_j_en  = 1'b0;
                    i_skip     = 1'b0;   
        end
        else begin
            case (opcode)
                `INST_I : begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 0;
                    rs2_r_addr = 0;
                    rd_w_ena   = 1'b1;
                    rd_w_addr  = rd;
                    
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_jr_en = 1'b0;
                    inst_j_en  = 1'b0;
                    i_skip     = 1'b0;
                    // $display("ss");
                    case (func3)
                        `ADDI:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_ADD ;
                            inst_type[4:0]   = `ARITH;
                            op1              = rs1_data;
                            op2              = {{52{imm[11]}}, imm } ;
                            
                            // $fwrite(fd,"%s",rs1_data);
                        end
                        `ORI:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_OR ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = {{52{imm[11]}}, imm } ;
                        end
                        `ANDI:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_AND ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = {{52{imm[11]}}, imm } ;
                        end

                        `SLLI:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SLL ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = {58'b0, imm[5:0] } ;
                            // op2              = {59'b0, 5'h1f } ;
                            // inst_jr_en = 1'b1;
                        end

                        `SRLI:begin
                            
                            case(func7)
                                `FUN7_SRL , 7'b0000001:begin
                                    
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SRL ;
                                    inst_type[4:0]   = `LOGIC;
                                    op1              = rs1_data;
                                    op2              = {58'b0, imm[5:0] } ;
                                    
                                end
                                
                                `FUN7_SRA ,7'b0100001:begin
                                    
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SRA ;
                                    inst_type[4:0]   = `LOGIC;
                                    op1              = rs1_data;
                                    op2              = {58'b0, imm[5:0] } ;
                                    
                                end
                                
                                
                                default:begin
                                    
                                end
                            endcase
             
                        end

                        `SLTIU:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SLTU ;
                            inst_type[4:0]   = `ARITH;
                            op1              = rs1_data;
                            op2              = {{52{imm[11]}}, imm } ;
                        end
                        
                        `SLTI:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SLT ;
                            inst_type[4:0]   = `ARITH;
                            op1              = rs1_data;
                            op2              = {{52{imm[11]}}, imm } ;
                        end
                        
                        `XOR:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_XOR ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = {{52{imm[11]}}, imm };
                        end
                  
                        default:begin
                            inst_opcode = 8'b00000000;
                        end
                        
                    endcase
                    
                end
                `INST_64I : begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 1'b1;
                    rs2_r_addr = rs2;
                    rd_w_ena   = 1'b1;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_j_en = 1'b0;
                    inst_jr_en = 1'b0;
                    i_skip     = 1'b0;
                    case (func3)
                        `ADDIW:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_ADDIW ;
                            inst_type[4:0]   = `ARITH;
                            op1              = rs1_data;
                            op2              = {{52{imm[11]}}, imm } ;
                        end
                        `SLLIW:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SLLIW ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = {{59{imm[4]}}, imm[4:0] };
                        end

                        `SRLW:begin
                            
                            case(func7)
                                `FUN7_SRL:begin
                                    
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SRLIW ;
                                    inst_type[4:0]   = `LOGIC;
                                    op1              = rs1_data;
                                    op2              = {{59{imm[4]}}, imm[4:0] };
                                    
                                end
                                
                                `FUN7_SRA:begin
                                    
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SRAIW ;
                                    inst_type[4:0]   = `LOGIC;
                                    op1              = rs1_data;
                                    op2              = {{59{imm[4]}}, imm[4:0] };
                                    
                                end
                                
                                
                                default:begin
                                    inst_opcode[7:0] = `ZERO_BYTE;
                                    inst_type[4:0]   = 5'b00000;
                                    op1              = `ZERO_WORD;
                                    op2              = `ZERO_WORD;
                                end
                            endcase

                            end
                        
                        default:begin
                            inst_opcode = 8'b00000000;
                        end
                        
                    endcase
                    
                end
                `INST_R : begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 1'b1;
                    rs2_r_addr = rs2;
                    rd_w_ena   = 1'b1;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_j_en  = 1'b0;
                    inst_jr_en = 1'b0;
                    i_skip     = 1'b0;
                    case (func3)
                        `ADD:begin
                            case(func7)
                                `FUN7_ADD:begin
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_ADD ;
                                    inst_type[4:0]   = `ARITH;
                                    op1              = rs1_data;
                                    op2              = rs2_data ;
                                end
                                `FUN7_SUB:begin
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SUB ;
                                    inst_type[4:0]   = `ARITH;
                                    op1              = rs1_data;
                                    op2              = rs2_data ;
                                end
                                default:begin
                                    inst_opcode[7:0] = `ZERO_BYTE;
                                    inst_type[4:0]   = 5'b0;
                                    op1              = `ZERO_WORD;
                                    op2              = `ZERO_WORD ;
                                end
                                
                            endcase
                            
                            
                            
                        end
                        `OR:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_OR ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = rs2_data ;
                        end
                        `AND:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_AND ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = rs2_data ;
                        end
                        `SLL:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SLL ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = rs2_data ;
                        end
                        `SRL:begin
                            
                            case(func7)
                                `FUN7_SRL:begin
                                    
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SRL ;
                                    inst_type[4:0]   = `LOGIC;
                                    op1              = rs1_data;
                                    op2              = rs2_data ;
                                    
                                end
                                
                                `FUN7_SRA:begin
                                    
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SRA ;
                                    inst_type[4:0]   = `LOGIC;
                                    op1              = rs1_data;
                                    op2              = rs2_data ;
                                    
                                end
                                
                                default:begin
                                    
                                end
                            endcase
                            
                        end
                        `SLTU:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SLTU ;
                            inst_type[4:0]   = `ARITH;
                            op1              = rs1_data;
                            op2              = rs2_data ;
                        end
                        
                        `SLT:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SLT ;
                            inst_type[4:0]   = `ARITH;
                            op1              = rs1_data;
                            op2              = rs2_data ;
                        end
                        
                        `XOR:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_XOR ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = rs2_data ;
                        end
                        
                        
                        default:begin
                            inst_opcode = 8'b00000000;
                        end
                        
                    endcase
                    
                end
                `INST_64R : begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 1'b1;
                    rs2_r_addr = rs2;
                    rd_w_ena   = 1'b1;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_jr_en = 1'b0;
                    inst_j_en  = 1'b0;
                    i_skip     = 1'b0;
                    case (func3)
                        `ADD:begin
                            case(func7)
                                `FUN7_ADD:begin
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_ADDW ;
                                    inst_type[4:0]   = `ARITH;
                                    op1              = rs1_data;
                                    op2              = rs2_data ;
                                end
                                `FUN7_SUB:begin
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SUBW ;
                                    inst_type[4:0]   = `ARITH;
                                    op1              = rs1_data;
                                    op2              = rs2_data ;
                                end
                                default:begin
                                    inst_opcode[7:0] = `ZERO_BYTE;
                                    inst_type[4:0]   = 5'b0;
                                    op1              = `ZERO_WORD;
                                    op2              = `ZERO_WORD ;
                                end
                                
                            endcase
                            
                        end

                        `SLLW:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SLLW ;
                            inst_type[4:0]   = `LOGIC;
                            op1              = rs1_data;
                            op2              = rs2_data;
                        end

                        `SRLW:begin
                            
                            case(func7)
                                `FUN7_SRL:begin
                                    
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SRLW ;
                                    inst_type[4:0]   = `LOGIC;
                                    op1              = rs1_data;
                                    op2              = rs2_data;
                                    
                                end
                                
                                `FUN7_SRA:begin
                                    
                                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SRAW ;
                                    inst_type[4:0]   = `LOGIC;
                                    op1              = rs1_data;
                                    op2              = rs2_data;
                                    
                                end
                                
                                
                                default:begin
                                    inst_opcode[7:0] = `ZERO_BYTE;
                                    inst_type[4:0]   = 5'b00000;
                                    op1              = `ZERO_WORD;
                                    op2              = `ZERO_WORD;
                                end
                            endcase

                            end
                        
                        default:begin
                            inst_opcode[7:0] = `ZERO_BYTE;
                            inst_type[4:0]   = 5'b00000;
                            op1              = `ZERO_WORD;
                            op2              = `ZERO_WORD;
                        end
                        
                    endcase
                    
                end
                `INST_L: begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 1'b0;
                    rs2_r_addr = rs2;
                    rd_w_ena   = 1'b1;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b1;
                    inst_j_en  = 1'b0;
                    inst_jr_en = 1'b0;
                    i_skip     = 1'b0;
                    case (func3)
                        `LB:begin
                            
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_LB ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}}, imm };
                            op2              = {{52{imm[11]}}, imm } ;
                            
                        end
                        
                        `LBU:begin
                            
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_LBU ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}}, imm };
                            op2              = {{52{imm[11]}}, imm } ;

                        end
                        `LH:begin
                            
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_LH ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}}, imm };
                            op2              = {{52{imm[11]}}, imm } ;
                            
                        end
                        `LHU:begin
                            
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_LHU ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}}, imm };
                            op2              = {{52{imm[11]}}, imm } ;
                            
                        end
                        `LW:begin
                            
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_LW ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}}, imm };
                            op2              = {{52{imm[11]}}, imm } ;
                            
                        end
                        `LWU:begin
                            
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_LWU ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}}, imm };
                            op2              = {{52{imm[11]}}, imm } ;
                            
                        end
                        `LD:begin
                            
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_LD ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}}, imm };
                            op2              = {{52{imm[11]}}, imm } ;
                            
                        end
                        
                        
                        default:begin
                            ;
                        end
                    endcase
                end
                `INST_S: begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 1'b1;
                    rs2_r_addr = rs2;
                    rd_w_ena   = 1'b0;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b1;
                    mem_r_ena  = 1'b0;
                    inst_j_en = 1'b0;
                    inst_jr_en = 1'b0;
                    i_skip     = 1'b0;
                    case (func3)
                        `SB:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SB ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}},S_imm};
                            op2              = rs2_data;
                        end
                        `SH:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SH ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}},S_imm};
                            op2              = rs2_data;
                        end
                        `SW:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SW ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{S_imm[11]}},S_imm};
                            op2              = rs2_data;
                        end
                            `SD:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_SD ;
                            inst_type[4:0]   = `LOAD;
                            op1              = rs1_data + {{52{imm[11]}},S_imm};
                            op2              = rs2_data;
                        end
                        default:begin
                            ;
                        end
                    endcase
                end
                `INST_B: begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 1'b1;
                    rs2_r_addr = rs2;
                    rd_w_ena   = 1'b0;;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_j_en  = 1'b0;
                    inst_jr_en = 1'b0;
                    i_skip     = 1'b0;
                    case (func3)
                        `BEQ:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_BEQ ;
                            inst_type[4:0]   = `JUMP;
                            if (rs1_data == rs2_data)
                            begin
                                inst_j_en = 1'b1;
                                op1       = {{51{SB_imm[11]}},SB_imm,1'b0};
                                op2       = `ZERO_WORD;
                            end
                            else begin
                                op1 = `ZERO_WORD;
                                op2 = `ZERO_WORD;
                            end
                            
                        end
                        `BNE:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_BNE ;
                            inst_type[4:0]   = `JUMP;
                            if (rs1_data != rs2_data)
                            begin
                                inst_j_en = 1'b1;
                                op1       = {{51{SB_imm[11]}},SB_imm,1'b0};
                                op2       = `ZERO_WORD;
                            end
                            else begin
                                op1 = `ZERO_WORD;
                                op2 = `ZERO_WORD;
                            end
                            
                        end
                        
                        `BLT:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_BLT ;
                            inst_type[4:0]   = `JUMP;
                            if ($signed(rs1_data) < $signed(rs2_data))
                            begin
                                inst_j_en = 1'b1;
                                op1       = {{51{SB_imm[11]}},SB_imm,1'b0};
                                op2       = `ZERO_WORD;
                            end
                            else begin
                                op1 = `ZERO_WORD;
                                op2 = `ZERO_WORD;
                            end
                            
                        end
                        `BGE:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_BGE ;
                            inst_type[4:0]   = `JUMP;
                            if ($signed(rs1_data) >= $signed(rs2_data))
                            begin
                                inst_j_en = 1'b1;
                                op1       = {{51{SB_imm[11]}},SB_imm,1'b0};
                                op2       = `ZERO_WORD;
                            end
                            else begin
                                op1 = `ZERO_WORD;
                                op2 = `ZERO_WORD;
                            end
                            
                        end
                        `BLTU:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_BLTU ;
                            inst_type[4:0]   = `JUMP;
                            if (rs1_data < rs2_data)
                            begin
                                inst_j_en = 1'b1;
                                op1       = {{51{SB_imm[11]}},SB_imm,1'b0};
                                op2       = `ZERO_WORD;
                            end
                            else begin
                                op1 = `ZERO_WORD;
                                op2 = `ZERO_WORD;
                            end
                            
                        end
                        `BGEU:begin
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_BGEU ;
                            inst_type[4:0]   = `JUMP;
                            if (rs1_data >= rs2_data)
                            begin
                                inst_j_en = 1'b1;
                                op1       = {{51{SB_imm[11]}},SB_imm,1'b0};
                                op2       = `ZERO_WORD;
                            end
                            else begin
                                op1 = `ZERO_WORD;
                                op2 = `ZERO_WORD;
                            end
                            
                        end
                        default:begin
                            ;
                        end
                    endcase
                end
                `INST_JR: begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 1'b0;
                    rs2_r_addr = rs2;
                    rd_w_ena   = 1'b1;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_j_en  = 1'b0;
                    inst_jr_en = 1'b0;
                    i_skip     = 1'b0;
                    case (func3)
                        `JALR:begin
                            inst_jr_en = 1'b1;
                            inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_JALR ;
                            inst_type[4:0]   = `JUMP;
                            
                            
                            op1              = rs1_data  ;
                            op2              = {{52{imm[11]}}, imm } ;

                            
                        end
                        
                        default:begin
                            op1 = `ZERO_WORD;
                            op2 = `ZERO_WORD;
                        end
                    endcase
                end               
                `INST_J: begin
                    rs1_r_ena  = 1'b0;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 1'b0;
                    rs2_r_addr = rs2;
                    rd_w_ena   = 1'b1;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                     inst_jr_en = 1'b0;
                     i_skip     = 1'b0;
                    inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_JAL ;
                    inst_type[4:0]   = `JUMP;

                    inst_j_en = 1'b1;
                    op1       = {{43{J_imm[19]}},J_imm,1'b0};
                    op2       = `ZERO_WORD;
                        
                end
                `INST_AP: begin
                        rs1_r_ena        = 1'b0;
                        rs1_r_addr       = rs1;
                        rs2_r_ena        = 1'b0;
                        rs2_r_addr       = rs2;
                        rd_w_ena         = 1'b1;
                        rd_w_addr        = rd;
                        mem_w_ena  = 1'b0;
                        mem_r_ena  = 1'b0;
                        inst_j_en  = 1'b0;
                        inst_jr_en = 1'b0;
                        i_skip     = 1'b0;
                
                        inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_AUIPC ;
                        inst_type[4:0]   = `JUMP;
                        op1              = {{32{U_imm[19]}}, U_imm, 12'b000000000000};
                        op2              = `ZERO_WORD ;
                end
                `INST_LI: begin
                        rs1_r_ena        = 1'b0;
                        rs1_r_addr       = rs1;
                        rs2_r_ena        = 1'b0;
                        rs2_r_addr       = rs2;
                        rd_w_ena         = 1'b1;
                        rd_w_addr        = rd;
                        mem_w_ena  = 1'b0;
                        mem_r_ena  = 1'b0;
                        inst_j_en  = 1'b0;
                        inst_jr_en = 1'b0;
                        i_skip     = 1'b0;
                
                        inst_opcode[7:0] = (rst == 1'b1) ? `ZERO_BYTE :`INST_LUI ;
                        inst_type[4:0]   = `ARITH;
                        op1              = {{32{U_imm[19]}}, U_imm, 12'b000000000000};
                        op2              = `ZERO_WORD ;
                end
                `INST_LSY:begin
                    rs1_r_ena  = 1'b1;
                    rs1_r_addr = rs1;
                    rs2_r_ena  = 0;
                    rs2_r_addr = 0;
                    rd_w_ena   = 1'b0;
                    rd_w_addr  = rd;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_jr_en = 1'b0;
                    inst_j_en  = 1'b0;
                    i_skip     = 1'b1;
                    //  fd ++;
                     

                end
                default:begin
                    rs1_r_ena  = 1'b0;
                    rs1_r_addr = 0;
                    rs2_r_ena  = 0;
                    rs2_r_addr = 0;
                    rd_w_ena   = 1'b0;
                    rd_w_addr  = 0;
                    mem_w_ena  = 1'b0;
                    mem_r_ena  = 1'b0;
                    inst_jr_en = 1'b0;
                    inst_j_en  = 1'b0;
                    i_skip     = 1'b0;
                        
                end
            endcase
        end
    end
    
    
endmodule
    
    /* //--xuezhen--
     
     `include "defines.v"
     
     module id_stage(
     input wire rst,
     input wire [31 : 0]inst,
     input wire [`REG_BUS]rs1_data,
     input wire [`REG_BUS]rs2_data,
     
     
     output wire rs1_r_ena,
     output wire [4 : 0]rs1_r_addr,
     output wire rs2_r_ena,
     output wire [4 : 0]rs2_r_addr,
     output wire rd_w_ena,
     output wire [4 : 0]rd_w_addr,
     
     output wire [4 : 0]inst_type,
     output wire [7 : 0]inst_opcode,
     output wire [`REG_BUS]op1,
     output wire [`REG_BUS]op2
     );
     
     
     wire inst_addi = ~opcode[2] & ~opcode[3] & opcode[4] & ~opcode[5] & ~opcode[5]
     & ~func3[0] & ~func3[1] & ~func3[2];
     
     // arith inst: 10000; logic: 01000;
     // load-store: 00100; j: 00010;  sys: 000001
     assign inst_type[4] = (rst == 1'b1) ? 0 : inst_addi;
     
     assign inst_opcode[0] = (rst == 1'b1) ? 0 : inst_addi;
     assign inst_opcode[1] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[2] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[3] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[4] = (rst == 1'b1) ? 0 : inst_addi;
     assign inst_opcode[5] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[6] = (rst == 1'b1) ? 0 : 0;
     assign inst_opcode[7] = (rst == 1'b1) ? 0 : 0;
     
     // I-type
     wire [6  : 0]opcode;
     wire [4  : 0]rd;
     wire [2  : 0]func3;
     wire [4  : 0]rs1;
     wire [11 : 0]imm;
     assign opcode = inst[6  :  0];
     assign rd     = inst[11 :  7];
     assign func3  = inst[14 : 12];
     assign rs1    = inst[19 : 15];
     assign imm    = inst[31 : 20];
     
     
     assign rs1_r_ena  = (rst == 1'b1) ? 0 : inst_type[4];
     assign rs1_r_addr = (rst == 1'b1) ? 0 : (inst_type[4] == 1'b1 ? rs1 : 0);
     assign rs2_r_ena  = 0;
     assign rs2_r_addr = 0;
     
     assign rd_w_ena  = (rst == 1'b1) ? 0 : inst_type[4];
     assign rd_w_addr = (rst == 1'b1) ? 0 : (inst_type[4] == 1'b1 ? rd  : 0);
     
     assign op1 = (rst == 1'b1) ? 0 : (inst_type[4] == 1'b1 ? rs1_data : 0);
     assign op2 = (rst == 1'b1) ? 0 : (inst_type[4] == 1'b1 ? { {52{imm[11]}}, imm } : 0);
     
     
     endmodule
     */
