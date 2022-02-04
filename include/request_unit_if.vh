`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH

// typedefs
`include "cpu_types_pkg.vh"

interface request_unit_if;
    import cpu_types_pkg::*;

    logic ihit, dhit, dmemREN, dmemWEN, MemtoReg, MemWr;

endinterface

`endif 