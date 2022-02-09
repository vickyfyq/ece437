
`ifndef DATAPATH_CACHE_IF_VH
`define DATAPATH_CACHE_IF_VH

// types
`include "cpu_types_pkg.vh"

interface datapath_cache_if;
  // import types
  import cpu_types_pkg::*;

// datapath signals
// Fetch
word_t  if_pc4, if_imemload;
// Decode
    word_t id_imemload, id_pc4;
    logic id_RegWr; 
    logic[1:0] id_RegDst; //RegDst: 0->rt, 1->rd, 2->r31
    logic id_zeroext, id_signext, id_lui; //ExtOp: zeroext, signext, lui 
    logic id_ALUSrc; //ALUSrc: 0->regB, 1->imm
    aluop_t id_ALUOp; 
    logic id_MemWr, id_MemRead;
    logic id_MemtoReg;//MemtoReg:0->aluout 1->dmemload
    logic id_beq, id_bne; // branch && zero flag : 
                  //0<pc+4, 1<- pc+4+ signext(imm16)<< 2
                  //1<- beq, 2<-bne
    logic id_jump, id_jreg , id_jal; //jump :  1<- {pc+4[31:28], addr,00 },2<-R[rs]
    logic id_Halt;

// Execute
    word_t ex_pc4, ex_rdat1, ex_rdat2, ex_imemload, ex_cur_imm, ex_branchAddr, ex_ALUout, ex_jumpAddr;
    logic ex_RegWr; 
    logic[1:0] ex_RegDst; //RegDst: 0->rt, 1->rd, 2->r31
    logic ex_ALUSrc; //ALUSrc: 0->regB, 1->imm
    aluop_t ex_ALUOp; 
    logic ex_MemWr, ex_MemRead;
    logic ex_MemtoReg;//MemtoReg:0->aluout 1->dmemload
    logic ex_beq, ex_bne; // branch && zero flag : 
                  //0<pc+4, 1<- pc+4+ signext(imm16)<< 2
                  //1<- beq, 2<-bne
    logic ex_jump, ex_jreg , ex_jal; //jump :  1<- {pc+4[31:28], addr,00 },2<-R[rs]
    logic ex_Halt;
    logic ex_zero;
// MEM
    word_t mem_rdat2, mem_ALUout, mem_branchAddr, mem_jumpAddr, mem_rdat1, mem_dmemload;
    logic mem_zero;
    logic mem_RegWr; 
    logic mem_MemWr, mem_MemRead;
    logic mem_MemtoReg;//MemtoReg:0->aluout 1->dmemload
    logic mem_beq, mem_bne; // branch && zero flag : 
                  //0<pc+4, 1<- pc+4+ signmemt(imm16)<< 2
                  //1<- beq, 2<-bne
    logic mem_jump, mem_jreg , mem_jal; //jump :  1<- {pc+4[31:28], addr,00 },2<-R[rs]
    logic mem_Halt;
// Write back
    word_t wb_dmemload, wb_rdat2;
    logic wb_RegWr; 
    logic wb_memtoReg;//wbtoReg:0->aluout 1->dwbload
    logic wb_Halt;


endinterface

`endif //DATAPATH_CACHE_IF_VH
