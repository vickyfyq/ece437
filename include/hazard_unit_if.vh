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

    typedef struct packed {
        regbits_t rt;
        logic MemtoReg;
    } ex_hazard;

    typedef struct packed {
        regbits_t rs, rt;
    } id_hazard;

    logic flush, stall;
    hazard mem;
    ex_hazard ex;
    id_hazard id;

    modport hzd(
        input mem, ex, id,
        output flush, stall
    );
    modport tb(
        output mem, ex, id,
        input flush, stall
    );



endinterface

`endif //REGISTER_FILE_IF_VH
