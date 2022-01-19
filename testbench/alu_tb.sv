`include "alu_if.vh"
`timescale 1 ns / 1 ns
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
module alu_tb;
parameter PERIOD = 10;
logic CLK = 0;
// clock
always #(PERIOD/2) CLK++;
//interface 
alu_if aluif();
test PROG(CLK, aluif);
  // DUT
`ifndef MAPPED
  alu DUT(aluif);
`else
  alu DUT(
    .\aluif.aluop    (aluif.aluop   ),
    .\aluif.overflow (aluif.overflow),
    .\aluif.negative (aluif.negative),
    .\aluif.zero     (aluif.zero    ),
    .\aluif.outport  (aluif.outport ),
    .\aluif.portA    (aluif.portA   ),
    .\aluif.portB    (aluif.portB   )
  );
`endif

endmodule
program test (input logic CLK, alu_if aluif);
initial begin
    
    aluif.aluop = ALU_SLL ;
    aluif.portA = 32'hf; //1111
    aluif.portB = 32'h8; //111100000000
    //result should be 0xf00
    @(negedge CLK)
    if (aluif.outport == (aluif.portB << aluif.portA))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    

    aluif.aluop = ALU_SRL ;
    aluif.portA = 32'hf0000000;
    aluif.portB = 32'h4;
    //result should be 0x0f000000
    @(negedge CLK)
    if (aluif.outport == (aluif.portB >> aluif.portA))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    
//-+
    aluif.aluop = ALU_ADD ;
    aluif.portA = 32'hffffffff;//-1
    aluif.portB = 32'h2;//2
    //-1+2 
    @(negedge CLK)
    if (aluif.outport == ($signed(aluif.portA) + $signed(aluif.portB)))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 0) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");

//+-
    //7+(-6) 
    aluif.aluop = ALU_ADD ;
    aluif.portA = 32'h7;
    aluif.portB = 32'hfffffffa; // result should 1
    //check overflow
    @(negedge CLK)
    if (aluif.outport == ($signed(aluif.portA) + $signed(aluif.portB)))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 0) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");

//++
//two positive int
    aluif.aluop = ALU_ADD ;
    aluif.portA = 32'hff;
    aluif.portB = 32'hff; // result should 0x1fe
    //check overflow
    @(negedge CLK)
    if (aluif.outport == ($signed(aluif.portA) + $signed(aluif.portB)))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 0) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");
//--
//(-16)+(-6) 
    aluif.aluop = ALU_ADD ;
    aluif.portA = 32'hfffffff0;
    aluif.portB = 32'hfffffffa; // result should be ffffffea
    //check overflow
    @(negedge CLK)
    if (aluif.outport == ($signed(aluif.portA) + $signed(aluif.portB)))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 0) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");
    if (aluif.negative == 1) $display("negative passed");
    else $display("ERROR:::::::negative is 0");

    aluif.aluop = ALU_ADD ;
    aluif.portA = 32'h80000001;
    aluif.portB = 32'h7fffffff; // result should be 0
    //check overflow
    @(negedge CLK)
    if (aluif.outport == ($signed(aluif.portA) + $signed(aluif.portB)))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 0) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");
    if (aluif.zero == 1) $display("zero flagpassed");
    else $display("ERROR:::::::zeroflag is 0");

//////////////////////////////////////////////
//neg overflow 
    
    aluif.aluop = ALU_ADD ;
    aluif.portA = 32'h80000000;
    aluif.portB = 32'hffffffff; // result should be 7fffffff
    //check overflow
    @(negedge CLK)
    if (aluif.outport == ($signed(aluif.portA) + $signed(aluif.portB)))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 1) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");

//pos overflow
    //7fffffff + 1  pos overflow
    aluif.aluop = ALU_ADD ;
    aluif.portA = 32'h7fffffff;
    aluif.portB = 32'h1; // result should be 80000000
    //check overflow
    @(negedge CLK)
    if (aluif.outport == ($signed(aluif.portA) + $signed(aluif.portB)))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 1) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");


//+- 7fffffff - (-1)  pos overflow
    aluif.aluop = ALU_SUB ;
    aluif.portA = 32'h7fffffff;
    aluif.portB = 32'hffffffff;
    @(negedge CLK)
    if (aluif.outport == (aluif.portA - aluif.portB))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 1) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");

//////////////////////////////////////////
//+- efffffff - (1) neg overflow
    aluif.aluop = ALU_SUB ;
    aluif.portA = 32'h80000000;
    aluif.portB = 32'h1;
    @(negedge CLK)
    if (aluif.outport == (aluif.portA - aluif.portB))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 1) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");


//normal sub
    aluif.aluop = ALU_SUB ;
    aluif.portA = 32'hff;
    aluif.portB = 32'ha;
    @(negedge CLK)
    if (aluif.outport == (aluif.portA - aluif.portB))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    if (aluif.overflow == 0) $display("overflow passed");
    else $display("ERROR:::::::overflow is 1");
    

    aluif.aluop = ALU_AND ;
    aluif.portA = 32'hff5a;
    aluif.portB = 32'hffa5;
    @(negedge CLK)
    if (aluif.outport == (aluif.portA & aluif.portB))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    

    aluif.aluop = ALU_OR  ;
    aluif.portA = 32'ha5;
    aluif.portB = 32'h5a;
    @(negedge CLK)
    if (aluif.outport == (aluif.portA | aluif.portB))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    

    aluif.aluop = ALU_XOR ;
    aluif.portA = 32'hfa5;
    aluif.portB = 32'hf5a;
    @(negedge CLK)
    if (aluif.outport == (aluif.portA ^ aluif.portB))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    

    aluif.aluop = ALU_NOR ;
    aluif.portA = 32'hfa5;
    aluif.portB = 32'hf5a;
    @(negedge CLK)
    if (aluif.outport == ~(aluif.portA | aluif.portB))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    

    aluif.aluop = ALU_SLT ;
    aluif.portA = 32'hfa5;
    aluif.portB = 32'hf5a;
    @(negedge CLK)
    if (aluif.outport == ($signed(aluif.portA) < $signed(aluif.portB)))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);
    

    aluif.aluop = ALU_SLTU;
    aluif.portA = 32'hfa5;
    aluif.portB = 32'hf5a;
    @(negedge CLK)
    if (aluif.outport == (aluif.portA < aluif.portB))begin
        $display("test passed %b", aluif.aluop);
    end
    else $display("!!!!!!!!!!Error %b", aluif.aluop);


end
endprogram
