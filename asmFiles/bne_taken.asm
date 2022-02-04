org 0x0000

ori $4, $0, 3
ori $5, $0, 5
ori $6, $0, 4

main:
bne $4, $5, taken
sw $4, 0($6)
taken:
sw $5, 4($6)
halt
