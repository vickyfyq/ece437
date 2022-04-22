#----------------------------------------------------------
# First Processor (Producer)
#----------------------------------------------------------
    org   0x0000              # first processor p0
    ori   $sp, $zero, 0x3ffc  # stack
    jal   mainp0              # go to program
    halt
# MAX: FD72, MIN: 4E, AVG: 825E
mainp0:
    push  $ra                 # save return address
    ori $t5, $zero, 0         # initialize counter 
    ori $t6, $zero, 256         # initialize max iter of rand 
    ori $t7, $zero, 0x666         # set seed 6

rand_init:
    or $a0, $zero, $t7        # set seed to be arg(first iter), second iter put rand generated
    jal crc32                 # call rand generator given 
    or $t8, $zero, $v0        # save the returned rand in t8
    ori   $a0, $zero, l1      # move lock to arguement register
    jal   lock                # try to aquire the lock
    or    $a0, $zero, $t8     # move rand to arguement register
    jal   mypush              # push the rand
    ori   $a0, $zero, l1      # move lock to arguement register
    jal   unlock              # release the lock

    addi $t5, $t5, 1          # increment the counter
    or   $t7, $zero, $t8      # set new seed
    bne  $t5, $t6, rand_init   # go back if not 256 rand yet

    pop   $ra                 # get return address
    jr    $ra                 # return to caller
mypush:
    ori $t0, $zero, stackptr
    ori $t1, $zero,  baseptr
    lw $t2, 0($t0)                      # load offset
    lw $t3, 0($t1)                      # load base
    sub $t3, $t3, $t2                   # calculate the place to store
    sw   $a0, 0($t3)                    # store to stack
    addi $t2, $t2, 4                    # increment the offset, decrement the stack pointer
    sw   $t2, 0($t0)                    # update offset
    jr   $ra                           


l1:
cfw 0x0

#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
org   0x200               # second processor p1
ori   $sp, $zero, 0x7ffc  # stack
jal   mainp1              # go to program
halt

mainp1:
    push  $ra                 # save return address
    ori   $t8, $zero, 256
    ori   $t9, $zero, 0  
    ori   $s0, $zero, 0xFFFF  # min
    ori   $s1, $zero, 0x0000  # max
    ori   $s2, $zero, 0           

branch:
stack_empty:
    ori $t2, $zero, stackptr
    lw $t3, 0($t2)          
    beq $t3, $zero, stack_empty

    ori   $a0, $zero, l1      # move lock to arguement register
    jal   lock                
    jal   mypop              
    or    $t7, $zero, $v0     # assign return val to temp
    ori   $a0, $zero, l1      # move lock to arguement register
    jal   unlock              

findmax:
    andi   $a0, $s1, 0x0000FFFF
    andi   $a1, $t7, 0x0000FFFF
    jal  max
    or   $s1, $zero, $v0

findmin:
    andi   $a0, $s0, 0x0000FFFF
    jal  min
    or   $s0, $zero, $v0

findsum:
    andi $t7, $t7, 0x0000FFFF
    add $s2, $s2, $t7

counter:
    addi  $t9, $t9, 1
    bne   $t9, $t8, branch

calculation:
    or $a0, $zero, $s2
    or $a1, $zero, $t8
    jal divide
    or $s2, $zero, $v0
    or $s3, $zero, $v1
    ori $t0, $zero, minaddr
    sw $s0, 0($t0)
    ori $t0, $zero, maxaddr
    sw $s1, 0($t0)
    ori $t0, $zero, avgaddr
    sw $s2, 0($t0)

pop   $ra                 # get return address
jr    $ra                 # return to caller


mypop:
    ori $t0, $zero, stackptr
    ori $t1, $zero, baseptr
    lw $t2, 0($t0)                      # load offset
    lw $t3, 0($t1)                      # load base
    addi $t2, $t2, -4                   # update the offset
    sub $t3, $t3, $t2                   # calculate the place to pop
    lw $v0, 0($t3)                      # load the value
    sw $zero, 0($t3)                    # clean the stack
    sw $t2, 0($t0)                      # update the offset
    jr    $ra                 # return to caller


res:
cfw 0x0                   

stackptr:
cfw 0x0000
baseptr:
cfw 0x4000

org 0xc000
maxaddr:
cfw 0xbeef0000
minaddr:
cfw 0xbeef0004
avgaddr:
cfw 0xbeef0008
#######################################GIVEN STUFF##################################

# USAGE random0 = crc(seed), random1 = crc(random0)
#       randomN = crc(randomN-1)
#------------------------------------------------------
# $v0 = crc32($a0)
crc32:
lui $t1, 0x04C1
ori $t1, $t1, 0x1DB7
or $t2, $0, $0
ori $t3, $0, 32

crcl1:
slt $t4, $t2, $t3
beq $t4, $zero, crcl2

ori $t5, $0, 31
srlv $t4, $t5, $a0
ori $t5, $0, 1
sllv $a0, $t5, $a0
beq $t4, $0, crcl3
xor $a0, $a0, $t1
crcl3:
addiu $t2, $t2, 1
j crcl1
crcl2:
or $v0, $a0, $0
jr $ra
#------------------------------------------------------

# registers a0-1,v0-1,t0
# a0 = Numerator
# a1 = Denominator
# v0 = Quotient
# v1 = Remainder

#-divide(N=$a0,D=$a1) returns (Q=$v0,R=$v1)--------
divide:               # setup frame
push  $ra           # saved return address
push  $a0           # saved register
push  $a1           # saved register
or    $v0, $0, $0   # Quotient v0=0
or    $v1, $0, $a0  # Remainder t2=N=a0
beq   $0, $a1, divrtn # test zero D
slt   $t0, $a1, $0  # test neg D
bne   $t0, $0, divdneg
slt   $t0, $a0, $0  # test neg N
bne   $t0, $0, divnneg
divloop:
slt   $t0, $v1, $a1 # while R >= D
bne   $t0, $0, divrtn
addiu $v0, $v0, 1   # Q = Q + 1
subu  $v1, $v1, $a1 # R = R - D
j     divloop
divnneg:
subu  $a0, $0, $a0  # negate N
jal   divide        # call divide
subu  $v0, $0, $v0  # negate Q
beq   $v1, $0, divrtn
addiu $v0, $v0, -1  # return -Q-1
j     divrtn
divdneg:
subu  $a0, $0, $a1  # negate D
jal   divide        # call divide
subu  $v0, $0, $v0  # negate Q
divrtn:
pop $a1
pop $a0
pop $ra
jr  $ra
#-divide--------------------------------------------


# registers a0-1,v0,t0
# a0 = a
# a1 = b
# v0 = result

#-max (a0=a,a1=b) returns v0=max(a,b)--------------
max:
push  $ra
push  $a0
push  $a1
or    $v0, $0, $a0
slt   $t0, $a0, $a1
beq   $t0, $0, maxrtn
or    $v0, $0, $a1
maxrtn:
pop   $a1
pop   $a0
pop   $ra
jr    $ra
#--------------------------------------------------

#-min (a0=a,a1=b) returns v0=min(a,b)--------------
min:
push  $ra
push  $a0
push  $a1
or    $v0, $0, $a0
slt   $t0, $a1, $a0
beq   $t0, $0, minrtn
or    $v0, $0, $a1
minrtn:
pop   $a1
pop   $a0
pop   $ra
jr    $ra
#--------------------------------------------------
##########################################
# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
ll    $t0, 0($a0)         # load lock location
bne   $t0, $0, aquire     # wait on lock to be open
addiu $t0, $t0, 1
sc    $t0, 0($a0)
beq   $t0, $0, lock       # if sc failed retry
jr    $ra


# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock:
sw    $0, 0($a0)
jr    $ra
##############################################
