`include "forward_unit_if.vh"
`include "cpu_types_pkg.vh"

module forward_unit(
    forward_unit_if.fwd fuif
);
    import cpu_types_pkg::*;

    always_comb begin
        fuif.forwardA = 0;
        fuif.forwardB = 0;

        if(fuif.mem_RegWr && fuif.mem_WrDest != 0 && fuif.mem_WrDest == fuif.ex_rs && fuif.mem_MemtoReg && fuif.dhit)
            forwardA = 2'b11;
        else if(fuif.mem_RegWr && fuif.mem_WrDest != 0 && fuif.mem_WrDest == fuif.ex_rs && !fuif.mem_MemtoReg)
            forwardA = 2'b10;
        else if(fuif.wb_RegWr && fuif.wb_WrDest != 0 && fuif.wb_WrDest == fuif.ex_rs)
            forwardA = 2'b01;

        if(fuif.mem_RegWr && fuif.mem_WrDest != 0 && fuif.mem_WrDest == fuif.ex_rt && fuif.mem_MemtoReg && fuif.dhit)
            forwardB = 2'b11;
        else if(fuif.mem_RegWr && fuif.mem_WrDest != 0 && fuif.mem_WrDest == fuif.ex_rt && !fuif.mem_MemtoReg)
            forwardB = 2'b10;
        else if(fuif.wb_RegWr && fuif.wb_WrDest != 0 && fuif.wb_WrDest == fuif.ex_rt)
            forwardB = 2'b01;
    end

endmodule
