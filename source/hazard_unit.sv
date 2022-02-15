`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"

module hazard_unit(
    hazard_unit_if.hzd huif
);
    import cpu_types_pkg::*;
    always_comb begin
        if ((huif.mem.beq && huif.mem.zero != 0) ||(huif.mem.bne && huif.mem.zero = 0)) //taken
            huif.mem.flush = 1;
        else if (huif.mem.jump || huif.mem.jreg || huif.mem.jal)    
            huif.mem.flush = 1;
        else    
            huif.mem.flush = 0;
    end

endmodule