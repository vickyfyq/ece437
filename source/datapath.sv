/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"
`include "control_unit_if.vh"
`include "request_unit_if.vh"
`include "register_file_if.vh"
`include "alu_if.vh"
// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dcif,
  datapath_if dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc initdpif
  word_t pc, npc, pc_p4;
  assign pc_p4 = pc+4;
  i_t iditype;
  r_t idrtype;
  j_t exjtype;

  //initialize instructions stuff
  assign cuif.instruction = dpif.id.imemload;
  assign idrtype = dpif.id.imemload;
  assign iditype = dpif.id.imemload;
  assign exjtype = dpif.ex.imemload;

  regbits_t WrDest;
  //register file connections
  assign rfif.rsel1 = idrtype.rs; //apply for both rtype and itype doesnt matter
  assign rfif.rsel2 = idrtype.rt;
  assign rfif.WEN = dpif.wb.RegWr & (dcif.ihit | dcif.dhit);
  assign WrDest = dpif.ex.RegDst== 2'd0 ?dpif.ex.rt:( dpif.ex.RegDst == 2'd1 ? dpif.ex.rd : 5'b11111);
  assign rfif.wsel = dpif.wb.WrDest;
  assign rfif.wdat = dpif.mem.jal ? dpif.wb.pc_p4 : (dpif.wb.MemtoReg==0 ? dpif.wb.ALUout :dpif.wb.dmemload);


  //alu connections
    //different imm
  word_t zeroext_imm,lui_imm, signext_imm, cur_imm;
  assign signext_imm = iditype.imm[15]? {16'hffff, iditype.imm} : {16'h0000, iditype.imm};
  assign zeroext_imm = {16'h0000, iditype.imm};
  assign lui_imm = {iditype.imm, 16'h0000};
  //extop does not need to go throught reg
  assign cur_imm = cuif.zeroext ? zeroext_imm : (cuif.lui ? lui_imm : cuif.signext ? signext_imm : 32'h0);

  assign aluif.aluop = dpif.ex.ALUOp;
  assign aluif.portA = dpif.ex.rdat1;
  assign aluif.portB = dpif.ex.ALUSrc ? dpif.ex.cur_imm : dpif.ex.rdat2;


  word_t branchAddr, jumpAddr;
  assign jumpAddr = {dpif.ex.npc[31:28], exjtype.addr,2'b00};
  assign branchAddr = dpif.ex.npc + {dpif.ex.cur_imm[29:0],2'b0};
  //branch jump
  always_comb begin
    npc = pc_p4;
    ///////////////////////////jump///////////////////////////////
    if (dpif.mem.jump) begin
      npc = dpif.mem.jumpAddr;
    end
    else if (dpif.mem.jal) begin
      npc = dpif.mem.jumpAddr;
    end
    else if (dpif.mem.jreg) begin
      npc = dpif.mem.rdat1;
    end
    ///////////////////////////branch///////////////////////////////////
    if (dpif.mem.beq && dpif.mem.zero) begin
      npc = dpif.mem.branchAddr;
    end
    else if (dpif.mem.bne && !dpif.mem.zero) begin
      npc = dpif.mem.branchAddr;
    end

  end

  //halt register
  logic nhalt,halt;
  assign nhalt = dpif.wb.Halt;
  
  always_ff@ (posedge CLK, negedge nRST) begin
    if(!nRST) halt <= 0;
    else halt <= nhalt;
  end
  //pc register

  always_ff@ (posedge CLK, negedge nRST) begin
    if(!nRST)  pc<= 32'b0;
    else if(dcif.ihit&!dcif.dhit) pc <= npc;
  end

  //datapath output
  assign dcif.halt = halt;
  assign dcif.imemREN = 1;
  assign dcif.dmemREN = dpif.mem.MemtoReg; 
  assign dcif.dmemWEN = dpif.mem.MemWr; 
  assign dcif.dmemstore = dpif.mem.rdat2;
  assign dcif.dmemaddr = dpif.mem.outport;
  assign dcif.imemaddr = pc;

/////////////////////////////// Pipeline /////////////////////////////////////////

  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      dpif.id <= '0; //'{default:'0}
      dpif.ex <= '0;
      dpif.mem <= '0;
      dpif.wb <= '0;
    end
    else if(dcif.ihit & !dcif.dhit)begin //stall when instr not ready
/////////////////////   IFID STAGE    ///////////////////////////
      //instruction
      dpif.id.imemload <= dcif.imemload;
      //pc
      dpif.id.npc      <= npc;

/////////////////////   IDEX STAGE    ///////////////////////////
      //instruction
      dpif.ex.imemload <= dpif.id.imemload;
      //pc
      dpif.ex.npc <= dpif.id.npc;      
      //Control unit signals
      dpif.ex.RegDst   <= cuif.RegDst;
      dpif.ex.ALUSrc   <= cuif.ALUSrc;
      dpif.ex.ALUop    <= cuif.ALUop;
      dpif.ex.MemWr    <= cuif.MemWr;
      dpif.ex.beq      <= cuif.beq;
      dpif.ex.bne      <= cuif.bne;
      dpif.ex.jump     <= cuif.jump;
      dpif.ex.jreg     <= cuif.jreg;
      dpif.ex.jal      <= cuif.jal;
      dpif.ex.RegWr    <= cuif.RegWr;
      dpif.ex.MemtoReg <= cuif.MemtoReg;
      dpif.ex.Halt     <= cuif.Halt;
      //register file output
      dpif.ex.rdat1      <= rfif.rdat1;
      dpif.ex.rdat2      <= rfif.rdat2;
      //extended immediate 
      dpif.ex.cur_imm    <= cur_imm;
      //rt rd for WrDest
      dpif.ex.rt       <= iditype.rt;
      dpif.ex.rd       <= idrtype.rd;

/////////////////////   EXMEM STAGE    ///////////////////////////
      //Control unit signals
      dpif.mem.MemWr    <= dpif.ex.MemWr;
      dpif.mem.beq      <= dpif.ex.beq;
      dpif.mem.bne      <= dpif.ex.bne;
      dpif.mem.jump     <= dpif.ex.jump;
      dpif.mem.jreg     <= dpif.ex.jreg;
      dpif.mem.jal      <= dpif.ex.jal;
      dpif.mem.RegWr    <= dpif.ex.RegWr;
      dpif.mem.MemtoReg <= dpif.ex.MemtoReg;
      dpif.mem.Halt     <= dpif.ex.Halt;
      //alu
      dpif.mem.rdat2    <= rfif.rdat2;
      dpif.mem.ALUout   <= aluif.outport;
      dpif.mem.zero     <= aluif.zero;
      dpif.mem.branchAddr <= branchAddr;
      dpif.mem.jumpAddr <= jumpAddr;
      dpif.mem.rdat1    <= rfif.rdat1;
      //write back register
      dpif.mem.WrDest   <= WrDest;
    end 
    else if (dcif.dhit) begin
/////////////////////     MEMWB STAGE    ///////////////////////////
      //Control unit signals
      dpif.wb.RegWr    <= dpif.mem.RegWr;
      dpif.wb.MemtoReg <= dpif.mem.MemtoReg;
      dpif.wb.Halt     <= dpif.mem.Halt;

      //wdat
      dpif.wb.ALUout   <= dpif.mem.ALUout;
      dpif.wb.dmemload <= dcif.dmemload;
      //wsel
      dpif.wb.WrDest   <= dpif.mem.WrDest;

    end
  end

endmodule
