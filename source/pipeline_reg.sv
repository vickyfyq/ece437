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
      prif.id.imemload <= in_imemload;
      //pc
      prif.id.npc      <= in_npc;

/////////////////////   IDEX STAGE    ///////////////////////////
      //instruction
      prif.ex.imemload <= prif.id.imemload;
      //pc
      prif.ex.npc <= prif.id.npc;      
      //Control unit signals
      prif.ex.RegDst   <= in_RegDst;
      prif.ex.ALUSrc   <= in_ALUSrc;
      prif.ex.ALUop    <= in_ALUop;
      prif.ex.MemWr    <= in_MemWr;
      prif.ex.beq      <= in_beq;
      prif.ex.bne      <= in_bne;
      prif.ex.jump     <= in_jump;
      prif.ex.jreg     <= in_jreg;
      prif.ex.jal      <= in_jal;
      prif.ex.RegWr    <= in_RegWr;
      prif.ex.MemtoReg <= in_MemtoReg;
      prif.ex.Halt     <= in_Halt;
      //register file output
      prif.ex.rdat1      <= in_rdat1;
      prif.ex.rdat2      <= in_rdat2;
      //extended immediate 
      prif.ex.cur_imm    <= in_cur_imm;
      //rt rd for WrDest
      prif.ex.rt       <= in_rt;
      prif.ex.rd       <= in_rd;

/////////////////////   EXMEM STAGE    ///////////////////////////
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
      prif.mem.ALUout   <= in_outport;
      prif.mem.zero     <= in_zero;
      prif.mem.branchAddr <= in_branchAddr;
      prif.mem.jumpAddr <= in_jumpAddr;
      prif.mem.rdat1    <= prif.ex.rdat1;
      //write back register
      prif.mem.WrDest   <= in_WrDest;
    end 
    else if (dhit) begin
/////////////////////     MEMWB STAGE    ///////////////////////////
      //Control unit signals
      prif.wb.RegWr    <= prif.mem.RegWr;
      prif.wb.MemtoReg <= prif.mem.MemtoReg;
      prif.wb.Halt     <= prif.mem.Halt;

      //wdat
      prif.wb.ALUout   <= prif.mem.ALUout;
      prif.wb.dmemload <= in_dmemload;
      //wsel
      prif.wb.WrDest   <= prif.mem.WrDest;

    end
  end