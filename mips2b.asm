	.text
	
	.globl main
main:
	li $v0, 4
	la $a0, msg
	syscall
	
	li $v0, 5
	syscall
	move $t0,$v0
	
	# check if n>0
	ble  $t0, 0, error
	
	# product
	li $s0, 1
	# iterator
	li $s1, 1
loop_start:
	mult $s1, $s0
	mfhi $s2
	bgt $s2,0,overflow
	
	mflo $s0
	
	# i++
	addi $s1, $s1, 1
	ble $s1,$t0, loop_start
	
	li $v0,1
	move $a0,$s0
	syscall
	
	j exit
	
	
overflow:
	li $v0, 4
	la $a0, error_overflow
	syscall
	
	li $v0, 1
	move $a0,$s1
	syscall
	
	j exit
error:
	li $v0, 4
	la $a0, error_msg
	syscall
exit:
	li $v0,10
	syscall
	
	.data
msg: 		.asciiz "Podaj liczbe >0\n" 
error_msg:	.asciiz "Blad\n"
error_overflow: .asciiz "Przepelnienie przy i = "	