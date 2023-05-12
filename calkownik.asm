
	.data
deltax: .float 0.01
result:	.float 0.0
one:    .float 1.0
msg:    .asciiz "Stopien wielomianu: "
nfactor:.asciiz "Wspolczynnik dla x^"
colon:  .asciiz ": "
lowerbound: .asciiz "Dolna granica calkowania: "
upperbound: .asciiz "Gora granica calkowania: "

	
	.text
	.globl main
main:

	
	li $v0, 4
	la $a0, msg
	syscall
	
	li $v0, 5
	syscall
	move $s0, $v0

	mul $t0, $s0, 4
	add $t0, $t0, 4
	sub $sp, $sp, $t0
	
	move $t0, $s0
	move $t1, $sp

loadfactors:
	beq $t0,-1, endload
	
	li $v0, 4
	la $a0, nfactor
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, colon
	syscall
	
	li $v0, 6
	syscall
	
	s.s $f0, ($t1)
	add $t1, $t1, 4
	
	sub $t0, $t0, 1
	j loadfactors

endload:
	li $v0, 4
	la $a0, lowerbound
	syscall
	
	li $v0, 6
	syscall
	movf.s $f4, $f0
	
		
	li $v0, 4
	la $a0, upperbound
	syscall
	
	li $v0, 6
	syscall
	movf.s $f5, $f0

	l.s $f3, deltax
	l.s $f2, result 

integrate:
	c.le.s $f5, $f4
	bc1t exit
	
	mul $t5, $s0, 4
	add $t5, $t5, $sp
	
	l.s $f6, one
sum:
	blt $t5, $sp, sumstop
	l.s $f1, ($t5)
	
	mul.s $f7, $f6, $f3
	mul.s $f7, $f7, $f1
	
	add.s $f2, $f2, $f7
	mul.s $f6, $f6, $f4
	
	sub $t5, $t5, 4
	j sum
sumstop:
	
	
	
	
	add.s $f4, $f4, $f3
	j integrate
exit:
	
	li $v0, 2
	mov.s $f12, $f2
	syscall
	

	li $v0, 10
	syscall
	
