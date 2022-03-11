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

program test(input logic CLK, output logic nRST, caches_if cif, datapath_cache_if dcif);
int test_num;
import cpu_types_pkg::*;
/*
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
endtask*/

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
    assert(dmemload != dcif.dmemload) begin
        $display("Incorrect output of dcif.dmemload for test case %0d. Expected: %0h, Actual: %0h", test_num, dmemload, dcif.dmemload);
        correct = 0;
    end

    assert(daddr != cif.daddr) begin
        $display("Incorrect output of cif.daddr for test case %0d. Expected: %0h, Actual: %0h", test_num, daddr, cif.daddr);
        correct = 0;
    end
    
    assert(dstore != cif.dstore) begin
        $display("Incorrect output of cif.dstore for test case %0d. Expected: %0h, Actual: %0h", test_num, dstore, cif.dstore);
        correct = 0;
    end
    
    assert(dREN != cif.dREN) begin
        $display("Incorrect output of cif.dREN for test case %0d. Expected: %0h, Actual: %0h", test_num, dREN, cif.dREN);
        correct = 0;
    end
    
    assert(dWEN != cif.dWEN) begin
        $display("Incorrect output of cif.dWEN for test case %0d. Expected: %0h, Actual: %0h", test_num, dWEN, cif.dWEN);
        correct = 0;
    end
    
    assert(dhit != dcif.dhit) begin
        $display("Incorrect output of dcif.dhit for test case %0d. Expected: %0h, Actual: %0h", test_num, dhit, dcif.dhit);
        correct = 0;
    end
    
    assert(flushed != dcif.flushed) begin
        $display("Incorrect output of dcif.flushed for test case %0d. Expected: %0h, Actual: %0h", test_num, flushed, dcif.flushed);
        correct = 0;
    end
    
    assert(correct)
        $display("Correct output for test case %0d", test_num);
    
end
endtask

initial begin
  test_num = 0;
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

  //reset_dut();
  nRST = 1;
  @(posedge CLK);
  nRST = 0;
  @(posedge CLK);
  @(posedge CLK);
  nRST = 1;
  @(posedge CLK);

  //load from 0x40 --- MISS
  //Test 1:
  test_num += 1;

  dcache_tb.dcif.dmemREN = 1;
  dcache_tb.dcif.dmemaddr = {30'h40, 2'b00};
  dcache_tb.cif.dwait = 0;
  dcache_tb.cif.dload = 32'hABCDEF00;
  #(20);
  dcache_tb.cif.dwait = 0;
  dcache_tb.cif.dload = 32'h12345678;
  #(20);

  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  read_outputs(32'hABCDEF00, 32'b0, 32'b0, 0, 0, 1, 0);
  
  //load from 0x41 --- HIT
  //Test 2:
  test_num += 1;

  dcache_tb.dcif.dmemREN = 1;
  dcache_tb.dcif.dmemaddr = {30'h41, 2'b00};
  #(20);

  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  read_outputs(32'h12345678, 32'b0, 32'b0, 0, 0, 1, 0);

  //store into 0x40 --- HIT, DIRTY
  //Test 3:
  test_num += 1;

  dcache_tb.cif.dwait = 1;
  dcache_tb.dcif.dmemREN = 0;
  dcache_tb.dcif.dmemWEN = 1;
  dcache_tb.dcif.dmemaddr = {30'h40, 2'b00};
  dcache_tb.dcif.dmemstore = 32'h69696969;
  #(20);

  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  read_outputs(32'h0, 32'h0, 32'h0, 0, 0, 1, 0);

  //load from 0x40 --- HIT
  //Test 4:
  test_num += 1;

  dcache_tb.dcif.dmemREN = 1;
  dcache_tb.dcif.dmemWEN = 0;
  dcache_tb.dcif.dmemaddr = {30'h40, 2'b00};
  #(20);

  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  read_outputs(32'h69696969, 32'b0, 32'b0, 0, 0, 1, 0);
  
  //load from 0x41 --- HIT
  //Test 5:
  test_num += 1;

  dcache_tb.dcif.dmemREN = 1;
  dcache_tb.dcif.dmemWEN = 0;
  dcache_tb.dcif.dmemaddr = {30'h41, 2'b00};
  #(20);

  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  read_outputs(32'h12345678, 32'b0, 32'b0, 0, 0, 1, 0);
  
   //store to 0x41 --- HIT, DIRTY 
  //Test 6:
  test_num += 1;
  dcache_tb.dcif.dmemREN = 0;
  dcache_tb.dcif.dmemWEN = 1;
  dcache_tb.dcif.dmemaddr = {30'h41, 2'b00};
  dcache_tb.dcif.dmemstore = 32'h96969696;
  #(20);

  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  read_outputs(32'h0, 32'h0, 32'h0, 0, 0, 1, 0);
  
  //load from 0x251 --- MISS
  //Test 7:
  test_num += 1;

  dcache_tb.dcif.dmemREN = 1;
  dcache_tb.dcif.dmemWEN = 0;
  dcache_tb.dcif.dmemaddr = {30'h251, 2'b00};
  dcache_tb.cif.dwait = 0;
  dcache_tb.cif.dload = 32'hbad1bad1;
  #(20);
  dcache_tb.cif.dwait = 0;
  dcache_tb.cif.dload = 32'hdad1dad1;
  #(20);

  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  read_outputs(32'hdad1dad1, 32'h0, 32'h0, 0, 0, 1, 0);
  
  //save to 0x250 --- HIT, DIRTY
  //Test 8:
  test_num += 1;
  dcache_tb.dcif.dmemREN = 0;
  dcache_tb.dcif.dmemWEN = 1;
  dcache_tb.dcif.dmemaddr = {30'h250, 2'b00};
  dcache_tb.dcif.dmemstore = 32'hDADDADAD;
  #(10);

  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  read_outputs(32'h0, 32'h0, 32'h0, 0, 0, 1, 0);
  
  //load from 0x3FFFF50 --- MISS
  test_num += 1;

  dcache_tb.dcif.dmemREN = 1;
  dcache_tb.dcif.dmemWEN = 0;
  dcache_tb.dcif.dmemaddr = {30'h3FFFF50, 2'b00};
  dcache_tb.cif.dwait = 1;
  #(20);
  dcache_tb.cif.dwait = 1;
  #(20);
  dcache_tb.cif.dwait = 0;
  dcache_tb.cif.dload = 32'h55555555;
  #(20);
  dcache_tb.cif.dwait = 0;
  dcache_tb.cif.dload = 32'hdeadbed1;
  #(10);
  
  //task read_outputs( memload; daddr; dstore; dREN; dWEN; dhit; flushed; )
  //read_outputs(32'h55555555, {30'h3FFFF50, 2'b00}, 32'h0, 1, 0, 1, 0);
  read_outputs(32'h55555555, 32'h0, 32'h0, 0, 0, 1, 0);
  
  // HALT
  test_num += 1;

  dcache_tb.cif.dwait = 1;
  dcache_tb.dcif.halt = 1;
  dcache_tb.cif.dwait = 0;

end

endprogram