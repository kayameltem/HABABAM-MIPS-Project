.data
	A: .word 720, 480, 80, 3, 1, 0 # encrypted similarity data
	size: .word 6 # size of the A[] array
	comma: .asciiz ", "
	bracket1: .asciiz "Data[] = { "
	bracket2: .asciiz " }\n"
	printSize: .asciiz "Size = "
	similarity: .asciiz "\nThe average similarity score is: "
	.text
	.globl main
main:
	la $t0, A # Load the address of A[0] to register t0
	lw $s0, size # size of array
	addi $t1, $0, 0  # i = 0
for:		
	beq $t1, $s0, done  # if i == size, done
	sll $t2, $t1, 2 # $t2 = i * 4 , let's $t2 call as index
	add $t2, $t2, $t0 # address of array[index]
	lw $t3,  0($t2)  # array[index]
	andi $s1, $t3, 1 # checks the right most bit to understand whether array[i] is even or not
	beq $s1, $0, else # if array[index] is even, jump to else
	sll $t4, $t3, 2  # $t4 = array[index] * 4
	add $t3, $t3, $t4 # $t4 = array[index] * 5
	sw $t3, 0($t2) # array[index] = array[index] * 5
	j always  # jump to always 
else:
	sra $t3, $t3, 3  # $t3 = array[index] / 8
	sw $t3, 0($t2) # array[index] = array[index] / 8

always:
	addi $t1, $t1, 1 # i++
	j for # jump to beginning of the loop
done: 
	#clear $t1
	addi $t1, $0, 0  # i = 0
	
	# print "Data[] = { "
	li $v0, 4
	la $a0, bracket1
	syscall
while:
	beq $t1, $s0, end_while # if i == size, jump to end_while
	sll $t2, $t1, 2 # index = i*4
	add $t2, $t2, $t0 # address of array[index]
	lw $t3, 0($t2) # array[index]
	addi $t1, $t1, 1 # i++		
				
	# prints the current number
	li $v0, 1
	move $a0, $t3
	syscall
			
	# prints a comma
	beq $t1, $s0, end_while
	li $v0, 4
	la $a0, comma
	syscall			
	j while # jump to while
		
end_while:

	# print " }"
	li $v0, 4
	la $a0, bracket2
	syscall
	
	# print "Size = "		
	li $v0, 4
	la $a0, printSize
	syscall
		
	# print size of the array A
	li $v0, 1
	lw $a0, size
	syscall
	
	la $a0, A  # load tha address of the array
	lw $a1, size # load the size
			
	jal average # function call for average
			
	# print "\nThe average similarity score is: "
	li $v0, 4
	la $a0, similarity
	syscall
	
	# print the value of average similiarity
	li $v0, 1
	move $a0, $v1
	syscall
	
	# terminate the program
	li $v0,10
	syscall
				
# average function, calculates the average similarity			
average:
	subi $sp, $sp, 8 #allocate stack
	sw $s4, 4($sp) # store $s4 on the stack, stores the value of n
	sw $ra, 0($sp) #store $ra on the stack

	#recursive step
	bne $a1, 1, recursive # if size is not equal to 1, jump to recursive
	
	#base step
	lw $v1, 0($a0) # load the value of A[0] to $v1	
	div $v1, $v1, $a1  # A[0] / n 
	j average_done
recursive:	
	subi $a1, $a1, 1 # calculate n-1 for recursive call
	move $s4, $a1 # copy the n-1
	jal average  #recursive call
	mul $t2, $s4, 4 # calculate the index of A[n-1]
	add $t2, $t2, $a0 # calculate the address of A[n-1]
	lw $t3, 0($t2) # store the value of A[n-1]
	mul $v1, $s4, $v1 # (n-1) * average(n-1)
	add $v1, $v1, $t3 # A[n-1] + (n-1) * average(n-1)
	addi $t2, $s4, 1 # $t2 = n
	div $v1, $v1, $t2 # (A[n-1] + (n-1) * average(n-1)) / n
average_done:
	lw $ra, 0($sp) #load $ra from the stack
	lw $s4, 4($sp) #load $s4 from the stack
	addi $sp, $sp, 8 #deallocate the stack
	jr $ra #return 
	
	
