`include "pipeline_reg_if.vh"
`include "cpu_types_pkg.vh"

module pipeline_reg(
    input logic CLK, nRST, ihit, dhit,
    pipeline_reg_if prif
);
assign wb_enable = ihit | dhit;

//////////////////////////// Pipeline //////////////////////////
assign wb_enable = ihit |dhit;
  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      prif.id   <= '0; //'{default:'0}
      prif.ex   <= '0;
      prif.mem  <= '0;
      prif.wb   <= '0;
    end
    else if((prif.flush || prif.mem.Halt) && (ihit || dhit)) begin
      prif.id <= '0;
      prif.ex <= '0;
      prif.mem <= '0;

/////////////////////     MEMWB STAGE    ///////////////////////////
      prif.wb.npc    <= prif.mem.npc;
      prif.wb.imemload <= prif.mem.imemload;
      prif.wb.branchAddr <= prif.mem.branchAddr;
      prif.wb.pc <= prif.mem.pc;
      prif.wb.cur_imm    <= prif.mem.cur_imm;
      prif.wb.lui_imm   <= prif.mem.lui_imm;
      prif.wb.rdat2    <= prif.mem.rdat2;
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
    else if(prif.stall && (ihit || dhit)) begin
      prif.ex <= '0;
      /////////////////////     EXMEM STAGE    ///////////////////////////
      prif.mem.npc    <= prif.ex.npc;
      prif.mem.imemload <= prif.ex.imemload;
      prif.mem.pc <= prif.ex.pc;
      prif.mem.cur_imm    <= prif.ex.cur_imm;
      prif.mem.lui_imm   <= prif.ex.lui_imm;
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
      prif.mem.rdat2    <= prif.in_aluPortB;
      prif.mem.ALUout   <= prif.in_ALUout;
      prif.mem.zero     <= prif.in_zero;
      prif.mem.branchAddr <= prif.in_branchAddr;
      prif.mem.jumpAddr <= prif.in_jumpAddr;
      prif.mem.rdat1    <= prif.ex.rdat1;
      //write back register
      prif.mem.WrDest   <= prif.in_WrDest;
      /////////////////////     MEMWB STAGE    ///////////////////////////
      prif.wb.npc        <= prif.mem.npc;
      prif.wb.imemload   <= prif.mem.imemload;
      prif.wb.branchAddr <= prif.mem.branchAddr;
      prif.wb.pc         <= prif.mem.pc;
      prif.wb.cur_imm    <= prif.mem.cur_imm;
      prif.wb.lui_imm    <= prif.mem.lui_imm;
      prif.wb.rdat2      <= prif.mem.rdat2;
      //Control unit signals
      prif.wb.RegWr      <= prif.mem.RegWr;
      prif.wb.MemtoReg   <= prif.mem.MemtoReg;
      prif.wb.Halt       <= prif.mem.Halt;
      prif.wb.jal        <= prif.mem.jal;
      //wdat
      prif.wb.ALUout     <= prif.mem.ALUout;
      prif.wb.dmemload   <= prif.in_dmemload;
      //wsel
      prif.wb.WrDest     <= prif.mem.WrDest;
    end
    else if(ihit & !dhit)begin //stall when instr not ready
/////////////////////   IFID STAGE    ///////////////////////////
      //instruction
      prif.id.imemload  <= prif.in_imemload;
      //pc 
      prif.id.npc       <= prif.in_npc;
      prif.id.pc        <= prif.in_pc;

/////////////////////   IDEX STAGE    ///////////////////////////
      prif.ex.lui_imm   <= prif.in_lui_imm;
      prif.ex.pc        <= prif.id.pc;
      //instruction
      prif.ex.imemload  <= prif.id.imemload;
      //pc
      prif.ex.npc       <= prif.id.npc;      
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
      prif.mem.imemload <= prif.ex.imemload;
      prif.mem.pc <= prif.ex.pc;
      prif.mem.cur_imm    <= prif.ex.cur_imm;
      prif.mem.lui_imm   <= prif.ex.lui_imm;
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
      prif.mem.rdat2    <= prif.in_aluPortB;
      prif.mem.ALUout   <= prif.in_ALUout;
      prif.mem.zero     <= prif.in_zero;
      prif.mem.branchAddr <= prif.in_branchAddr;
      prif.mem.jumpAddr <= prif.in_jumpAddr;
      prif.mem.rdat1    <= prif.ex.rdat1;
      //write back register
      prif.mem.WrDest   <= prif.in_WrDest;
      /////////////////////     MEMWB STAGE    ///////////////////////////
      prif.wb.npc        <= prif.mem.npc;
      prif.wb.imemload   <= prif.mem.imemload;
      prif.wb.branchAddr <= prif.mem.branchAddr;
      prif.wb.pc         <= prif.mem.pc;
      prif.wb.cur_imm    <= prif.mem.cur_imm;
      prif.wb.lui_imm    <= prif.mem.lui_imm;
      prif.wb.rdat2      <= prif.mem.rdat2;
      //Control unit signals
      prif.wb.RegWr      <= prif.mem.RegWr;
      prif.wb.MemtoReg   <= prif.mem.MemtoReg;
      prif.wb.Halt       <= prif.mem.Halt;
      prif.wb.jal        <= prif.mem.jal;
      //wdat
      prif.wb.ALUout     <= prif.mem.ALUout;
      prif.wb.dmemload   <= prif.in_dmemload;
      //wsel
      prif.wb.WrDest     <= prif.mem.WrDest;
    end 
    else if (dhit) begin
/////////////////////   IFID STAGE    ///////////////////////////
      prif.id <= '0;
/////////////////////   IDEX STAGE    ///////////////////////////
      prif.ex.lui_imm   <= prif.in_lui_imm;
      prif.ex.pc <= prif.id.pc;
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
      prif.mem.imemload <= prif.ex.imemload;
      prif.mem.pc <= prif.ex.pc;
      prif.mem.cur_imm    <= prif.ex.cur_imm;
      prif.mem.lui_imm   <= prif.ex.lui_imm;
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
      prif.mem.rdat2    <= prif.in_aluPortB;
      prif.mem.ALUout   <= prif.in_ALUout;
      prif.mem.zero     <= prif.in_zero;
      prif.mem.branchAddr <= prif.in_branchAddr;
      prif.mem.jumpAddr <= prif.in_jumpAddr;
      prif.mem.rdat1    <= prif.ex.rdat1;
      //write back register
      prif.mem.WrDest   <= prif.in_WrDest;
/////////////////////     MEMWB STAGE    ///////////////////////////
      prif.wb.imemload   <= prif.mem.imemload;  
      prif.wb.npc        <= prif.mem.npc;
      prif.wb.branchAddr <= prif.mem.branchAddr;
        prif.wb.cur_imm    <= prif.mem.cur_imm;
        prif.wb.lui_imm   <= prif.mem.lui_imm;
        prif.wb.pc <= prif.mem.pc;
      //Control unit signals
        // prif.mem.MemWr <= 0;
        // prif.mem.MemtoReg <= 0;
        
      
      prif.wb.rdat2    <= prif.mem.rdat2;
      prif.wb.RegWr    <= prif.mem.RegWr;
      prif.wb.MemtoReg <= prif.mem.MemtoReg;
      
      prif.wb.Halt       <= prif.mem.Halt;
      prif.wb.jal        <= prif.mem.jal;
      //wdat  
      prif.wb.ALUout     <= prif.mem.ALUout;
      prif.wb.dmemload   <= prif.in_dmemload;
      //wsel  
      prif.wb.WrDest     <= prif.mem.WrDest;

    end/*
    else if (prif.flush) begin
      prif.id   <= '0; //flush wrong branch target
      prif.ex   <= '0;
    end*/
  end
endmodule