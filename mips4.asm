	.macro print_string(%string_address)
	li $v0, 4
	la $a0, %string_address
	syscall
	.end_macro	
	
	.macro read_int(%dest_register)
	li $v0, 5
	syscall
	move %dest_register, $v0
	.end_macro
	
	.macro print_int(%int_register)
	li $v0, 1
	move $a0, %int_register
	syscall
	.end_macro
	
	.eqv firstbit 0x80000000
	
	.data
prompt1:	.asciiz "Liczba wymiarow wektorow: "
separator: 	.asciiz ": "
wektor1:	.asciiz "wektor 1:\n"
wektor2:	.asciiz "wektor 2:\n"
result:		.asciiz "iloczyn skalarny: "
	.text
	.globl main
	
main:
	print_string(prompt1)
	read_int($s0)
	
	print_string(wektor1)
	jal load_vector
	move $s1, $v0
	
	print_string(wektor2)
	jal load_vector
	move $s2, $v0
	
	jal dotproduct
	move $s3, $v0
	
	print_string(result)
	print_int($s3)
	
	
	
	li $v0, 10
	syscall
	
	
	
load_vector:
	# przeliczenie ile slow na bitmape
	add $t0, $s0, 31
	srl $t0, $t0, 5	 # /32
	sll $t0, $t0, 2	 # * 4
	sub $sp, $sp, $t0
	move $t0, $sp		# bitmapa	
		
	
	li $t1, 0
	li $t2, 0 
	move $t3, $t0
load:
		beq $s0, $t1, loadend
		
		print_int($t1)
		print_string(separator)
		read_int($t4)
		
		beqz $t4,eqz
		
		# zapisania wartosci != 0
		sub $sp, $sp, 4
		sw $t4, ($sp)
		add $t2, $t2, 1
eqz:	 
		add $t1, $t1, 1
		# kiedy bitmapa jest pelna, zapisz do pamieci 
		andi $t4, $t1, 0x1f	# reszta z dzielenia przez 32
		bnez $t4, dontstorebitmap
		
		sw $t2, ($t3)
		li $t2, 0
		add $t3, $t3, 4
		
					
dontstorebitmap:
		sll $t2, $t2, 1

		j load
loadend:
	# kiedy niepelna bitmapa po zakonczeniu ladowania
	andi $t4, $t1, 0x1f	
	beqz $t4, dontstore
	
	# przesun ja do lewej strony
	li $t5, 31
	sub $t4, $t5, $t4

	sllv $t2, $t2, $t4
	sw $t2, ($t3)
	
dontstore:
	move $v0, $t0
	jr $ra


dotproduct:
	li $t0, 0		# iterator
	
	move $t1, $s1		# data address 1
	move $t2, $s2		# data address 2
	li $t3, 0	  	# product
	lw $t4, ($s1)		# bitmap 1
	lw $t5, ($s2)		# bitmap 2

product:
		beq $t0, $s0, productend
		
		# sprawdzenie msb i odjecie adresu -4 jezeli 1
		andi $t6, $t4, firstbit
		sgeu $t7, $t6, 1
		sll $t7, $t7, 2
		sub $t1, $t1, $t7
		
		andi $t7, $t5, firstbit
		sgeu $t8, $t7, 1
		sll $t8, $t8, 2
		sub $t2, $t2, $t8
		
		# sprawdzenie czy w obu wektorach msb = 1
		and $t8, $t6, $t7
		
		beqz $t8, dontload
		lw $t6, ($t1)
		lw $t7, ($t2)
		mul $t8, $t6, $t7
		add $t3, $t3, $t8
dontload:
		
		sll $t4, $t4, 1
		sll $t5, $t5, 1
		add $t0, $t0, 1
		
		# doczytywanie bitmapy
		andi $t6, $t0, 0x1f
		bnez $t6, dontloadbitmap
		
		srl $t6, $t0, 5
		sll $t6, $t6, 2
		
		add $t7, $t6, $s1
		lw $t4, ($t7)
		
		add $t7, $t6, $s2
		lw $t5, ($t7)
dontloadbitmap:
		
		j product	
productend:
	move $v0, $t3
	jr $ra
	
