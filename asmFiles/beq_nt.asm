org 0x0000

ori $4, $0, 5
ori $5, $0, 6
ori $6, $0, 4

main:
beq $4, $5, taken
sw $4, 0($6)
taken:
sw $6, 4($6)
halt
