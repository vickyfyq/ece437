/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();
  // test program
  test PROG (.CLK(CLK),.nRST(nRST),.rfif(rfif));

  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif


endmodule

program test(input logic CLK,nRST,
register_file_if rfif);
initial begin

integer i;
rfif.WEN ='0;    
rfif.wsel = '0;
rfif.wdat = '0;
rfif.rsel1 = '0;
rfif.rsel2 = '0;
register_file_tb.nRST = 0;
@(negedge CLK);
@(negedge CLK);
@(negedge CLK);
register_file_tb.nRST = 1;
@(negedge CLK);
//test write to reg 0
//verify writes and reads
rfif.WEN = 1;    

for (i = 0;i <32;i++) begin
  rfif.wsel = i; 
  rfif.wdat = i*4; 
  @(negedge CLK);
  @(negedge CLK);
end

for (i = 0;i <16;i++) begin
  rfif.rsel1 = i; 
  rfif.rsel2= i+16; 
  @(negedge CLK);
  @(negedge CLK);
end

//test async reset
register_file_tb.nRST = 0;
@(negedge CLK);
@(negedge CLK);
@(negedge CLK);
register_file_tb.nRST = 1;

end
endprogram

