/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;

  assign ccif.iwait = ~(ccif.iREN && ~ccif.dWEN && ~ccif.dREN && (ccif.ramstate == ACCESS));
  assign ccif.dwait = ~((ccif.dWEN || ccif.dREN) && (ccif.ramstate == ACCESS));
  assign ccif.iload = ccif.iREN ? ccif.ramload : '0;
  assign ccif.dload = ccif.dREN ? ccif.ramload : '0;
  assign ccif.ramstore = ccif.dstore;
  assign ccif.ramWEN = ccif.dWEN;
  assign ccif.ramaddr = (ccif.dREN || ccif.dWEN) ? ccif.daddr : ccif.iaddr;
  assign ccif.ramREN = (ccif.dREN || ccif.iREN) & ~ccif.dWEN;
  


endmodule
