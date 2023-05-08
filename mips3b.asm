	.text
	.globl main
main:
	li $v0,4
	la $a0,msg
	syscall

	# load N
	li $v0,5
	syscall
	move $s0,$v0

	bge $s0, 100, error
	blt $s0, 0, error

	# allocate stack
	mul $t0, $s0, 4
	sub $sp, $sp, $t0
	move $s1, $sp


	li $s2, 0
loadloop:
	bge $s2, $s0, loaded

	li $v0,1
	move $a0,$s2
	syscall
	li $v0,4
	la $a0,msgl
	syscall

	# load integer
	li $v0,5
	syscall
	# calculate address to store value in
	mul $t0, $s2, 4
	add $t0, $t0, $s1
	sw $v0, 0($t0)

	# increment before loops
	add $s2, $s2, 1

	# call sort
	move $a0, $s1
	move $a1, $s2
	jal sort

	# print values
	li $s3,0
printloop:
	bge $s3, $s2, printed
	mul $t0, $s3, 4
	add $t0, $t0, $s1

	lw $a0, 0($t0)
	li $v0, 1
	syscall

	add $t0, $s3, 1
	beq $t0, $s2, printloop_noseparator
	li $v0,4
	la $a0, separator
	syscall
printloop_noseparator:

	add $s3, $s3, 1
	j printloop
printed:
	li $v0,4
	la $a0, newline
	syscall

	j loadloop
loaded:
	# free stack
	mul $t0, $s0, 4
	add $sp, $sp, $t0
	j exit

error:
	li $v0,4
	la $a0, errormsg
	syscall
	li $v0,1
	move $a0, $s0
	syscall

exit:
	li $v0,10
	syscall


sort:
	# $a0 <- address of data
	# $a1 <- data count

	# store registers s0 and s1 in memory
	sub $sp, $sp, 12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	# store return address to restore it after swap subroutine
	sw $ra, 8($sp)
	move $s0,$a0
	move $s1,$a1

	# iter1
	li $t0, 0
loop1:
	bge $t0,$s1, sort_end
	# iter2
	li $t1, 0
	move $t2,$s1
	# n - iter1 - 1
	sub $t2, $t2, 1
	sub $t2, $t2, $t0
loop2:
	bge $t1,$t2, loop1_end

	# multiply iter2 by size of int
	mul $t3, $t1, 4
	# add address to it
	add $t3, $t3, $s0
	# load n from memory
	lw $a0, 0($t3)
	# load n+1
	lw $a1, 4($t3)

	# compare values
	ble $a0, $a1, ifless
	jal swap
	# store values in memory
	sw $a0, 0($t3)
	sw $a1, 4($t3)

ifless:
	add $t1, $t1, 1
	j loop2
loop1_end:
	add $t0, $t0, 1
	j loop1

sort_end:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	add $sp, $sp, 12
	jr $ra

swap:
	# a0 <- element1
	# a1 <- element2
	# swap without buffer
	xor $a0, $a0, $a1
	xor $a1, $a0, $a1
	xor $a0, $a0, $a1
	jr $ra

	.data
msg: 		.asciiz "Podaj N: "
msgl:		.asciiz " n: "
errormsg:	.asciiz "error - n ="
separator:	.asciiz ", "
newline:	.asciiz "\n"
