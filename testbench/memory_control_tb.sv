`include "cache_control_if.vh"
`include "cpu_ram_if.vh"
`include "caches_if.vh"
`include "cpu_types_pkg.vh"


`timescale 1 ns / 1 ns

module memory_control_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // clock
  always #(PERIOD/2) CLK++;

  caches_if cif0();
  caches_if cif1();
  cache_control_if #(.CPUS(1))ccif(cif0,cif1);
  cpu_ram_if crif();

  assign ccif.ramload =crif.ramload;
  assign ccif.ramstate = crif.ramstate;
  assign crif.ramstore = ccif.ramstore;
  assign crif.ramaddr = ccif.ramaddr;
  assign crif.ramWEN = ccif.ramWEN;
  assign crif.ramREN = ccif.ramREN;

  test PROG (CLK, nRST, ccif);
    // DUT
`ifndef MAPPED
  memory_control DUT(CLK, nRST, ccif);
  ram ramstuff(CLK,nRST,crif);
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


  task automatic dump_memory();
    string filename = "memcpu.hex";
    int memfd;

    
    cif0.daddr = 0;
    cif0.dWEN = 0;
    cif0.dREN = 0;

    memfd = $fopen(filename,"w");
    if (memfd)
      $display("Starting memory dump.");
    else
      begin $display("Failed to open %s.",filename); $finish; end

    for (int unsigned i = 0; memfd && i < 16384; i++)
    begin
      int chksum = 0;
      bit [7:0][7:0] values;
      string ihex;

      cif0.daddr = i << 2;
      cif0.dREN = 1;
      repeat (4) @(posedge CLK);
      if (cif0.dload === 0)
        continue;
      values = {8'h04,16'(i),8'h00,cif0.dload};
      foreach (values[j])
        chksum += values[j];
      chksum = 16'h100 - chksum;
      ihex = $sformatf(":04%h00%h%h",16'(i),cif0.dload,8'(chksum));
      $fdisplay(memfd,"%s",ihex.toupper());
    end //for
    if (memfd)
    begin
     
      cif0.dREN = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask


initial begin


  //reset
  nRST = 0;
  cif0.iaddr = 0;
  cif0.daddr = 0;
  cif0.iREN = 0;
  cif0.dWEN = 0;
  cif0.dREN = 0;
  cif0.dstore = 32'h00000000;
  @(negedge CLK);
  @(negedge CLK);

  //d and i hit same time
  nRST = 1;
  cif0.iaddr = 32'h00000004;
  cif0.daddr = 32'h00000004;
  cif0.dstore = 32'h00000004;
  cif0.iREN = 1;
  cif0.dWEN = 1;
  cif0.dREN = 0;
  @(negedge CLK);
  @(negedge CLK);

  //read ins
  for (int i = 0; i < 10; i++) begin
    cif0.iaddr = i << 2; 
    cif0.iREN = 1'b1;
    cif0.dWEN = 1'b0;
    cif0.dREN = 1'b0;
  @(negedge CLK);
  @(negedge CLK);
  end
  @(negedge CLK);
  @(negedge CLK);
  @(negedge CLK);

//     //load from addr
//   cif0.daddr = 1 << 2; 
//   cif0.iREN = 1'b0;
//   cif0.dWEN = 1'b0;
//   cif0.dREN = 1'b1;
//   @(negedge CLK);
//   @(negedge CLK);
//   @(negedge CLK);  @(negedge CLK);
//   @(negedge CLK);
 
// //write from addr
//   cif0.daddr = 1 << 2; 
//   cif0.iREN = 1'b0;
//   cif0.dWEN = 1'b1;
//   cif0.dREN = 1'b0;
//   @(negedge CLK);  @(negedge CLK);
//   @(negedge CLK);  @(negedge CLK);
//   @(negedge CLK);  @(negedge CLK);
//   @(negedge CLK);
// //load from address
//   cif0.daddr = 1 << 2; 
//   cif0.iREN = 1'b0;
//   cif0.dWEN = 1'b0;
//   cif0.dREN = 1'b1;
//   @(negedge CLK);
//   @(negedge CLK);
//   @(negedge CLK);  @(negedge CLK);
//   @(negedge CLK);  @(negedge CLK);
//   @(negedge CLK);


//   cif0.iREN = 0;
//   cif0.iaddr = 32'h0;

//   //write to mem dump mem
//   cif0.dWEN = 1;ooo
//   cif0.daddr = 32'h00000004;
//   cif0.dstore = 32'h00000abc;
//   @(negedge CLK);
//   @(negedge CLK);
//   @(negedge CLK);
//   @(negedge CLK);
//   @(negedge CLK);
//   cif0.dWEN = 0;
//   @(negedge CLK);
//   @(negedge CLK);
//   @(negedge CLK);
//   @(negedge CLK);
//   @(negedge CLK);
//   cif0.iaddr = 32'h0;
//   cif0.daddr = 32'h0;
//   cif0.iREN = 0;
//   cif0.dWEN = 0;
//   cif0.dREN = 0;
//   @(negedge CLK);
//   @(negedge CLK);



dump_memory();
$finish;
end



endprogram
