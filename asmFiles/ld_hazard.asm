org 0x0000

main: 
ori $3, $0, 0xF0
ori $4, $0, 0x7000
nop
lw  $5, 0($3)
nop
sub $6, $5, $4
nop
sw  $6, 0($3)

halt

org   0x00F0
cfw   0x7337
cfw   0x2701
cfw   0x1337
