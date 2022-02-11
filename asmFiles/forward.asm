org 0x0000

main: 
ori $4, $0, 4
ori $5, $0, 5
ori $6, $0, 0x80
add $7, $4, $5
nop
nop
add $8, $4, $7
add $9, $5, $7
sw $8, 0($6)
lw $9, 0($6)
#sw $9, 4($6)

halt
