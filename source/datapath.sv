/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"
`include "pipeline_reg_if.vh"
`include "control_unit_if.vh"
`include "forward_unit_if.vh"
`include "hazard_unit_if.vh"
`include "register_file_if.vh"
`include "alu_if.vh"
`include "forward_unit_if.vh"
`include "hazard_unit_if.vh"
// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dcif
);
  // import types
  import cpu_types_pkg::*;

  // pc init
  parameter PC_INIT = 0;
  pipeline_reg_if  prif();
  control_unit_if  cuif();
  hazard_unit_if   huif();
  forward_unit_if  fuif();
  register_file_if rfif();
  alu_if aluif();
  
  //DUT
  control_unit CU (cuif);
  register_file RF (CLK, nRST, rfif);
  alu ALU (aluif);
  pipeline_reg PR (CLK,nRST,dcif.ihit, dcif.dhit,  prif);
  hazard_unit  HU (huif);
  forward_unit FU (fuif);

  // pc initprif
  word_t pc, npc, pc_p4;
  assign pc_p4 = pc+4;
  i_t iditype;
  r_t idrtype, exrtype ,rtype;
  j_t exjtype;
  assign rtype = dcif.imemload; //for cpu tracker

  //initialize instructions stuff
  assign cuif.instruction = prif.id.imemload;
  assign idrtype = prif.id.imemload;
  assign iditype = prif.id.imemload;
  assign exjtype = prif.ex.imemload;
  assign exrtype = prif.ex.imemload;

  regbits_t WrDest;
  //register file connections
  assign rfif.rsel1 = idrtype.rs; //apply for both rtype and itype doesnt matter
  assign rfif.rsel2 = idrtype.rt;
  assign rfif.WEN = prif.wb.RegWr ;//& (dcif.ihit | dcif.dhit);
  assign WrDest = prif.ex.RegDst== 2'd0 ?prif.ex.rt:( prif.ex.RegDst == 2'd1 ? prif.ex.rd : 5'b11111);
  assign rfif.wsel = prif.wb.WrDest;
  assign rfif.wdat = prif.wb.jal ? prif.wb.npc : (prif.wb.MemtoReg==0 ? prif.wb.ALUout :prif.wb.dmemload);


  //alu connections
    //different imm
  word_t zeroext_imm,lui_imm, signext_imm, cur_imm;
  assign signext_imm = iditype.imm[15]? {16'hffff, iditype.imm} : {16'h0000, iditype.imm};
  assign zeroext_imm = {16'h0000, iditype.imm};
  assign lui_imm = {iditype.imm, 16'h0000};
  //extop does not need to go throught reg
  assign cur_imm = cuif.zeroext ? zeroext_imm : (cuif.lui ? lui_imm : cuif.signext ? signext_imm : 32'h0);

  word_t aluPortA, aluPortB;

  assign aluif.aluop = prif.ex.ALUOp;
  //assign aluif.portA = prif.ex.rdat1;
  //assign aluif.portB = prif.ex.ALUSrc ? prif.ex.cur_imm : prif.ex.rdat2;
  assign aluif.portA = aluPortA;
  assign aluif.portB = prif.ex.ALUSrc ? prif.ex.cur_imm : aluPortB;

  // Forwarding muxes
  always_comb begin
    casez (fuif.forwardA)
      //2'b11 : aluPortA = dcif.dmemload;
      2'b10 : aluPortA = prif.mem.ALUout;
      2'b01 : aluPortA = rfif.wdat; 
      default : aluPortA = prif.ex.rdat1;
    endcase
    casez (fuif.forwardB)
      //2'b11 : aluPortB = dcif.dmemload;
      2'b10 : aluPortB = prif.mem.ALUout;
      2'b01 : aluPortB = rfif.wdat; 
      default : aluPortB = prif.ex.rdat2;
    endcase
  end

  assign prif.in_aluPortB = aluPortB;

  word_t branchAddr, jumpAddr;
  assign jumpAddr = {prif.ex.npc[31:28], exjtype.addr,2'b00};
  assign branchAddr = prif.ex.npc + {prif.ex.cur_imm[29:0],2'b0};
  //branch jump
  always_comb begin
    npc = pc_p4;
    if(huif.stall) 
      npc = pc;
    ///////////////////////////jump///////////////////////////////
    if (prif.mem.jump) begin
      npc = prif.mem.jumpAddr;
    end
    else if (prif.mem.jal) begin
      npc = prif.mem.jumpAddr;
    end
    else if (prif.mem.jreg) begin
      npc = prif.mem.rdat1;
    end
    ///////////////////////////branch///////////////////////////////////
    if (prif.mem.beq && prif.mem.zero) begin
      npc = prif.mem.branchAddr;
    end
    else if (prif.mem.bne && !prif.mem.zero) begin
      npc = prif.mem.branchAddr;
    end

  end

  //Hazard Unit
  assign huif.mem.jal = prif.mem.jal;
  assign huif.mem.jreg = prif.mem.jreg;
  assign huif.mem.jump = prif.mem.jump;
  assign huif.mem.bne = prif.mem.bne;
  assign huif.mem.beq = prif.mem.beq;
  assign huif.mem.zero = prif.mem.zero;
  assign huif.id.rs = idrtype.rs;
  assign huif.id.rt = idrtype.rt;
  assign huif.ex.rt = exrtype.rt;
  assign huif.ex.MemtoReg = prif.ex.MemtoReg;
  assign prif.flush = huif.flush;
  assign prif.stall = huif.stall;

  //Forward Unit
  assign fuif.ex_rs = prif.ex.imemload[25:21];
  assign fuif.ex_rt = prif.ex.imemload[20:16];
  assign fuif.mem_WrDest = prif.mem.WrDest;
  assign fuif.mem_RegWr = prif.mem.RegWr;
  assign fuif.mem_MemtoReg = prif.mem.MemtoReg;
  assign fuif.wb_WrDest = prif.wb.WrDest;
  assign fuif.wb_RegWr = prif.wb.RegWr;
  assign fuif.dhit = dcif.dhit;
  assign prif.forwardA = fuif.forwardA;
  assign prif.forwardB = fuif.forwardB;

  //halt register
  logic nhalt,halt;
  assign nhalt = prif.mem.Halt;
  
  always_ff@ (posedge CLK, negedge nRST) begin
    if(!nRST) halt <= 0;
    else halt <= nhalt | halt;
  end

  //pc register
  always_ff@ (posedge CLK, negedge nRST) begin
    if(!nRST)  pc<= PC_INIT;
    else if(dcif.ihit&!dcif.dhit) pc <= npc;
  end

  //datapath output
  assign dcif.halt = halt;
  assign dcif.imemREN = ~dcif.dmemREN && ~dcif.dmemWEN;
  assign dcif.dmemREN = prif.mem.MemtoReg; 
  assign dcif.dmemWEN = prif.mem.MemWr; 
  assign dcif.dmemstore = prif.mem.rdat2;
  assign dcif.dmemaddr = prif.mem.ALUout;
  assign dcif.imemaddr = pc;

  
///////////////  input for pipeline ///////////////////
    assign   prif.in_imemload = dcif.imemload;
    assign prif.in_lui_imm = lui_imm;
    assign prif.in_pc = pc;
  //pc
    assign   prif.in_npc      = npc;
  
  //Control unit signals
    assign   prif.in_RegDst   = cuif.RegDst;
    assign   prif.in_ALUSrc   = cuif.ALUSrc;
    assign   prif.in_ALUop    = cuif.ALUOp;
    assign   prif.in_MemWr    = cuif.MemWr;
    assign   prif.in_beq      = cuif.beq;
    assign   prif.in_bne      = cuif.bne;
    assign   prif.in_jump     = cuif.jump;
    assign   prif.in_jreg     = cuif.jreg;
    assign   prif.in_jal      = cuif.jal;
    assign   prif.in_RegWr    = cuif.RegWr;
    assign   prif.in_MemtoReg = cuif.MemtoReg;
    assign   prif.in_Halt     = cuif.Halt;
  //register file output
    assign   prif.in_rdat1      = rfif.rdat1;
    assign   prif.in_rdat2      = rfif.rdat2;
  //extended immediate 
    assign   prif.in_cur_imm    = cur_imm;
  //rt rd for WrDest
    assign   prif.in_rt       = iditype.rt;
    assign   prif.in_rd       = idrtype.rd;
  //alu
    assign   prif.in_ALUout   = aluif.outport;
    assign   prif.in_zero     = aluif.zero;
    assign   prif.in_branchAddr = branchAddr;
    assign   prif.in_jumpAddr = jumpAddr;
    assign   prif.in_dmemload = dcif.dmemload;
  //write back register
    assign prif.in_WrDest = WrDest;

    assign dcif.datomic = (prif.mem.imemload[31:26] == LL || prif.mem.imemload[31:26] == SC);

endmodule
