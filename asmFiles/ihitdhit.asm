org 0x0000
ori $4,$0, 0x4
ori $2, $0, 4
ori $3, $0, 1
loop:
sub $2, $2, $3
sw $2, 0($4)
bne $2, $0, loop


loop_out:
halt
