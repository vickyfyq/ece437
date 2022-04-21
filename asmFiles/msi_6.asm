# core 1
org 0x0000

ori $t0, $0, 0x400
ori $t2, $0, 0xdead
nop
nop
nop
lw $t1, 0($t0) # I -> M snoop read
nop # M -> I by snoop write
nop
nop
nop
nop
sw $t2, 0($t0) # I -> M snoop read
nop
nop
nop
nop
nop
halt



# core 2
org 0x0200

ori $t0, $0, 0x400
ori $t1, $0, 0xb00b
sw $t1, 0($t0) # I -> M local write
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
halt
