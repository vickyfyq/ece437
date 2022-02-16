`include "forward_unit_if.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::*;

module forward_unit_tb;
  // interface
  forward_unit_if fuif ();
  // test program
  test PROG (.fuif(fuif));
  // DUT
`ifndef MAPPED
  forward_unit DUT(fuif);
`else
  forward_unit DUT (
    .\fuif.ex_rs(fuif.ex_rs),
    .\fuif.ex_rt(fuif.ex_rt),
    .\fuif.mem_WrDest(fuif.mem_WrDest),
    .\fuif.wb_WrDest(fuif.wb_WrDest), 
    .\fuif.wr_wrDest(fuif.wr_wr),
    .\fuif.mem_MemtoReg(fuif.mem_MemtoReg), 
    .\fuif.mem_RegWr(fuif.mem_RegWr), 
    .\fuif.wb_RegWr(fuif.wb_RegWr), 
    .\fuif.dhit(fuif.dhit),
    .\fuif.forwardA(fuif.forwardA),
    .\fuif.forwardB(fuif.forwardB)
  );
`endif
endmodule

program test(forward_unit_if fuif);
  string test_num;
task set_inputs;
    input ex_rs, ex_rt, mem_WrDest, wb_WrDest, mem_MemtoReg, mem_RegWr, wb_RegWr, dhit;
begin
    fuif.ex_rs        = ex_rs;
    fuif.ex_rt        = ex_rt;
    fuif.mem_WrDest   = mem_WrDest;
    fuif.wb_WrDest    = wb_WrDest;
    fuif.mem_MemtoReg = mem_MemtoReg;
    fuif.mem_RegWr    = mem_RegWr;
    fuif.wb_RegWr     = wb_RegWr;
    fuif.dhit         = dhit;
end  
endtask;

task read_output;
  input ex_A, ex_B;
begin
  assert(ex_A == fuif.forwardA && ex_B == fuif.forwardB)
    $display("Correct output for test case %s", test_num);
  else begin
    $display("Incorrect output for test case %s. Expected fwdA: %0d  , Actual fwdA: %0d", test_num, ex_A, fuif.forwardA);
    $display("Incorrect output for test case %s. Expected fwdB: %0d  , Actual fwdB: %0d", test_num, ex_B, fuif.forwardB);
  end
  end
endtask

parameter PERIOD = 10;
initial begin
    //set_inputs(ex_rs, ex_rt, mem_WrDest, wb_WrDest, 
  //mem_MemtoReg, mem_RegWr, wb_RegWr, dhit)
    test_num = "";

    //forward A rtype
    test_num ="A 00";
    set_inputs('0,'0,'0,'0,0,0,0,0);
    #(PERIOD)
    read_output(2'b00,2'b00);

    test_num ="A 11";
    set_inputs(5'd3,'0,5'd3,'0,1,1,0,1);
    #(PERIOD)
    read_output(2'b11,2'b00);

    test_num ="A 10";
    set_inputs(5'd4,'0,5'd4,'0,0,1,0,0);
    #(PERIOD)
    read_output(2'b10,2'b00);

    test_num ="A 01";
    set_inputs(5'd5,'0,'0,5'd5,0,0,1,0);
    #(PERIOD)
    read_output(2'b01,2'b00);

    //forward B itype
    test_num ="B 00";
    set_inputs('0,'0,'0,'0,0,0,0,0);
    #(PERIOD)
    read_output(2'b00,2'b00);

    test_num ="B 11";
    set_inputs('0,5'd3,5'd3,'0,1,1,0,1);
    #(PERIOD)
    read_output(2'b00,2'b11);

    test_num ="B 10";
    set_inputs('0,5'd4,5'd4,'0,0,1,0,0);
    #(PERIOD)
    read_output(2'b00,2'b10);

    test_num ="B 01";
    set_inputs('0,5'd5,'0,5'd5,0,0,1,0);
    #(PERIOD)
    read_output(2'b00,2'b01);


    $finish;
end
endprogram