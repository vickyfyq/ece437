`ifndef FORWARD_UNIT_IF_VH
`define FORWARD_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface forward_unit_if;
    // import types
    import cpu_types_pkg::*;
    
    regbits_t ex_rs, ex_rt, mem_WrDest, wb_WrDest;
    logic mem_RegWr, wb_RegWr, dhit, mem_MemtoReg;
    logic [1:0] forwardA, forwardB;

modport fwd (
input ex_rs, ex_rt, mem_WrDest, wb_WrDest, mem_MemtoReg, mem_RegWr, wb_RegWr, dhit,
output forwardA, forwardB
);

modport tb (
output ex_rs, ex_rt, mem_WrDest, wb_WrDest, mem_MemtoReg, mem_RegWr, wb_RegWr, dhit,
input forwardA, forwardB
);

endinterface

`endif //REGISTER_FILE_IF_VH
