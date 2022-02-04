`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

// typedefs
`include "cpu_types_pkg.vh"

interface control_unit_if;
    import cpu_types_pkg::*;


    word_t instruction;
  //  logic lw,sw; //
    logic RegWr; 
    logic[1:0] RegDst; //RegDst: 0->rt, 1->rd, 2->r31
    logic zeroext, signext, lui; //ExtOp: zeroext, signext, lui 
    logic ALUSrc; //ALUSrc: 0->regB, 1->imm
    aluop_t ALUOp; 
    logic MemWr;
    logic MemtoReg;//MemtoReg:0->aluout 1->dmemload
    logic beq, bne; // branch && zero flag : 
                  //0<pc+4, 1<- pc+4+ signext(imm16)<< 2
                  //1<- beq, 2<-bne
    logic jump, jreg , jal; //jump :  1<- {pc+4[31:28], addr,00 },2<-R[rs]
    logic Halt;


endinterface

`endif 