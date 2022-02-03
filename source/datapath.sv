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
  datapath_cache_if.dp dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc init
  parameter PC_INIT = 0;

  control_unit_if cuif();
  request_unit_if ruif();
  register_file_if rfif();
  alu_if aluif();
  
  //DUT
  control_unit CU (cuif);
  request_unit RU (CLK, nRST, ruif);
  register_file RF (CLK, nRST, rfif);
  alu ALU (aluif);

  word_t pc, npc, pc_p4;
  assign pc_p4 = pc+4;
  j_t jtype;
  i_t itype;
  r_t rtype;

  //initialize instructions stuff
  assign cuif.instruction = dpif.imemload;
  assign itype = dpif.imemload;
  assign rtype = dpif.imemload;
  assign jtype = dpif.imemload;
  //pcenable
  logic pcen;
  assign pcen = dpif.ihit && (~dpif.ihit);

  //request unit connections
  assign ruif.dhit = dpif.dhit;
  assign ruif.ihit = dpif.ihit;
  assign ruif.MemtoReg = cuif.MemtoReg;
  assign ruif.MemWr = cuif.MemWr;

  //register file connections
  assign rfif.rsel1 = rtype.rs; //apply for both rtype and itype doesnt matter
  assign rfif.rsel2 = rtype.rt;
  assign rfif.WEN = cuif.RegWr;
  assign rfif.wsel = cuif.RegDst == 2'd0 ?itype.rt:(cuif.RegDst == 2'd1 ? rtype.rd : 5'b11111);
  assign rfif.wdat = cuif.jal ? pc_p4 : (cuif.RegWr ? aluif.outport : dpif.dmemload);

  //alu connections
    //different imm
  word_t zeroext_imm,lui_imm, signext_imm, cur_imm;
  assign signext_imm = itype.imm[15]? {16'hffff, itype.imm} : {16'h0000, itype.imm};
  assign zeroext_imm = {16'h0000, itype.imm};
  assign lui_imm = {itype.imm, 16'h0000};
  assign cur_imm = cuif.zeroext ? zeroext_imm : (cuif.lui ? lui_imm : cuif.signext ? signext_imm : 32'h0);
 
  assign aluif.aluop = cuif.ALUOp;
  assign aluif.portA = rfif.rdat1;
  assign aluif.portB = cuif.ALUSrc ? cur_imm : rfif.rdat2;

  //branch jump
  always_comb begin
    npc = pc_p4;
    ///////////////////////////jump///////////////////////////////
    if (cuif.jump) begin
      npc = {pc_p4[31:28], jtype.addr,2'b00};
    end
    else if (cuif.jal) begin
      npc = {pc_p4[31:28], jtype.addr,2'b00};
    end
    else if (cuif.jreg) begin
      npc = rfif.rdat1;
    end
    ///////////////////////////branch///////////////////////////////////
    if (cuif.beq) begin
      if (aluif.zero) npc = pc_p4 + {cur_imm[29:0],2'b0};
      else npc = pc_p4;
    end
    else if (cuif.bne && !aluif.zero) begin
      if (aluif.zero) npc = pc_p4;
      else npc = pc_p4 + {cur_imm[29:0],2'b0};
    end

  end

  //halt register
  logic nhalt,halt;
  assign nhalt = cuif.Halt;
  
  always_ff@ (posedge CLK, negedge nRST) begin
    if(!nRST) halt <= 0;
    else halt <= nhalt;
  end
  //pc register

  always_ff@ (posedge CLK, negedge nRST) begin
    if(!nRST)  pc<= 32'b0;
    else if(dpif.ihit&!dpif.dhit) pc <= npc;
  end

  //datapath output
  assign dpif.halt = halt;
  assign dpif.imemREN = 1;
  assign dpif.dmemREN = ruif.dmemREN;
  assign dpif.dmemWEN = ruif.dmemWEN;
  assign dpif.dmemstore = rfif.rdat2;
  assign dpif.dmemaddr = aluif.outport;
  assign dpif.imemaddr = pc;

  
endmodule
