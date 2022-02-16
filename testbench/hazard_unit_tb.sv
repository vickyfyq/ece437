`include "hazard_unit_if.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::*;

module hazard_unit_tb;
  // interface
  hazard_unit_if huif ();
  // test program
  test PROG (.huif(huif));
  // DUT
`ifndef MAPPED
  hazard_unit DUT(huif);
`else
  hazard_unit DUT (
    .\huif.mem (huif.mem),
    .\huif.flush (huif.flush)
  );
`endif
endmodule

program test(hazard_unit_if huif);
integer test_num;
task set_inputs;
  input jump;
  input jal;
  input jreg;
  input beq;
  input bne;
  input zero;
begin
  huif.mem.jump = jump;
  huif.mem.jal = jal;
  huif.mem.jreg = jreg;
  huif.mem.beq = beq;
  huif.mem.bne = bne;
  huif.mem.zero = zero;
end  
endtask;

task read_output;
  input expected;
begin
  assert(expected == huif.flush)
    $display("Correct output for test case %0d", test_num);
  else
    $display("Incorrect output for test case %0d. Expected: %0d , Actual: %0d", test_num, expected, huif.flush);
end
endtask

parameter PERIOD = 10;
initial begin
    //set_inputs(jump, jal, jreg, beq, bne, zero)
    test_num = 0;

    test_num += 1;
    set_inputs(0,0,0,0,0,0);
    #(PERIOD)
    read_output(0);

    test_num += 1;
    set_inputs(1,0,0,0,0,0);
    #(PERIOD)
    read_output(1);

    test_num += 1;
    set_inputs(0,1,0,0,0,0);
    #(PERIOD)
    read_output(1);

    test_num += 1;
    set_inputs(0,0,1,0,0,0);
    #(PERIOD)
    read_output(1);

    test_num += 1;
    set_inputs(0,0,0,1,0,0);
    #(PERIOD)
    read_output(0);

    test_num += 1;
    set_inputs(0,0,0,1,0,1);
    #(PERIOD)
    read_output(1);

    test_num += 1;
    set_inputs(0,0,0,0,1,0);
    #(PERIOD)
    read_output(1);

    test_num += 1;
    set_inputs(0,0,0,0,1,1);
    #(PERIOD)
    read_output(0);

    $finish;
end
endprogram