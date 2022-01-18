org 0x0000
main:
#sp at $29, 4*5
ori $29, $0, 0xfffc
ori $4, $0, 4
ori $5, $0, 5
#push two integers
addi $29, $29, -8
sw $4, 4($29)
sw $5, 0($29)

mult:
#pop two int
lw $7, 0($29)
lw $6, 4($29)
addi $29, $29, 8
#initialize result
ori $8, $0, 0
loop:
beq $7, $0, exit
add $8, $8, $6
addi $7, $7, -1
j loop
exit: 
addi $29, $29, -4
sw $8, 0($29)
halt
