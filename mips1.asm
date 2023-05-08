	.text
	
	.globl main
main:
	
	li $v0,4
	la $a0,msgw
	syscall

	#load a
	li $v0,4
	la $a0,msga
	syscall
	
	li $v0,5
	syscall
	move $t0,$v0
	
	#load b
	li $v0,4
	la $a0, msgb
	syscall
	
	li $v0,5
	syscall
	move $t1,$v0
	
	#load c
	li $v0,4
	la $a0, msgc
	syscall
	
	li $v0,5
	syscall
	move $t2,$v0
	
	#load d
	li $v0,4
	la $a0, msgd
	syscall
	 
	li $v0,5
	syscall
	move $t3, $v0
	
	#load x
	li $v0,4
	la $a0, msgx
	syscall
	
	li $v0,5
	syscall
	move $t4, $v0
	
	# $s0 <- c*x
	mult $t2,$t4
	mflo $s0
	# $t3 <- c*x + d
	add $t3,$t3,$s0
	
	# $s2 <- x*x
	mult $t4,$t4
	mflo $s2
	
	# $s0 <- b*x*x
	mult $s2,$t1
	mflo $s0
	# $t3 <- b*x^2 + c*x + d
	add $t3,$t3,$s0
	
	# $s2 <- x*x*x
	mult $t4,$s2
	mflo $s2
	
	# $s0 <- a*x*x*x
	mult $s2,$t0
	mflo $s0
	
	# $t3 <- a*x*x*x + b*x^2 + c*x + d
	add $t3,$t3,$s0
	
	li $v0,1
	move $a0,$t3
	syscall
	
	li $v0,10
	syscall
	
	.data
	
msgw: .asciiz "y = ax^3 + bx^2 +cx +d\n"	
msga: .asciiz "podaj a\n"
msgb: .asciiz "podaj b\n"
msgc: .asciiz "podaj c\n"
msgd: .asciiz "podaj d\n"
msgx: .asciiz "podaj x\n"
