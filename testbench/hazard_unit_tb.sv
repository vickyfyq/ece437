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
    .\huif.jal (huif.jal ),
    .\huif.jreg (huif.jreg ),
    .\huif.jump (huif.jump ),
    .\huif.bne (huif.bne ),
    .\huif.beq (huif.beq ),
    .\huif.zero (huif.zero),
    .\huif.flush (huif.flush)
  );
`endif
endmodule

program test(control_unit_if huif);

task set_inputs;
  input jump;
  input jal;
  input jreg;
  input beq;
  input bne;
  input zero;
begin
  huif.jump = jump;
  huif.jal = jal;
  huif.jreg = jreg;
  huif.beq = beq;
  huif.bne = bne;
  huif.zero = zero;
end  
endtask;

task read_output;
  input expected;
begin
  assert(expected == huif.hazard)
    $display("Correct output for test case %0d", test_num);
  else
    $display("Incorrect output for test case %0d. Expected: %0d , Actual: %0d", test_num, expected, huif.hazard);
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
    read_output(1);

    $finish;
end
endprogram