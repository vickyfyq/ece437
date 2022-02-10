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
  j_t jtype;
  i_t itype;
  r_t rtype;

  //initialize instructions stuff
  assign cuif.instruction = dcif.imemload;
  assign itype = dcif.imemload;
  assign rtype = dcif.imemload;
  assign jtype = dcif.imemload;
  //pcenable
  logic pcen;
  assign pcen = dcif.ihit && (~dcif.ihit);

  //request unit connections
  assign ruif.dhit = dcif.dhit;
  assign ruif.ihit = dcif.ihit;
  assign ruif.MemtoReg = cuif.MemtoReg;
  assign ruif.MemWr = cuif.MemWr;

  //register file connections
  assign rfif.rsel1 = rtype.rs; //apply for both rtype and itype doesnt matter
  assign rfif.rsel2 = rtype.rt;
  assign rfif.WEN = cuif.RegWr & (dcif.ihit | dcif.dhit);
  assign rfif.wsel = cuif.RegDst == 2'd0 ?itype.rt:(cuif.RegDst == 2'd1 ? rtype.rd : 5'b11111);
  assign rfif.wdat = cuif.jal ? pc_p4 : (cuif.MemtoReg==0 ? aluif.outport : dcif.dmemload);

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
    else if(dcif.ihit&!dcif.dhit) pc <= npc;
  end

  //datapath output
  assign dcif.halt = halt;
  assign dcif.imemREN = 1;
  assign dcif.dmemREN = ruif.dmemREN;
  assign dcif.dmemWEN = ruif.dmemWEN;
  assign dcif.dmemstore = rfif.rdat2;
  assign dcif.dmemaddr = aluif.outport;
  assign dcif.imemaddr = pc;

/////////////////////////////// Pipeline /////////////////////////////////////////
  //Decode Latch Logic
  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      dpif.id = '0; //'{default:'0}
    end
    else begin 
      dpif.id.imemload = dcif.imemload;
      dpif.id.pc_p4 = pc_p4;
    end
  end
  //Execute Latch Logic
  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      dpif.ex = '0;  //'{default:'0}
    end
    else begin 
      //Control unit signals
      dpif.ex.RegDst = cuif.RegDst;
      dpif.ex.ALUSrc = cuif.ALUSrc;
      dpif.ex.ALUop  = cuif.ALUop;
      dpif.ex.MemWr  = cuif.MemWr;
      dpif.ex.beq    = cuif.beq;
      dpif.ex.bne    = cuif.bne;
      dpif.ex.jump   = cuif.jump;
      dpif.ex.jreg   = cuif.jreg;
      dpif.ex.jal    = cuif.jal;
      dpif.ex.RegWr  = cuif.RegWr;
      dpif.ex.MemtoReg = cuif.MemtoReg;
      dpif.ex.Halt   = cuif.halt;
      // Others
      dpif.ex.rdat1  = rfif.rdat1;
      dpif.ex.rdat2  = rfif.rdat2;
      dpif.ex.cur_imm = cur_imm;
      dpif.ex.rt     = rtype.rt;
      dpif.ex.rd     = rtype.rd;
    end
  end
  // Memory Latch Logic
  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      dpif.mem = '0;  //'{default:'0}
    end
    else begin 
      //Control unit signals
      dpif.mem.MemWr  = dpif.ex.MemWr;
      dpif.mem.beq    = dpif.ex.beq;
      dpif.mem.bne    = dpif.ex.bne;
      dpif.mem.jump   = dpif.ex.jump;
      dpif.mem.jreg   = dpif.ex.jreg;
      dpif.mem.jal    = dpif.ex.jal;
      dpif.mem.RegWr  = dpif.ex.RegWr;
      dpif.mem.MemtoReg = dpif.ex.MemtoReg;
      dpif.mem.Halt   = dpif.ex.halt;

      // Others
      dpif.mem.ALUout = aluif.outport;
      dpif.mem.rdat2  = rfif.rdat2;
      dpif.mem.npc    = npc;
    end
  end
  // Write Back Latch Logic
  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      dpif.wb = '0;  //'{default:'0}
    end
    else begin 
      //Control unit signals
      dpif.wb.RegWr  = dpif.ex.RegWr;
      dpif.wb.MemtoReg = dpif.ex.MemtoReg;
      dpif.wb.Halt   = dpif.ex.halt;

      // Others
      dpif.wb.dmemload  = dcif.dmemload;
      dpif.wb.rdat2  = rfif.rdat2;
    end
  end
endmodule
