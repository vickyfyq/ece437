`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface hazard_unit_if;
    // import types
    import cpu_types_pkg::*;
    typedef struct packed {
    logic jal,jreg,jump;
    logic bne, beq, zero;
    } hazard;
    logic flush;
    hazard mem;

    modport hzd(
        input mem, output flush
    );
    modport tb(
        output mem, input flush
    );



endinterface

`endif //REGISTER_FILE_IF_VH
