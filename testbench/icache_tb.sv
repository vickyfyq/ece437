import cpu_types_pkg::*;
`include "datapath_cache_if.vh"
`include "caches_if.vh"
`timescale 1 ns / 1 ns
module icache_tb;
    parameter PERIOD = 10;
    logic CLK = 0, nRST;
    always #(PERIOD/2) CLK++;

    caches_if cif ();
    datapath_cache_if dcif ();

    test PROG(CLK, nRST, dcif, cif);

`ifndef MAPPED
  icache DUT(CLK, nRST,dcif,cif);
`else
  icache DUT(
    .\CLK(CLK),
    .\nRST(nRST),
    .\cif.iwait(cif.iwait),
    .\cif.iload(cif.iload),
    .\cif.iREN(cif.iREN),
    .\cif.iaddr(cif.iaddr),
    .\dcif.imemREN(dcif.imemREN),
    .\dcif.imemaddr(dcif.imemaddr),
    .\dcif.ihit(dcif.ihit),
    .\dcif.imemload(dcif.imemload),
  );
`endif

endmodule 

program test(input logic CLK, nRST, datapath_cache_if dcif,caches_if cif);
import cpu_types_pkg::*;
string testcase;
task msg;

  input logic ihit, iREN;
  input logic [31:0] imemload, iaddr; 
  begin
  if (dcif.ihit == ihit && cif.iREN == iREN&& dcif.imemload == imemload  && cif.iaddr == iaddr) 
      $display("Pass %s", testcase);
  else begin
    $display("!!!!!!!!failed %s ihit %d iREN %d imemload %d", testcase,dcif.ihit, dcif.dhit,dcif.imemload);
    end
  end
endtask
initial begin
    // string testcase; 
    dcif.halt = '0;
    dcif.dmemREN = '0;
    dcif.dmemWEN = '0;

    icache_tb.nRST = 0;
    #(10);
    icache_tb.nRST = 1;
    //write to index
    dcif.imemaddr = {26'hfff, 4'd1, 2'b00};
    #(10);
    cif.iload = 32'he00ee00e;
    dcif.imemREN = 1;
    cif.iwait = 0;
    #(20);
    cif.iwait = 1;
    

    dcif.imemaddr = {26'hfff, 4'd1, 2'b00};
    cif.iwait = 1;
    dcif.imemREN = 1;
    #(10);
    
    testcase = "tag matches";
    msg(1, 0, 32'he00ee00e, '0);
    #(10);




    dcif.imemaddr = {26'hfff, 4'd2, 2'b00};
    #(10);
    cif.iload = 32'he2222222;
    cif.iwait = 0;
    #(20);
    cif.iwait = 1;

    dcif.imemaddr = {26'hfff, 4'd3, 2'b00};
    #(10);
    cif.iload = 32'he3333333;
    cif.iwait = 0;
    #(20);
    cif.iwait = 1;

    dcif.imemaddr = {26'hff, 4'd2, 2'b00};
    cif.iload = 32'haaaaaaaa;
    cif.iwait = 0;
    dcif.imemREN = 1;
    #(10);
    testcase = "tag not match";
    msg(1, 1, 32'haaaaaaaa, {26'hff, 4'd2, 2'b00});
    #(10);
    dcif.imemaddr = {26'hfff, 4'd3, 2'b00};
    cif.iload = 32'h0;
    cif.iwait = 1;
    dcif.imemREN = 0;
    #(10);
    testcase = "not reading";
    msg(0,0,'0,'0);

end
endprogram

