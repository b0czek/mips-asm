#=============================================
.eqv STACK_SIZE 2048

#=============================================
.data

# obszar na zapamiętanie adresu stosu systemowego
sys_stack_addr: .word 0

# deklaracja własnego obszaru stosu
stack: .space STACK_SIZE
# int global_array[10] = { 1,2,3,4,5,6,7,8,9,10 };
global_array:
	.word 1
	.word 2
	.word 3
	.word 4
	.word 5
	.word 6
	.word 7
	.word 8
	.word 9
	.word 10
global_array_size:
	.word 10
# ============================================
.text
# czynności inicjalizacyjne
	sw $sp, sys_stack_addr 		# zachowanie adresu stosu systemowego
	la $sp, stack+STACK_SIZE 	# zainicjowanie obszaru stosu

# początek programu programisty - zakładamy, że main
# wywoływany jest tylko raz
main:
	sub $sp, $sp, 4 # int s;
	
	sub $sp, $sp, 8 # zarezerwowanie miejsca na stosie na argumenty funkcji
	la $t0, global_array	 
	sw $t0, 4($sp)		# argument 1 
	lw $t0, global_array_size
	sw $t0, 0($sp) 		# argument 2
	jal sum
	
	lw $t0, ($sp)		# wczytanie zwroconej wartosci
	sw $t0, 12($sp)		# s = sum(...);
	
	add $sp, $sp, 12	# usuniecie zwroconej wartosci i argumentow ze stosu
	
	li $v0, 1		# print(s)
	lw $a0, ($sp)
	syscall
	
	add $sp, $sp, 4		# usuwam zmienna lokalna ze stosu
	
	# koniec podprogramu main:
	lw $sp, sys_stack_addr # odtworzenie wskaźnika stosu
	# systemowego
	li $v0, 10
	syscall
	
	
sum:
	sub $sp, $sp, 8 	# zarezerwowanie miejsca na wartosc zwracana i adres powrotu
	sw $ra, ($sp) 		# umieszczenie adresu powrotu na wierzcholku stosu
	
	sub $sp, $sp, 8		# int i; int s;
	
	# 0 - s
	# 4 - i
	# 8 - ra
	# 12 - return val
	# 16 - array_size
	# 20 - array address
	
	
	sw $zero, ($sp)		# s = 0;
	lw $t0, 16($sp)		# wczytanie array_size
	subi $t0, $t0, 1	# array_size - 1
	sw $t0, 4($sp)		# i = array_size - 1;
	
loop:
	lw $t0, 4($sp)
	bltz $t0, endloop 	# while (i >= 0)
	
	lw $t0, 4($sp)		# wczytuje i
	sll $t0, $t0, 2		# mnoze *4
	
	lw $t1, 20($sp)		# wczytuje address tablicy
	add $t0, $t1, $t0	# offsetuje adres tablicy o i*4 bajty
	lw $t0, ($t0)		# wczytuje wartosc tablicy pod obliczonym adresem
	
	lw $t1, ($sp)		# wczytuje s
	add $t1, $t1, $t0	# s + array[i];
	sw $t1, ($sp)		# s = s + array[i];
	
	
	lw $t0, 4($sp)		# wczytuje i
	subi $t0, $t0, 1	# i - 1
	sw $t0, 4($sp)		# i = i - 1
	
	j loop	
endloop:
	lw $t0, ($sp)		# odczytuje wynik s
	sw $t0, 12($sp)		# zapisuje zwracana wartosc
	
	add $sp, $sp, 8		# usuwam zmienne lokalne ze stosu
	
	lw $ra, ($sp)		# wczytuje adres powrotny
	
	add $sp, $sp, 4		# przesuwam wierzcholek stosu na zwracana wartosc
	
	jr $ra			# powrot do maina
