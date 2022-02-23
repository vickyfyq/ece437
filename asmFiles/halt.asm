org 0x0000

ori $3, $0, 0xbad1bad1
ori $4, $0, 0x2b00b1e5
ori $5, $0, 3
ori $6, $0, 4
sw $4, 0($6)
halt
sw $3, 0($6)
