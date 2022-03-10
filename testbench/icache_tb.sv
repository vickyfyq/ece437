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
  alu DUT(CLK, nRST,dcif,cif);
`else
  alu DUT(
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
initial begin
    nRST = 0;
    #(10);
    nRST = 1;
    //write to index
    fcif.imemaddr = {26'hfff, 4'd1, 2'b00}
    #(10);
    cif.iload = 32'he00ee00e;
    cif.iwait = 0;
    #(20);
    cif.iwait = 1;
    
    fcif.imemaddr = {26'hfff, 4'd2, 2'b00}
    #(10);
    cif.iload = 32'he2222222;
    cif.iwait = 0;
    #(20);
    cif.iwait = 1;

    fcif.imemaddr = {26'hfff, 4'd3, 2'b00}
    #(10);
    cif.iload = 32'he3333333;
    cif.iwait = 0;
    #(20);
    cif.iwait = 1;
    

    dcif.imemaddr = {26'hfff, 4'd1, 2'b00};
    cif.iload = 32'h0;
    cif.iwait = 1;
    dcif.imemREN = 1;
    #(10);
 
    msg("tag matches", 1, 0, 32'he00ee00e, 0);

    dcif.imemaddr = {26'hff, 4'd2, 2'b00};
    cif.iload = 32'haaaaaaaa;
    cif.iwait = 0;
    dcif.imemREN = 1;
    #(10);

    msg("tag not match", 1, 1, 32'haaaaaaaa, {26'hff, 4'd2, 2'b00});

    dcif.imemaddr = {26'hfff, 4'd3, 2'b00};
    cif.iload = 32'h0;
    cif.iwait = 1;
    dcif.imemREN = 0;
    #(10);

    msg("not reading", 0,0,'0,'0);

end

task msg;
    string testcase;
    input logic ihit, iREN;
    input logic [31:0] imemload, iaddr; 

    begin
    correct = 0;
    if (dcif.ihit == ihit && dcif.imemload == imemload && cif.iREN == iREN && cif.iaddr == iaddr) 
        $display("Pass %s", testcase);
    else $display("!!!!!!!!failed %s", testcase);
  endtask
