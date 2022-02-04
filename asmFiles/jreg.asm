org 0x0000

main: 
ori $4, $0, 4
ori $5, $0, 5
ori $6, $0, 4
ori $7, $0, 34
jal jump_to_here #sw
sw $4, 4($6)
halt

jump_to_here:
sw $5, 0($6)
jr $31
sw $7, 8($6)
