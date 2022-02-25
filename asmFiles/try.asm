org 0x0000
ori $3,$0,0x4
ori $1,$0,0x22
ori $8,$0,-1
slti $1,$3,1
sw $1, 0($3)
sltiu $1,$3,-1
sw $1, 4($3)
slt $1,$3,$1
sw $1, 8($3)
sltu $1,$3,$8
sw $1, 12($3)

halt
