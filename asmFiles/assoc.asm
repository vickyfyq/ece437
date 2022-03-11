org 0x0000

ori $1,$0,0x123cc
ori $2,$0,0x321cc
ori $7, $0, 0x456cc
ori $3,$0,0xfffc
ori $4,$0, 0xcccf
sw  $3, 0($2)
sw  $4, 0($1)
sw  $3, 0($7)
lw  $5, 0($1)
lw  $6, 0($2)
lw  $8, 0($7)


halt
