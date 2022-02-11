
`ifndef PIPELINE_REG_IF_VH
`define PIPELINE_REG_IF_VH

// types
`include "cpu_types_pkg.vh"

interface pipeline_reg_if;
  // import types
  import cpu_types_pkg::*;

  typedef struct packed {
    //Decode signals
    word_t imemload;
    
    //Execute signals
    word_t rdat1, rdat2, cur_imm;
    logic [1:0] RegDst; //RegDst: 0->rt, 1->rd, 2->r31
    logic ALUSrc; //ALUSrc: 0->regB, 1->imm
    aluop_t ALUOp; 
    regbits_t rt, rd;
    
    //Memory signals
    word_t branchAddr,jumpAddr, ALUout, npc;
    logic MemWr ;
    logic beq, bne; // branch && zero flag : 
                  //0<pc+4, 1<- pc+4+ signext(imm16)<< 2
                  //1<- beq, 2<-bne
    logic jump, jreg , jal; //jump :  1<- {pc+4[31:28], addr,00 },2<-R[rs]
    logic zero;

    //Write back signals
    word_t dmemload;
    logic MemtoReg;//MemtoReg:0->aluout 1->dmemload
    logic RegWr; 
    logic Halt;
    regbits_t WrDest; // wsel
  } pipe_control;

  typedef struct packed {
    r_t imemload, pc;
    //mux
    word_t ALUout,npc,cur_imm, lui_imm,branchAddr;
    word_t dmemload, rdat2;
    //control
    logic MemtoReg;
    logic RegWr; 
    logic Halt,  jal;
    //wsel
    regbits_t WrDest;


  } pipe_control_memwb;
  
  typedef struct packed {  
    word_t imemload, pc;
    word_t rdat1, rdat2,npc,cur_imm, lui_imm;
    logic zero;
    word_t branchAddr, jumpAddr, ALUout;
    //WSEL
    regbits_t WrDest;
    
    //control
    logic MemWr ;
    logic beq, bne; 
    logic jump, jreg , jal; 
    logic MemtoReg;
    logic RegWr; 
    logic Halt;
    
  } pipe_control_exmem;

  typedef struct packed {
    //Decode signals
    word_t imemload, pc;
    
    //Execute signals
    word_t rdat1, rdat2, cur_imm, lui_imm;
    logic [1:0] RegDst; 
    logic ALUSrc; 
    aluop_t ALUOp; 
    regbits_t rt, rd;
    
    //Memory signals
    word_t branchAddr,jumpAddr, ALUout, npc;
    logic MemWr ;
    logic beq, bne; 
    logic jump, jreg , jal; 
    logic zero;

    //Write back signals
    word_t dmemload;
    logic MemtoReg;
    logic RegWr; 
    logic Halt;
  } pipe_control_idex;
  
  typedef struct packed {
    //Decode signals
    word_t imemload, npc, pc;
  } pipe_control_ifid;

pipe_control_memwb wb;
pipe_control_exmem mem;
pipe_control_idex ex;
pipe_control_ifid id;

logic wb_enable;
word_t in_imemload, in_npc, in_pc;
logic[1:0] in_RegDst;
logic in_ALUSrc;
aluop_t in_ALUop;
logic in_MemWr;
logic in_beq;
logic in_bne;
logic in_jump;
logic in_jreg;
logic in_jal;
logic in_RegWr;
logic in_MemtoReg;
logic in_Halt;
word_t in_rdat1, in_rdat2, in_lui_imm,in_cur_imm,in_jumpAddr,in_branchAddr;
regbits_t in_rt, in_rd;
word_t in_ALUout;
logic in_zero;
regbits_t in_WrDest;
word_t in_dmemload;

endinterface

`endif //DATAPATH_CACHE_IF_VH
