org 0x0000
main:
#Days = CurrentDay + (30 ∗ (CurrentMonth − 1)) + 365 ∗ (CurrentY ear − 2000)

#sp at $29
ori $29, $0, 0xfffc
ori $4, $0, 25 #current day 325
ori $5, $0, 11  #current month
ori $6, $0, 2029 #current year 2022
addi $12, $6, -2000 #current year - 2000
addi $5, $5, -1 #current month - 1
ori $7, $0, 30  #30
ori $13, $0, 365 #365

#push two integers
addi $29, $29, -8
sw $5, 4($29)
sw $7, 0($29)
jal mult
lw $9, 0($29)
addi $29, $29, 4
add $10, $0, $9

addi $29, $29, -8
sw $12, 4($29)
sw $13, 0($29)
jal mult
lw $9, 0($29)
addi $29, $29, 4
add $10, $10, $9
add $10, $10, $4
halt

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
jr $31
