org 0x0000

ori $4, $0, 3
ori $5, $0, 3
ori $6, $0, 4

main:
beq $4, $5, equal_taken

equal_taken:
sw $4, 0($6)
bne $5, $6, not_equal_taken

blah3:
ori $6, $0, 1000

not_equal_taken:
sw $4, 4($6)
beq $5, $6, equal_not_taken

blah:
ori $6, $0, 1000

equal_not_taken:
sw $4, 8($6)
bne $4, $5, not_equal_not_taken

blah2:
ori $6, $0, 1000

not_equal_not_taken:
sw $4, 12($6)
ori $8, $0, 12


halt
