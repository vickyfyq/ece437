`ifndef ALU_IF_VH
`define ALU_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface alu_if;
    // import types
    import cpu_types_pkg::*;
    aluop_t aluop;
    word_t portA, portB, outport;
    logic negative, overflow, zero;

endinterface

`endif //REGISTER_FILE_IF_VH