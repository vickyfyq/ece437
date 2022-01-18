org 0x0000
main:
#sp at $29, multiply several integers together
ori $29, $0, 0xfffc
ori $4, $0, 4
ori $5, $0, 5
ori $6, $0, 6
ori $7, $0, 7
#push several integers
addi $29, $29, -16
sw $4, 12($29)
sw $5, 8($29)
sw $6, 4($29)
sw $7, 0($29)
#if only two left on stack (last int and result) exit the program
mult_procedure:
ori $8, $0, 0xfff8
beq $29, $8, exit

mult:
#load first two on top of stack
lw $7, 0($29)
lw $6, 4($29)
addi $29, $29, 8
#initialize result reg
ori $9, $0, 0

loop:
// save reg if mult done
beq $7, $0, save
add $9, $9, $6
addi $7, $7, -1
j loop

save:si
addi $29, $29, -4
sw $9, 0($29)
j mult_procedure

exit:
halt
