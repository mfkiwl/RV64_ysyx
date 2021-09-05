
`timescale 1ns / 1ps

`define ZERO_WORD  64'h00000000_00000000
`define ZERO_HWORD 32'h00000000
`define PC_START   64'h00000000_80000000 
`define ZERO_BYTE  8'h00 
`define REG_BUS    63 : 0   
`define MEM_BUS    63 : 0  


`define INST_I     7'b0010011
`define INST_64I   7'b0011011 //need modify
`define INST_R     7'b0110011
`define INST_64R   7'b0111011
`define INST_L     7'b0000011
`define INST_S     7'b0100011
`define INST_B     7'b1100011
`define INST_JR    7'b1100111
`define INST_J     7'b1101111
`define INST_AP    7'b0010111
`define INST_LI    7'b0110111
`define INST_LSY   7'b1111111
// `define INST_JR    7'b1100111 

`define ARITH      5'b10000
`define LOGIC      5'b01000
`define LOAD       5'b00100
`define JUMP       5'b00010
`define SYS        5'b00001

`define BEQ     3'b000
`define BNE     3'b001
`define BLT     3'b100
`define BGE     3'b101
`define BLTU    3'b110
`define BGEU    3'b111

`define LB      3'b000
`define LH      3'b001
`define LW      3'b010
`define LBU     3'b100
`define LHU     3'b101
`define LWU     3'b110
`define LD     3'b011


`define SB      3'b000
`define SH      3'b001
`define SW      3'b010
`define SD      3'b011

`define ADDI       3'b000
`define SLLI       3'b001
`define SLTI       3'b010
`define SLTIU      3'b011
`define XORI       3'b100
`define SRLI       3'b101
`define ORI        3'b110
`define ANDI       3'b111
`define ADDIW      3'b000
`define SLLW       3'b001
`define SRLW       3'b101
`define SRAW       3'b101

`define SLLIW       3'b001
`define SRLIW       3'b101
`define SRAIW       3'b101


`define ADD        3'b000
`define SLL        3'b001
`define SLT        3'b010
`define SLTU       3'b011
`define XOR        3'b100
`define SRL        3'b101
`define OR         3'b110
`define AND        3'b111

`define SRA         3'b101
`define SUB         3'b000

// `define JAL         
`define JALR        3'b000

`define ADDW        3'b000


`define INST_ADD   8'h11
`define INST_OR    8'h12
`define INST_AND   8'h13
`define INST_SLL   8'h14
`define INST_SRL   8'h15
`define INST_SRA   8'h16
`define INST_SUB   8'h17
`define INST_SLT   8'h18
`define INST_SLTU  8'h19
`define INST_XOR   8'h1a
`define INST_LB    8'h1b
`define INST_LBU   8'h1c
`define INST_LH    8'h1d
`define INST_LHU   8'h1e
`define INST_LW    8'h1f
`define INST_LWU   8'h20
`define INST_SB    8'h21
`define INST_SH    8'h22
`define INST_SW    8'h23
`define INST_BEQ   8'h24
`define INST_BNE   8'h25
`define INST_BLT   8'h26
`define INST_BGE   8'h27
`define INST_BLTU  8'h28
`define INST_BGEU  8'h29
`define INST_JAL   8'h2a
`define INST_JALR  8'h2b
`define INST_AUIPC 8'h2c
`define INST_SD    8'h2d
`define INST_LD    8'h2e
`define INST_ADDW  8'h2f
`define INST_ADDIW 8'h30
`define INST_SLLW  8'h31
`define INST_SRLW  8'h32
`define INST_SRAW  8'h33
`define INST_SUBW  8'h34
`define INST_SLLI  8'h35
`define INST_SRLI  8'h36
`define INST_SRAI  8'h37
`define INST_SLLIW 8'h38
`define INST_SRLIW 8'h39
`define INST_SRAIW 8'h40
`define INST_LUI   8'h41

`define FUN7_SRL        7'b0000000
`define FUN7_SRA        7'b0100000
`define FUN7_ADD        7'b0000000
`define FUN7_SUB        7'b0100000