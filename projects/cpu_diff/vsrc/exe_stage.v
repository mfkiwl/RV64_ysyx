/* verilator lint_off PINMISSING */
//--xuezhen--

`include "defines.v"

/* module exe_stage(
  input wire rst,
  input wire [4 : 0]inst_type_i,
  input wire [7 : 0]inst_opcode,
  input wire [`REG_BUS]op1,
  input wire [`REG_BUS]op2,
  
  output wire [4 : 0]inst_type_o,
  output reg  [`REG_BUS]rd_data
);

assign inst_type_o = inst_type_i;

always@( * )
begin
  if( rst == 1'b1 )
  begin
    rd_data = `ZERO_WORD;
  end
  else
  begin
    case( inst_opcode )
	  `INST_ADD: begin rd_data = op1 + op2;  end
	  default:   begin rd_data = `ZERO_WORD; end
	endcase
  end
end


endmodule */

module exe_stage(input wire rst,
                 input wire clk,
                 input wire [4 : 0]inst_type_i,
                 input wire [7 : 0]inst_opcode,
                 input wire [`REG_BUS]op1,
                 input wire [`REG_BUS]op2,
                 input wire [`REG_BUS]mem_r_data,
                 input wire [`REG_BUS]pc_if,
                 input wire inst_j_en,
                 output wire [9 : 0]mem_addr,
                 output wire [4 : 0]inst_type_o,
                 output reg [`REG_BUS]rd_data,
                 output reg [`REG_BUS]mem_w_data,
                 output reg [`REG_BUS]pc_exe);
    
    
    assign inst_type_o = inst_type_i;
    
    assign mem_addr = rd_data[9:0];
    
    reg[`REG_BUS] alout;
    reg[`REG_BUS] alwout;
    reg[31 : 0] alwout_0;
    reg[`REG_BUS] slout;
    reg[`REG_BUS] jbout;
    
    
    always @(*)begin
        if (rst == 1'b1)
        begin
            alout = `ZERO_WORD;
        end
        else
        begin
            
            case(inst_opcode)
                `INST_ADD: begin
                    alout = op1 + op2 ;
                end
                `INST_SUB: begin
                    alout = op1 - op2 ;
                end
                `INST_OR: begin
                    alout = op1 | op2 ;
                end
                `INST_AND:begin
                    alout = op1 & op2 ;
                end
                `INST_SLL:begin
                    alout = op1 << (op2[5:0]) ;
                    // $display(" slli");
                end
                `INST_SRL:begin
                    alout = op1 >> (op2[5:0]) ;
                end
                `INST_SRA:begin
                    alout = op1 >> (op2[5:0]) | ({64{op1[63]}} << (7'd64 - {1'b0,op2[5:0]})) ;
                    // to achieve arith right shift
                end
                `INST_SLT:begin
                    alout = {63'b0,{$signed(op1) < $signed(op2)}};
                end
                `INST_SLTU:begin
                    alout = {63'b0,{op1 < op2}};
                end
                `INST_XOR:begin
                    alout = op1 ^ op2;
                end
                `INST_LUI:begin
                    alout = op1;
                end
                default:  begin
                    alout = `ZERO_WORD;
                end
            endcase
        end
    end
     
    wire [31:0] op1_32= op1[31:0];
    wire [31:0] op2_32= op2[31:0];
    //64I/64R
    always @(*)begin
        if (rst == 1'b1)
        begin
            alwout = `ZERO_WORD;
            alwout_0 = `ZERO_HWORD;
        end
        else
        begin
            
            case(inst_opcode)
                `INST_ADDW,`INST_ADDIW: begin
                    alwout_0 = op1_32 + op2_32 ;
                    alout = {{32{alwout_0[31]}},alwout_0[31:0]};
                end
                `INST_SUBW: begin
                    alwout_0 = op1_32 - op2_32 ;
                    alout = {{32{alwout_0[31]}},alwout_0[31:0]};
                end
                `INST_SLLW , `INST_SLLIW:begin
                    alwout_0 = op1_32 << (op2_32[4:0]);
                    alout = {{32{alwout_0[31]}},alwout_0[31:0]};
                end
                `INST_SRLW , `INST_SRLIW:begin
                    alwout_0 = op1_32 >> (op2_32[4:0]);
                    alout = {{32{alwout_0[31]}},alwout_0[31:0]};
                end
                `INST_SRAW , `INST_SRAIW:begin
                    alwout_0 = op1_32 >> (op2_32[4:0]) | ({32{op1_32[31]}} << (7'd32 - {2'b0,op2_32[4:0]})) ;
                    alout = {{32{alwout_0[31]}},alwout_0[31:0]};
                    // alwout_0 =  , >> (op2[4:0]);
                    // alout = {{32{alwout_0[31]}},alwout_0[31:0]};
                end
                default : begin
                    alwout = `ZERO_WORD;
                    alwout_0 = `ZERO_HWORD;
                end
            endcase
        end
    end
    //Load/Store
    always @(*) begin
        if (rst == 1'b1)
        begin
            slout = `ZERO_WORD;
            mem_w_data = `ZERO_WORD;
            
        end
        else
        begin
            case(inst_opcode)
                
                `INST_LB:begin
                    mem_w_data = `ZERO_WORD;
                    slout      = {{56{mem_r_data[7]}}, mem_r_data[7:0]};
                end
                
                `INST_LBU:begin
                    mem_w_data = `ZERO_WORD;
                    slout      = {56'b0, mem_r_data[7:0]};
                end
                
                `INST_LH:begin
                    mem_w_data = `ZERO_WORD;
                    slout      = {{48{mem_r_data[15]}}, mem_r_data[15:0]};
                end
                
                `INST_LHU:begin
                    mem_w_data = `ZERO_WORD;
                    slout      = {48'b0, mem_r_data[15:0]};
                end
                
                `INST_LW:begin
                    mem_w_data = `ZERO_WORD;
                    slout      = {{32{mem_r_data[31]}}, mem_r_data[31:0]};
                    // slout      = {32'b0, mem_r_data[31:0]};
                end
                
                `INST_LWU:begin
                    mem_w_data = `ZERO_WORD;
                    slout      = {32'b0, mem_r_data[31:0]};
                end

                `INST_LD:begin
                    mem_w_data = `ZERO_WORD;
                    slout      =  mem_r_data[63:0];

                end
                `INST_SB:begin
                    mem_w_data = {56'b0,op2[7:0]};
                    slout      = op1;
                end
                `INST_SH:begin
                    mem_w_data = {48'b0,op2[15:0]};
                    slout      = op1;
                end
                `INST_SW:begin
                    mem_w_data = {32'b0,op2[31:0]};
                    slout      = op1;
                end
                `INST_SD:begin
                    mem_w_data = op2;
                    slout      = op1;
                end
                default:begin
                    mem_w_data = `ZERO_WORD;
                    slout      = `ZERO_WORD;
                end
            endcase
        end
    end
    //Branch
    always @(*) begin
        if (rst == 1'b1)
        begin
            pc_exe = `ZERO_WORD;
            jbout  = `ZERO_WORD;
            
        end
        else
        begin
            case(inst_opcode)
                
                `INST_BEQ:begin
                    if (inst_j_en == 1'b1) begin
                        pc_exe = pc_if + op1;
                    end
                    else begin
                        pc_exe = pc_if;
                    end
                    
                end
                `INST_BNE:begin
                    if (inst_j_en == 1'b1) begin
                        pc_exe = pc_if + op1;
                    end
                    else begin
                        pc_exe = pc_if;
                    end
                    
                end
                `INST_BLT:begin
                    if (inst_j_en == 1'b1) begin
                        pc_exe = pc_if + op1;
                    end
                    else begin
                        pc_exe = pc_if;
                    end
                end
                `INST_BGE:begin
                    if (inst_j_en == 1'b1) begin
                        pc_exe = pc_if + op1;
                    end
                    else begin
                        pc_exe = pc_if;
                    end
                end
                `INST_BLTU:begin
                    if (inst_j_en == 1'b1) begin
                        pc_exe = pc_if + op1;
                    end
                    else begin
                        pc_exe = pc_if;
                    end
                end
                `INST_BGEU:begin
                    if (inst_j_en == 1'b1) begin
                        pc_exe = pc_if + op1;
                    end
                    else begin
                        pc_exe = pc_if;
                    end
                    
                end
                
                `INST_JAL:begin
                    jbout  = pc_if + 4;
                    pc_exe = pc_if + op1;
                end
                
                `INST_JALR:begin
                    jbout  = pc_if + 4;
                    pc_exe = (op1 + op2) & -1 ;
                end

                `INST_AUIPC:begin
                    jbout  = pc_if + op1;
                end
                
                default:begin
                    // mem_w_data = `ZERO_WORD;
                    pc_exe        = `ZERO_WORD;
                    jbout         = `ZERO_WORD;
                end
            endcase
        end
    end
   //Jump
    always @( *) begin
     if (rst == 1'b1)
     begin
     pc_exe = `ZERO_WORD;
     jbout  = `ZERO_WORD;
     
     end
     else
     begin
     case(inst_opcode)
     
     `INST_JAL:begin
     jbout  = pc_if + 4;
     pc_exe= pc_if + op1;

    //  pc_if <= pc_if + op1;
     end
     
     `INST_JALR:begin
     jbout  = pc_if + 4;
     pc_exe = (op1 + op2) & 64'h11111111_11111110 ;
     end
     
     default:begin
     // mem_w_data = `ZERO_WORD;
     jbout         = `ZERO_WORD;
     end
     endcase
     end
     end
    
    
    always @ (*) begin // MUX
    if (rst == 1'b1)
        begin
            rd_data = `ZERO_WORD;
        end

      else
      begin
        case (inst_type_i)
        `ARITH:begin
         rd_data = alout;
        end

         `LOGIC:begin
         rd_data = alout;
        end

        `LOAD:begin
          rd_data = slout;
        end

        `JUMP:begin
          rd_data = jbout;
        end
        default:begin
          rd_data = `ZERO_WORD;
        end
        endcase
      end
    end
    endmodule
