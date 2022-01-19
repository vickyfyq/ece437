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
ori $28, $0, 0xfff8
beq $29, $28, exit

mult:
#pop two int
lw $7, 0($29)  #X, B
lw $6, 4($29)  #Y, Q
addi $29, $29, 8
#initialize result
ori $8, $0, 0 #initialize A reg
ori $9, $0, 32 #initialize N
loop:
ori $11, $0, 1
andi $12, $6, 0x1
bne $12, $11, shift
#A<-A+B
add $8,$8, $7
shift:
sllv $7, $11, $7
srlv $6, $11, $6
addi $9, $9, -1
bne $9, $0, loop
save: 
addi $29, $29, -4
sw $8, 0($29)
j mult_procedure

exit:
halt
