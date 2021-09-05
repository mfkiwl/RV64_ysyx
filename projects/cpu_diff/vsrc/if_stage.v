
//--xuezhen--

`include "defines.v"


module if_stage(
  input wire clk,
  input wire rst,
  input reg inst_j_en,
  input reg inst_jr_en,
  input wire [63 : 0] pc_jump,
  input wire [63 : 0] op1,
  
  output reg [63 : 0] pc,
  output reg [31 : 0] inst
 
);

parameter PC_START_RESET = `PC_START - 4;

// fetch an instruction
always@( posedge clk )
begin
  if( rst == 1'b1 )
  begin
    pc <= PC_START_RESET;
  end
  else if (inst_j_en)
  begin
    pc <= pc_jump;
  end
  else if (inst_jr_en)
  begin
    pc <= pc_jump;
  end
  else
  begin
    pc <= pc + 4;
  end
end



endmodule
