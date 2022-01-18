`include "alu_if.vh"
`include "cpu_types_pkg.vh"

module alu(
alu_if aluif
);
import cpu_types_pkg::*;

always_comb begin 
    aluif.overflow = 0;

    casez(aluif.aluop) 
    ALU_SLL  :aluif.outport = aluif.portA << aluif.portB;
    ALU_SRL  :aluif.outport = aluif.portA >> aluif.portB;
    ALU_ADD  : 
    begin 
        aluif.outport = $signed(aluif.portA) + $signed(aluif.portB);
        aluif.overflow = (aluif.portA[31] == aluif.portB[31]) && (aluif.portA[31] != aluif.outport[31]);
    end
    ALU_SUB  :
    begin
        aluif.outport = aluif.portA - aluif.portB;
        aluif.overflow = (aluif.portA[31] != aluif.portB[31]) && (aluif.portA[31] != aluif.outport[31]);
    end
    ALU_AND  :aluif.outport = aluif.portA & aluif.portB;
    ALU_OR   :aluif.outport = aluif.portA | aluif.portB;
    ALU_XOR  :aluif.outport = aluif.portA ^ aluif.portB;
    ALU_NOR  :aluif.outport = ~(aluif.portA | aluif.portB);
    ALU_SLT  :aluif.outport = ($signed(aluif.portA) < $signed(aluif.portB)) ? 1 : 0;
    ALU_SLTU :aluif.outport = (aluif.portA < aluif.portB) ? 1 : 0;
    default  :aluif.outport = '0; 
endcase
    //set flags
    aluif.zero = (aluif.outport == 0) ? 1 : 0; //if output is 0 then zero flag is high
    aluif.negative = aluif.outport[31];
end

endmodule