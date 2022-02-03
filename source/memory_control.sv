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

  
  always_comb begin
    ccif.ramREN = '0;
    ccif.ramaddr = '0;
    ccif.dload = '0;
    ccif.ramWEN = '0;
    ccif.ramaddr = '0;
    ccif.ramstore = '0;
    ccif.ramREN = '0;
    ccif.ramaddr = '0;
    ccif.iload = '0;
    
    if (ccif.dREN) begin
      ccif.ramREN = ccif.dREN;
      ccif.ramaddr = ccif.daddr;
      ccif.dload = ccif.ramload; 
    end  
    else if(ccif.dWEN && !ccif.dREN ) begin
      ccif.ramWEN = ccif.dWEN;
      ccif.ramaddr = ccif.daddr;
      ccif.ramstore = ccif.dstore;
    end

    if (ccif.iREN && !ccif.dREN && !ccif.dWEN)  begin
      ccif.ramREN = ccif.iREN;
      ccif.ramaddr = ccif.iaddr;
      ccif.iload = ccif.ramload;
    end
    
    ccif.dwait =((ccif.dWEN || ccif.dREN) && (ccif.ramstate != ACCESS)) ? 1:0;   
    ccif.iwait = (ccif.iREN && (ccif.ramstate != ACCESS)) ? 1:0;
     

  end



endmodule
