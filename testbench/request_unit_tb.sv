`include "request_unit_if.vh"
`include "cpu_types_pkg.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module request_unit_tb;

    parameter PERIOD = 10;

  logic CLK = 0, nRST;


  // clock
  always #(PERIOD/2) CLK++;

  // interface
  request_unit_if ruif ();
  // test program
  test PROG (.CLK(CLK),.nRST(nRST),.ruif(ruif));

`ifndef MAPPED
  request_unit DUT(CLK, nRST, ruif);
`else
  request_unit DUT(
    .\ruif.MemtoReg (ruif.MemtoReg),
    .\ruif.MemWr (ruif.MemWr),
    .\ruif.dhit (ruif.dhit),
    .\ruif.ihit (ruif.ihit),
    .\ruif.dmemREN (ruif.dmemREN),
    .\ruif.dmemWEN (ruif.dmemWEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif

endmodule

program test(input logic CLK,nRST,
request_unit_if ruif);  
parameter PERIOD = 10;
integer num = 0;
String testnm;
initial begin
    request_unit_tb.nRST = 0;
    #(PERIOD);
    #(PERIOD);
    request_unit_tb.nRST = 1;
    testnm = "1000";
    #(PERIOD);
    ruif.ihit = 1;
    ruif.dhit = 0;
    ruif.MemtoReg = 0;
    ruif.MemWr = 0;

    #(PERIOD);
    ruif.ihit = 1;
    ruif.dhit = 0;
    ruif.MemtoReg = 1;
    ruif.MemWr = 0;

    #(PERIOD);
    ruif.ihit = 1;
    ruif.dhit = 0;
    ruif.MemtoReg = 0;
    ruif.MemWr = 1;

    #(PERIOD);
    ruif.ihit = 0;
    ruif.dhit = 1;
    ruif.MemtoReg = 1;
    ruif.MemWr = 0;

    #(PERIOD);
    ruif.ihit = 0;
    ruif.dhit = 1;
    ruif.MemtoReg = 0;
    ruif.MemWr = 1;

    #(PERIOD);
    ruif.ihit = 0;
    ruif.dhit = 0;
    ruif.MemtoReg = 0;
    ruif.MemWr = 0;
    
    #(PERIOD);
    #(PERIOD);
    $finish; 

end
endprogram

