`include "pipeline_reg_if.vh"
`include "cpu_types_pkg.vh"

module pipeline_reg(
    input logic CLK, nRST, ihit, dhit,
    pipeline_reg_if prif
);
/////////////////////////////// Pipeline /////////////////////////////////////////

  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      prif.id <= '0; //'{default:'0}
      prif.ex <= '0;
      prif.mem <= '0;
      prif.wb <= '0;
    end
    else if(ihit & !dhit)begin //stall when instr not ready
/////////////////////   IFID STAGE    ///////////////////////////
      //instruction
      prif.id.imemload <= prif.in_imemload;
      //pc
      prif.id.npc      <= prif.in_npc;

/////////////////////   IDEX STAGE    ///////////////////////////
      //instruction
      prif.ex.imemload <= prif.id.imemload;
      //pc
      prif.ex.npc <= prif.id.npc;      
      //Control unit signals
      prif.ex.RegDst   <= prif.in_RegDst;
      prif.ex.ALUSrc   <= prif.in_ALUSrc;
      prif.ex.ALUOp    <= prif.in_ALUop;
      prif.ex.MemWr    <= prif.in_MemWr;
      prif.ex.beq      <= prif.in_beq;
      prif.ex.bne      <= prif.in_bne;
      prif.ex.jump     <= prif.in_jump;
      prif.ex.jreg     <= prif.in_jreg;
      prif.ex.jal      <= prif.in_jal;
      prif.ex.RegWr    <= prif.in_RegWr;
      prif.ex.MemtoReg <= prif.in_MemtoReg;
      prif.ex.Halt     <= prif.in_Halt;
      //register file output
      prif.ex.rdat1      <= prif.in_rdat1;
      prif.ex.rdat2      <= prif.in_rdat2;
      //extended immediate 
      prif.ex.cur_imm    <= prif.in_cur_imm;
      //rt rd for WrDest
      prif.ex.rt       <= prif.in_rt;
      prif.ex.rd       <= prif.in_rd;

/////////////////////   EXMEM STAGE    ///////////////////////////
      prif.mem.npc    <= prif.ex.npc;
      //Control unit signals
      prif.mem.MemWr    <= prif.ex.MemWr;
      prif.mem.beq      <= prif.ex.beq;
      prif.mem.bne      <= prif.ex.bne;
      prif.mem.jump     <= prif.ex.jump;
      prif.mem.jreg     <= prif.ex.jreg;
      prif.mem.jal      <= prif.ex.jal;
      prif.mem.RegWr    <= prif.ex.RegWr;
      prif.mem.MemtoReg <= prif.ex.MemtoReg;
      prif.mem.Halt     <= prif.ex.Halt;
      //alu
      prif.mem.rdat2    <= prif.ex.rdat2;
      prif.mem.ALUout   <= prif.in_ALUout;
      prif.mem.zero     <= prif.in_zero;
      prif.mem.branchAddr <= prif.in_branchAddr;
      prif.mem.jumpAddr <= prif.in_jumpAddr;
      prif.mem.rdat1    <= prif.ex.rdat1;
      //write back register
      prif.mem.WrDest   <= prif.in_WrDest;
      /////////////////////     MEMWB STAGE    ///////////////////////////
      prif.wb.npc    <= prif.mem.npc;
      //Control unit signals
      prif.wb.RegWr    <= prif.mem.RegWr;
      prif.wb.MemtoReg <= prif.mem.MemtoReg;
      prif.wb.Halt     <= prif.mem.Halt;
      prif.wb.jal      <= prif.mem.jal;
      //wdat
      prif.wb.ALUout   <= prif.mem.ALUout;
      prif.wb.dmemload <= prif.in_dmemload;
      //wsel
      prif.wb.WrDest   <= prif.mem.WrDest;
    end 
    else if (dhit) begin
/////////////////////     MEMWB STAGE    ///////////////////////////
        prif.wb.npc    <= prif.mem.npc;
      //Control unit signals
        // prif.mem.MemWr <= 0;
        // prif.mem.MemtoReg <= 0;
        prif.mem <= '0;
      prif.wb.RegWr    <= prif.mem.RegWr;
      prif.wb.RegWr    <= prif.mem.RegWr;
      prif.wb.MemtoReg <= prif.mem.MemtoReg;
      
      prif.wb.Halt     <= prif.mem.Halt;
      prif.wb.jal      <= prif.mem.jal;
      //wdat
      prif.wb.ALUout   <= prif.mem.ALUout;
      prif.wb.dmemload <= prif.in_dmemload;
      //wsel
      prif.wb.WrDest   <= prif.mem.WrDest;

    end
  end
endmodule