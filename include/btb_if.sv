
`ifndef BTB_IF_VH
`define BTB_IF_VH

`include "cpu_types_pkg.vh"
interface btb_if;

  import cpu_types_pkg::*;


  logic pcen;
  word_t [31:0] npc_branch, pc, ex_pc, beq, bne ;

  logic branch_found; 
  word_t [31:0] branch_addr;


endinterface
`endif
