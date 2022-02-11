org 0x0000

main: 
ori $3, $0, 0x3C
ori $4, $0, 0x7000
nop
nop
beq $4, $4, branch
ori $5, $0, 0xBAD
nop
sw  $5, 0($3)
j   end
branch:
ori $5, $0, 0x123
nop
sw  $5, 0($3)

end:

halt

org   0x00F0
cfw   0x7337
cfw   0x2701
cfw   0x1337
