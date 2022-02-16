`include "cpu_types_pkg.vh"
`include "forward_unit_if.vh"

module forward_unit(
    forward_unit_if.fwd fuif
);
    import cpu_types_pkg::*;

    always_comb begin
        fuif.forwardA = 0;
        fuif.forwardB = 0;
        
        //regWr WrDest=rs memtoreg dhit// mem.dmemload to ex.alu_portA
        if(fuif.mem_RegWr && fuif.mem_WrDest != 0 && fuif.mem_WrDest == fuif.ex_rs && fuif.mem_MemtoReg && fuif.dhit) 
            fuif.forwardA = 2'b11;
        //regWr WrDest=rs // mem.aluout to ex.alu_portA
        else if(fuif.mem_RegWr && fuif.mem_WrDest != 0 && fuif.mem_WrDest == fuif.ex_rs && !fuif.mem_MemtoReg)
            fuif.forwardA = 2'b10;
        //regWr WrDest=rs // wb.aluout to ex.alu_portA
        else if(fuif.wb_RegWr && fuif.wb_WrDest != 0 && fuif.wb_WrDest == fuif.ex_rs)
            fuif.forwardA = 2'b01;
        
        //regWr WrDest=rs memtoreg dhit// mem.dmemload to ex.alu_portB
        if(fuif.mem_RegWr && fuif.mem_WrDest != 0 && fuif.mem_WrDest == fuif.ex_rt && fuif.mem_MemtoReg && fuif.dhit)
            fuif.forwardB = 2'b11;
        //regWr WrDest=rs // mem.aluout to ex.alu_portB
        else if(fuif.mem_RegWr && fuif.mem_WrDest != 0 && fuif.mem_WrDest == fuif.ex_rt && !fuif.mem_MemtoReg)
            fuif.forwardB = 2'b10; 
        //regWr WrDest=rs // wb.aluout to ex.alu_portB
        else if(fuif.wb_RegWr && fuif.wb_WrDest != 0 && fuif.wb_WrDest == fuif.ex_rt)
            fuif.forwardB = 2'b01;
    end

endmodule
