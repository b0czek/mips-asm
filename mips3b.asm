	.macro print_string(%string_address)
	li $v0, 4
	la $a0, %string_address
	syscall
	.end_macro
	
	.macro read_int(%dest_registry)
	li $v0, 5
	syscall
	move %dest_registry, $v0
	.end_macro
		
		
	.data
msg:		.asciiz "Podaj N:"
loadmsg:	.asciiz " n: "
errmsg: 	.asciiz "Blad"
newline:	.asciiz "\n"
separator:    	.asciiz ", "



	.text
	.globl main
main:
	print_string(msg)
	read_int($s0)
	
	bge $s0, 100, error
        blt $s0, 0, error

	mul $t0, $s0, 4
	sub $sp, $sp, $t0
	move $s1, $sp
	
	li $t0, 0
load:
		beq $t0, $s0, loaded
	
		li $v0,1
 	        move $a0,$t0
	        syscall
        
	        print_string(loadmsg)
 	        read_int($t1)
        
        	mul $t2, $t0, 4
        	add $t2, $t2, $s1
        	sw $t1, ($t2)

		add $t0, $t0, 1
		j load
loaded:
	move $a0, $s1
	move $a1, $s0
	jal sort
	
	li $t0, 0
print:
		beq $t0, $s0, printed
	
		mul $t1, $t0, 4
		add $t1, $t1, $s1
		
		lw $a0, ($t1)
		li $v0, 1
		syscall
	
		add $t1, $t0, 1
		beq $t1, $s0, nosep
		print_string(separator)
nosep:
		add $t0, $t0, 1
		j print
printed:
	mul $t0, $s0, 4
	add $sp, $sp, $t0
	j exit


error:
	print_string(errmsg)
exit:
	li $v0, 10
	syscall
	
	
	
	
sort:
	# $a0 <- address of data
        # $a1 <- data count
        
        sub $sp, $sp, 12
        sw $s0, 0($sp)
        sw $s1, 4($sp)
        sw $ra, 8($sp)
        move $s0,$a0
        move $s1,$a1

        li $t0, 0
loop1:
		beq $t0, $s1, sort_end
		li $t1, 0
		
		sub $t2, $s1, 1
		sub $t2, $t2, $t0
loop2:
			beq $t1, $t2, loop2_end
			
			mul $t3, $t1, 4
			add $t3, $t3, $s0
			
			lw $t4, ($t3)
			lw $t5, 4($t3)
			
			ble $t4, $t5, noswap
			xor $t4, $t4, $t5
			xor $t5, $t4, $t5
			xor $t4, $t4, $t5
			
			sw $t4, ($t3)
			sw $t5, 4($t3)
noswap:
			add $t1, $t1, 1
			j loop2
loop2_end:
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

