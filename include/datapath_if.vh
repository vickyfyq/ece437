
`ifndef DATAPATH_CACHE_IF_VH
`define DATAPATH_CACHE_IF_VH

// types
`include "cpu_types_pkg.vh"

interface datapath_cache_if;
  // import types
  import cpu_types_pkg::*;

  typedef struct packed {
    //Decode signals
    word_t imemload;
    
    //Execute signals
    word_t rdat1, rdat2, cur_imm, npc;
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
    //mux
    word_t ALUout;
    word_t dmemload;
    //control
    logic MemtoReg;
    logic RegWr; 
    logic Halt;
    //wsel
    regbits_t WrDest;

  } pipe_control_memwb;
  
  typedef struct packed {  
    word_t rdat1, rdat2;
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
    word_t imemload;
    
    //Execute signals
    word_t rdat1, rdat2, cur_imm, npc;
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
    word_t imemload, npc;
  } pipe_control_idex;

pipe_control_memwb wb;
pipe_control_exmem mem;
pipe_control_idex ex;
pipe_control_ifid id;


endinterface

`endif //DATAPATH_CACHE_IF_VH
