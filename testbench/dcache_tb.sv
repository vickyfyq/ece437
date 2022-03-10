`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"

`timescale 1 ns / 1 ns

module dcache_tb;

  parameter PERIOD = 10;
  logic CLK = 0, nRST;

  always #(PERIOD/2) CLK++;

  // interface delcaration
  caches_if cif ();
  datapath_cache_if dcif ();
  // test program setup
  test PROG (CLK, nRST, cif, dcif);

`ifndef MAPPED
  dcache DUT(CLK, nRST, dcif, cif);

`else
  dcache DUT(
    .\CLK(CLK),
    .\nRST(nRST),
    .\dcif.halt(dcif.halt),
    .\dcif.dmemaddr(dcif.dmemaddr),
    .\dcif.dmemREN(dcif.dmemREN),
    .\dcif.dmemWEN(dcif.dmemWEN),
    .\dcif.dmemload(dcif.dmemload),
    .\dcif.dmemstore(dcif.dmemstore),
    .\dcif.dmemaddr(dcif.dmemaddr),
    .\dcif.dhit(dcif.dhit),
    .\cif.dwait(cif.dwait),
    .\cif.dload(cif.dload),
    .\cif.dREN(cif.dREN),
    .\cif.dWEN(cif.dWEN),
    .\cif.daddr(cif.daddr),
    .\cif.dstore(cif.dstore)
  );
`endif

endmodule

program test(logic CLK, logic nRST, caches_if cif, datapath_cache_if dcif);

import cpu_types_pkg::*;

task reset_dut;
begin
    nRST = 1;
    @(posedge CLK);
    nRST = 0;
    @(posedge CLK);
    @(posedge CLK);
    nRST = 1;
    @(posedge CLK);
end

task read_outputs;
input word_t dmemload;
input word_t daddr;
input word_t dstore;
input logic dREN;
input logic dWEN;
input logic dhit;
input logic flushed;
logic correct;
begin
    correct = 1;
    assert(dmemload == dcif.dmemload)
        $display("Incorrect output of dcif.dmemload for test case %0d. Expected: %0h, Actual: %0h", test_num, dmemload, dcif.dmemload);

    assert(daddr == cif.daddr)
        $display("Incorrect output of cif.daddr for test case %0d. Expected: %0h, Actual: %0h", test_num, daddr, cif.daddr);
    
    assert(dstore == cif.dstore)
        $display("Incorrect output of cif.dstore for test case %0d. Expected: %0h, Actual: %0h", test_num, dstore, cif.dstore);
    
    assert(dREN == cif.dREN)
        $display("Incorrect output of cif.dREN for test case %0d. Expected: %0h, Actual: %0h", test_num, dREN, cif.dREN);
    
    assert(dWEN == cif.dWEN)
        $display("Incorrect output of cif.dWEN for test case %0d. Expected: %0h, Actual: %0h", test_num, dWEN, cif.dWEN);
    
    assert(dhit == dcif.dhit)
        $display("Incorrect output of dcif.dhit for test case %0d. Expected: %0h, Actual: %0h", test_num, dhit, dcif.dhit);
    
    assert(flushed == dcif.flushed)
        $display("Incorrect output of dcif.flushed for test case %0d. Expected: %0h, Actual: %0h", test_num, flushed, dcif.flushed);
    
    assert(correct)
        $display("Correct output for test case %0d", test_num);
    
end

initial begin

  int testNum;

  nRST = 1;
  dcif.imemaddr = '0;
  dcif.halt = 0;
  dcif.imemREN = 1;
  dcif.dmemREN = 0;
  dcif.dmemWEN = 0;
  dcif.datomic = 0;
  dcif.dmemstore = 0;
  dcif.dmemaddr = 0;
  dcif.imemaddr = 0;
  cif.dwait = 1;
  cif.dload = 0;
  cif.ccwait = 0;
  cif.ccinv = 0;
  cif.ccsnoopaddr = 0;
  cif.iwait = 1;
  cif.iload = 0;

  reset_dut();

end

endprogram