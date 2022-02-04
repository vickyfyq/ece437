org 0x0000

main: 
ori $4, $0, 4
ori $5, $0, 5
ori $6, $0, 4
j jump_to_here #sw
sw $4, 0($6)

jump_to_here:
sw $5, 0($6)


halt
