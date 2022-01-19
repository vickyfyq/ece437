org 0x0000
main:
#sp at $29, 4*5
ori $29, $0, 0xfffc
ori $4, $0, 30
ori $5, $0, 1
#push two integers
addi $29, $29, -8
sw $4, 4($29)
sw $5, 0($29)

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
exit: 
addi $29, $29, -4
sw $8, 0($29)
halt
