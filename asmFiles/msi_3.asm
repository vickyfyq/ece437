# core 1
org 0x0000

ori $t0, $0, 0x400
ori $t1, $0, 0xdead
nop
lw $t1, 0($t0) # I -> S snoop read
sw $t2, 0($t0) # S -> M local write
nop # M -> I by snoop write

halt



# core 2
org 0x0200

ori $t0, $0, 0x400
ori $t1, $0, 0xee
sw $t1, 0($t0) # I -> M local write
lw $t2, 0($t0) # M -> S snoop read
nop
sw $t2, 0($t0) # S -> M local write
halt
