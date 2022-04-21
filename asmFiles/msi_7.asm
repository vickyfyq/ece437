# core 1
org 0x0000

ori $t0, $0, 0x400
ori $t2, $0, 0xdead

lw $t1, 0($t0) # I -> M snoop read
nop
nop
nop
nop
lw $t1, 0($t0) # I -> M snoop read
sw $t1, 0($t0) # I -> M local write
nop
halt



# core 2
org 0x0200

ori $t0, $0, 0x400
ori $t1, $0, 0xb00b
nop
nop
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

org 0x0400
data1:
  cfw 0x01234567
data2:
  cfw 0x89abcdef
data3:
  cfw 0x08192a3b
data4:
  cfw 0x4c5d6e7f
