#----------------------------------------------------------
# First Processor (Producer)
#----------------------------------------------------------

	org 	0x0000 				        # first processor
	ori		$s0, $zero, 256		    # 256 rand number
	ori		$s1, $zero, 0			    # counter
	ori		$s2, $zero, 0xbabe		# seed
	ori 	$s3, $zero, 0			    # stack pointer
	ori		$s4, $zero, 0			    # stack size
	ori		$s5, $zero, 10		  	# full stack size
	ori		$s6, $zero, 40		  	# stack base

producer:
  beq		$s1, $s0, done	      # if 256 done halt
	lw		$s4, offset($zero)		# load stack
	beq		$s4, $s5, producer    # if full, go back to producer
	ori 	$a0, $zero, l4		  	# move lock to argument register
	jal 	lock				          # acquire lock
	lw 		$s4, offset($zero)		# load stack
	addi	$s4, $s4, 1			      # increment the stack
	sw		$s4, offset($zero)		# store the current stack
	ori		$a0, $s2, 0		        # set seed
	jal 	crc32				          
	addi	$t0, $s3, stack     	# stack pointer
	sw		$v0, 0($t0)		      	# store the value in stack
	ori		$s2, $v0, 0x0000	    # update seed
	addi	$s3, $s3, 0x0004      # increment the stack pointer
	jal		check_stack           # reset the stack pointer
	ori 	$a0, $zero, l4
	jal 	unlock				        # release lock 
	addi 	$s1, $s1, 1		      	# increment the counter
	# beq 	$s1, $s0, done        # s1 = 256 finish
	j 		producer

check_stack:
	beq		$s3, $s6, reset_stack_pointer
	jr 		$ra 			

reset_stack_pointer:
	ori		$s3, $zero, 0
	jr		$ra 		
done:
	ori		$t5, $zero, 256
	sw		$t5, ready($zero)
	halt 						



#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
	org		0x200 	
	ori		$s6, $zero, 256
	ori		$s5, $zero, 0
	ori 	$s4, $zero, 40            # stack pointer
	ori		$s3, $zero, 0			        # stack base
	ori		$s2, $zero, 0x0000FFFF		# min
	ori		$s1, $zero, 0x00000000		# max
	ori 	$s0, $zero, 0x00000000		# sum

consumer:
	lw		$t3, offset($zero)
	beq		$t3, $zero, lock_check
	ori 	$a0, $zero, l4   
	jal		lock				          # acquire lock
	lw 		$t3, offset($zero)		# load stack		
	addi 	$t3, $t3, -1	        # decrement size
	sw		$t3, offset($zero) 	  # store value
	addi	$t4, $s3, stack 	    # base stack
	lw 		$t1, 0($t4) 		      # load the rand
	or  	$a1, $t1, $zero				# rand
	addi 	$s3, $s3, 4			      # stack +4
	jal		check_base 
findmin:
  	andi 	$a1, $a1, 0xFFFF 
	or 	  $a0, $s2, $zero		      
	jal		min 				          
	or 	  $s2, $v0, $zero				
findmax:      
	or 	  $a0, $s1, $zero			      
	jal		max 				          
	or 	  $s1, $v0, $zero		      	
	add 	$s0, $s0, $a1 	    	# find sum
	addi $s5, $s5, 1
	beq		$s5, $s6, calc

	ori 	$a0, $zero, l4			  # move lock to argument
	jal		unlock				        # release the lock
	j 		consumer			

calc:
	sw 		$s2, res_min($zero)		# min value
	sw		$s1, res_max($zero)		# max value
	or $a0, $zero, $s0
	ori $a1, $zero, 256
	jal divide
	or $s0, $zero, $v0
#	srl 	$s0, $s0, 8           # divide by 256
	sw 		$s0, res_avg($zero)		# store the value

	halt

lock_check:
	lw 		$t0, ready($zero) 		# if p0 finishes
	beq 	$t0, $zero, consumer	# not finish go back to consumer
	j 		calc                  # finish go to calculation

check_base:
	beq 	$s3, $s4, reset_base_pointer
	jr 		$ra 				

reset_base_pointer:
	ori 	$s3, $zero, 0
	jr 		$ra 			

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


# registers a0-1,v0,t0
# a0 = a
# a1 = b
# v0 = result

#-max (a0=a,a1=b) returns v0=max(a,b)--------------
max:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $zero, $a0
  slt   $t0, $a0, $a1
  beq   $t0, $zero, maxrtn
  or    $v0, $zero, $a1
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
  or    $v0, $zero, $a0
  slt   $t0, $a1, $a0
  beq   $t0, $zero, minrtn
  or    $v0, $zero, $a1
minrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra
#--------------------------------------------------


divide:               # setup frame
  push  $ra           # saved return address
  push  $a0           # saved register
  push  $a1           # saved register
  or    $v0, $zero, $zero   # Quotient v0=0
  or    $v1, $zero, $a0  # Remainder t2=N=a0
  beq   $zero, $a1, divrtn # test zero D
  slt   $t0, $a1, $zero  # test neg D
  bne   $t0, $zero, divdneg
  slt   $t0, $a0, $zero  # test neg N
  bne   $t0, $zero, divnneg
divloop:
  slt   $t0, $v1, $a1 # while R >= D
  bne   $t0, $zero, divrtn
  addiu $v0, $v0, 1   # Q = Q + 1
  subu  $v1, $v1, $a1 # R = R - D
  j     divloop
divnneg:
  subu  $a0, $zero, $a0  # negate N
  jal   divide        # call divide
  subu  $v0, $zero, $v0  # negate Q
  beq   $v1, $zero, divrtn
  addiu $v0, $v0, -1  # return -Q-1
  j     divrtn
divdneg:
  subu  $a0, $zero, $a1  # negate D
  jal   divide        # call divide
  subu  $v0, $zero, $v0  # negate Q
divrtn:
  pop $a1
  pop $a0
  pop $ra
  jr  $ra
crc32:
  lui $t1, 0x04C1
  ori $t1, $t1, 0x1DB7
  or $t2, $zero, $zero
  ori $t3, $zero, 32

l1:
  slt $t4, $t2, $t3
  beq $t4, $zero, l2

  ori $t5, $zero, 31
  srlv $t4, $t5, $a0
  ori $t5, $zero, 1
  sllv $a0, $t5, $a0
  beq $t4, $zero, l3
  xor $a0, $a0, $t1
l3:
  addiu $t2, $t2, 1
  j l1
l2:
  or $v0, $a0, $zero
  jr $ra
#--------------------------------------------------
l4:
	cfw 	0x0000

ready:
	cfw 	0x0000
offset:       
	cfw 	0x000

stack:
	cfw 	0x000
	cfw 	0x000
	cfw 	0x000
	cfw 	0x000
	cfw 	0x000
	cfw 	0x000
	cfw 	0x000
	cfw 	0x000
	cfw 	0x000
	cfw 	0x000
  
org 	0x600
res_min:
	cfw 	0xbeef
res_max:
	cfw 	0xdead
res_avg:
	cfw 	0xbad1
