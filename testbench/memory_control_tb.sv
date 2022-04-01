`include "cache_control_if.vh"
`include "cpu_ram_if.vh"
`include "caches_if.vh"
`include "cpu_types_pkg.vh"


`timescale 1 ns / 1 ns

  typedef enum logic[3:0] {
    IDLE, WB1, WB2, IFETCH, ARB, LDRAM1, LDRAM2, LDCACHE1, LDCACHE2, SNOOP
  } state_t;


module memory_control_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // clock
  always #(PERIOD/2) CLK++;

  caches_if cif0();
  caches_if cif1();
  cache_control_if #(.CPUS(2))ccif(cif0,cif1);

  
  // assign ccif.ramload =crif.ramload;
  // assign ccif.ramstate = crif.ramstate;
  // assign crif.ramstore = ccif.ramstore;
  // assign crif.ramaddr = ccif.ramaddr;
  // assign crif.ramWEN = ccif.ramWEN;
  // assign crif.ramREN = ccif.ramREN;

  test PROG (CLK, nRST, ccif);
    // DUT
`ifndef MAPPED
  memory_control DUT(CLK, nRST, ccif);
  // ram ramstuff(CLK,nRST,crif);
`else
  memory_control DUT(
    .\ccif.iREN (ccif.iREN),
    .\ccif.dREN (ccif.dREN),
    .\ccif.dWEN (ccif.dWEN),
    .\ccif.dstore (ccif.dstore),
    .\ccif.iaddr (ccif.iaddr),
    .\ccif.daddr (ccif.daddr),
    .\ccif.ramload (ccif.ramload),
    .\ccif.ramstate (ccif.ramstate),
    .\ccif.iwait (ccif.iwait),
    .\ccif.dwait(ccif.dwait),
    .\ccif.iload (ccif.iload),
    .\ccif.dload (ccif.dload),
    .\ccif.ramstore (ccif.ramstore),
    .\ccif.ramaddr (ccif.ramaddr),
    .\ccif.ramWEN (ccif.ramWEN),
    .\ccif.ramREN (ccif.ramREN,
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif


endmodule


program test(input logic CLK, output logic nRST, cache_control_if.cc ccif);

  import cpu_types_pkg::*;

initial begin
  state_t expected;

  //reset
  nRST = 0;
  expected = IDLE;

  ccif.ramload = 0;
  ccif.ramstate = ACCESS;

  cif0.dWEN = 0;
  cif0.dREN = 0;
  cif0.iREN = 0;
  cif0.dstore = '0;
  cif0.iaddr = 32'h12341234;
  cif0.daddr = '0;
  cif0.ccwrite = 0;
  cif0.cctrans = 0;

  cif1.dWEN = 0;
  cif1.dREN = 0;
  cif1.iREN = 0;
  cif1.dstore = '0;
  cif1.iaddr = '0;
  cif1.daddr = '0;
  cif1.ccwrite = 0;
  cif1.cctrans = 0;

  //instruction
  #(10);
  nRST = 1;
  #(10);
  cif0.iREN = 1;
  #(10);
  expected = IFETCH;

  //back to idle
  #(10);
  ccif.ramstate = FREE; 
  cif0.iREN = 0;
  cif0.cctrans = 0;
  #(10);
  expected = IDLE;
  #(10);

  //Ld ram 0 trans 1 write
  #(10);
  cif0.cctrans = 1;
  #(10);
  expected = ARB;
  cif0.dREN = 1;
  #(10);
  expected = SNOOP;

  cif1.ccwrite = 1;
  cif1.cctrans = 1;

  #(10);
  expected = LDRAM1;
  cif0.dREN = 0;

  cif0.cctrans = 0;
  cif1.ccwrite = 0;

  cif1.cctrans = 0;
  ccif.ramstate = FREE; 

  #(10);
  expected = LDRAM2;
  ccif.ramstate = FREE; 
  #(10);
  expected = IDLE;
  #(10);

  //ld cache
  #(10);
  cif0.cctrans = 1;
  cif0.ccwrite = 0;
  #(10);
  expected = ARB;
  cif0.dREN = 1;
  #(10);
  expected = SNOOP;

  cif1.ccwrite = 0;
  cif1.cctrans = 0;
  #(10);
  expected = LDCACHE1;
  cif0.dREN = 0;
  cif0.cctrans = 0;
  ccif.ramstate = FREE; 
  #(10);
  expected = LDCACHE2;
  ccif.ramstate = FREE; 
  #(10);
  expected = IDLE;
  #(10);


  //ld cache
  #(10);
  cif0.cctrans = 1;
  cif0.ccwrite = 1;
  #(10);
  expected = ARB;
  cif0.dREN = 1;
  #(10);
  expected = SNOOP;

  cif1.ccwrite = 0;
  cif1.cctrans = 0;
  #(10);
  expected = LDCACHE1;
  cif0.dREN = 0;
  cif0.cctrans = 0;
  ccif.ramstate = FREE; 
  #(10);
  expected = LDCACHE2;
  ccif.ramstate = FREE; 
  #(10);
  expected = IDLE;
  #(10);



  //WB
  #(10);
  cif0.dWEN = 1;
  #(10);
  expected = WB1;
  cif0.dWEN = 0;
  ccif.ramstate = FREE; 
  #(10);
  expected = WB2;
  ccif.ramstate = FREE; 
  #(10);
  expected = IDLE;
  #(10);


end



endprogram
