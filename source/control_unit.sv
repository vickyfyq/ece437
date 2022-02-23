`include "control_unit_if.vh"
`include "cpu_types_pkg.vh"

module control_unit(
control_unit_if cuif
);
import cpu_types_pkg::*;

opcode_t opcode;
funct_t funct;

always_comb begin
opcode =opcode_t'(cuif.instruction[31:26]);
funct = funct_t'(cuif.instruction[5:0]);
//initialization
// cuif.lw = 0;
// cuif.sw = 0;
cuif.RegWr = 0; //write to register file 
cuif.RegDst = 2'd0; // RegDst: 0->rt, 1->rd, 2->r31
cuif.zeroext = 0;
cuif.signext = 0;
cuif.lui = 0;
cuif.ALUSrc = 0;//ALUSrc: 0->regB, 1->imm
cuif.MemWr = 0; //write to memory ///////SW
cuif.MemtoReg = 0;//MemtoReg:0->aluout 1->dmemload/////lw
cuif.beq = 0; 
cuif.bne = 0;
cuif.jump = 0;
cuif.jreg = 0;
cuif.jal = 0;
cuif.Halt = 0;
cuif.ALUOp = ALU_SLL;


if(opcode == RTYPE) begin
    casez(funct)
    SLLV  :begin
        cuif.ALUOp = ALU_SLL;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;
   
   
    end
    SRLV  :begin
        cuif.ALUOp = ALU_SRL;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;
    
   
    end
    JR    :begin
        cuif.jreg = 1; // jr R[rs]
    end
    ADD   :begin
        cuif.ALUOp = ALU_ADD;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;
   
    
    end
    ADDU  :begin 
        cuif.ALUOp = ALU_ADD;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;
   
    end
    SUB   :begin
        cuif.ALUOp = ALU_SUB;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;

    end
    SUBU  :begin
        cuif.ALUOp = ALU_SUB;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;
  
    end
    AND   :begin
        cuif.ALUOp = ALU_AND;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;
 
    end
    OR    :begin
        cuif.ALUOp = ALU_OR;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;
 
    end
    XOR   :begin
        cuif.ALUOp = ALU_XOR;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;

    end
    NOR   :begin
        cuif.ALUOp = ALU_NOR;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;

    end
    SLT   :begin
        cuif.ALUOp = ALU_SLT;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;
 
    end
    SLTU  :begin
        cuif.ALUOp = ALU_SLTU;
        cuif.RegWr = 1; //write data
        cuif.RegDst = 2'd1;
        cuif.ALUSrc = 0;//regB;

    end
    endcase
end
else begin
    casez(opcode)
    // jtype
    J  : begin 
        cuif.jump = 1; // {pc+4[31:28], addr,00 }
    end
    JAL: begin 
        cuif.jal = 1; 
        // JAL 31 = pc+4,,,
        //{pc+4[31:28], addr,00 }
        cuif.RegWr = 1;
        cuif.RegDst = 2'd2;//r31
        
    end

    // itype
    BEQ   :begin
        cuif.ALUOp = ALU_SUB;
        cuif.beq = 1; //taken when zero = 1
        cuif.signext = 1;
    end
    BNE   :begin
        cuif.ALUOp = ALU_SUB;
        cuif.bne = 1; //taken when zero = 0
        cuif.signext = 1;
    end
    ADDI  :begin
        cuif.ALUOp = ALU_ADD ;
        cuif.ALUSrc = 1; 
        cuif.signext = 1;
        cuif.RegWr = 1;
    end
    ADDIU :begin
        cuif.ALUOp = ALU_ADD ;
        cuif.ALUSrc = 1; 
        cuif.signext = 1;
        cuif.RegWr = 1;
    end
    SLTI  :begin
        cuif.ALUOp = ALU_SLT ;
        cuif.ALUSrc = 1; 
        cuif.signext = 1;
        cuif.RegWr = 1;
    end
    SLTIU :begin
        cuif.ALUOp = ALU_SLTU ;
        cuif.ALUSrc = 1; 
        cuif.signext = 1;
        cuif.RegWr = 1;
    end
    ANDI  :begin
        cuif.ALUOp = ALU_AND ;
        cuif.ALUSrc = 1; 
        cuif.zeroext = 1;
        cuif.RegWr = 1;
    end
    ORI   :begin
        cuif.ALUOp = ALU_OR ;
        cuif.ALUSrc = 1; 
        cuif.zeroext = 1;
        cuif.RegWr = 1;
    end
    XORI  :begin
        cuif.ALUOp = ALU_XOR;
        cuif.ALUSrc = 1; 
        cuif.zeroext = 1;
        cuif.RegWr = 1;
    end
    LUI   :begin
        cuif.ALUSrc = 1; 
        cuif.lui = 1;
        cuif.RegWr = 1;
    end
    LW    :begin
        cuif.ALUOp = ALU_ADD;
        cuif.signext = 1;
        cuif.MemtoReg = 1;
        cuif.ALUSrc = 1;
        cuif.RegWr = 1;
        
       // cuif.lw = 1;
    end
    SW    :begin
        cuif.ALUOp = ALU_ADD;
        cuif.signext = 1;
        cuif.ALUSrc = 1;
       // cuif.sw = 1;
        cuif.MemWr = 1;
    end
    HALT  :begin
        cuif.Halt = 1;
    end

    endcase
    
end

end

endmodule