`include "control_unit_if.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::*;

module control_unit_tb;
  // interface
  control_unit_if cuif ();
  // test program
  test PROG (.cuif(cuif));
  // DUT
`ifndef MAPPED
  control_unit DUT(cuif);
`else
  control_unit DUT (
	.\cuif.instruction (cuif.instruction),
	.\cuif.MemtoReg (cuif.MemtoReg),
    .\cuif.Halt (cuif.Halt), 
    .\cuif.jal (cuif.jal ),
    .\cuif.jreg (cuif.jreg ),
    .\cuif.jump (cuif.jump ),
    .\cuif.bne (cuif.bne ),
    .\cuif.beq (cuif.beq ),
    .\cuif.MemWr (cuif.MemWr ),
    .\cuif.ALUSrc (cuif.ALUSrc ),
    .\cuif.lui (cuif.lui ),
    .\cuif.signext (cuif.signext ),
    .\cuif.zeroext (cuif.zeroext ),
    .\cuif.RegDst (cuif.RegDst ),
    .\cuif.RegWr (cuif.RegWr ),
    .\cuif.ALUOp (cuif.ALUOp)

  );
`endif
endmodule

program test(control_unit_if cuif);
parameter PERIOD = 10;
initial begin
    cuif.instruction = 32'h340100F0;// ORI R1, R0, 240
    #(PERIOD);
    cuif.instruction = 32'h34020080;// ORI R2, R0, 128
    #(PERIOD);
    cuif.instruction = 32'h8C230000;//LW R3, 0(R1)
    #(PERIOD);
    #(PERIOD);
    #(PERIOD);
    cuif.instruction = 32'h8C240004;//LW R4, 4(R1)
    #(PERIOD);
    #(PERIOD);
    #(PERIOD);
    cuif.instruction = 32'h8C250008;//LW R5, 8(R1)
    #(PERIOD);
    #(PERIOD);
    #(PERIOD);
    cuif.instruction = 32'hAC430000;//SW R3, 0(R2)
    #(PERIOD);
    #(PERIOD);
    #(PERIOD);
    cuif.instruction = 32'hAC440004;//SW R4, 4(R2)
    #(PERIOD);
    #(PERIOD);
    #(PERIOD);
    cuif.instruction = 32'hAC450008;//SW R5, 8(R2)
    #(PERIOD);
    #(PERIOD);
    #(PERIOD);
    cuif.instruction = 32'hAC47000C;//SW R7, 12(R2)
    #(PERIOD);
    #(PERIOD);
    #(PERIOD);
    cuif.instruction = 32'h00A24826; //xor
    #(PERIOD);
    cuif.instruction = 32'h00223021; //addu
    #(PERIOD);
    cuif.instruction = 32'h03E00008; //jr
    #(PERIOD);
    cuif.instruction = 32'h158B0001; //bne
    #(PERIOD);

    cuif.instruction = 32'hFFFFFFFF;//halt
    #(PERIOD);
    $finish;
end
endprogram