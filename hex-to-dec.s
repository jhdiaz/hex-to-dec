.globl	main
.globl	counter
.globl	next
.globl	increment
.globl	input
.globl	invalid
.globl	convert
.globl	change
.globl	loop
.globl	ends
.globl	complete
.globl	display

.data
	.asciiz "Commands:\n1 = Enter a New String\n2 = Convert\n3 = Mean\n4 = Median\n5 = Display String\n6 = Display Array\n\nEnter a command: \n"
	.asciiz "Enter a New String: \n" # .asciiz is a null terminated string.
	.asciiz "Invalid command.\n"

.text
main:	
	addi $v0, $0, 4		# Prompt user.
	lui $a0, 0x1000		# Set upper 16 bits of address of the string in memory.
	or $0, $0, $0		# NOP.
	syscall

	addi $v0, $0, 8		# Command input.
	lui $a0, 0x1001		# $a0 = 0x10010000.
	or $0, $0, $0		# NOP.
	syscall

	addi $s1, $0, 0x31	# First command is saved for comparison.
	addi $s2, $0, 0x32	# Second command is saved for comparison.
	addi $s3, $0, 0x33	# Third command is saved for comparison.
	addi $s4, $0, 0x34	# Fourth command is saved for comparison.
	addi $s5, $0, 0x35	# Fifth command is saved for comparison.
	addi $t7, $0, 0x36	# Sixth command is saved for comparison.

	lb $s0, 0($a0)		# Command input from user is being saved for comparison.
	or $0, $0, $0		# NOP.
	beq $s0, $s1, input	# If the user entered 1 proceed to input.
	or $0, $0, $0		# NOP.
	beq $s0, $s2, convert	# If the user entered 2 proceed to convert.
	or $0, $0, $0		# NOP.	
	
	beq $s0, $s5, display	# If the user entered 5 proceed to display
	or $0, $0, $0		# NOP.

invalid:
	addi $v0, $0, 4		# An invalid command was input by the user.
	add $a0, $0, $0		# Register a0 is reset.
	lui $a0, 0x1000		# $a0 = 0x10000000.
	or $0, $0, $0		# NOP.
	addi $a0, $a0, 144	# $a0 is set to the address of the beginning of the string we wish to print.
	syscall
	beq $0, $0, main	# Return to main.
	or $0, $0, $0		# NOP.

input:
	addi $v0, $0, 4		# Ask user to enter a new string.
	add $a0, $0, $0		# $a0 is reset.
	lui $a0, 0x1000		# Upper 16-bits of $a0 are set.
	or $0, $0, $0		# NOP.
	addi $a0, $a0, 122	# $a0 is set to memory address where the string we wish to print begins.
	syscall

	lui $a2, 0x1000         # $a2 = 0x10000000.
        or $0, $0, $0           # NOP.
        addi $a2, $a2, 0x0202   # Array starts at 0x10000202 because first 2 bytes are reserved for number of elements.

	addi $v0, $0, 8		# 8 is stored in $v0 for string input syscall.
	add $a0, $0, $0		# Reset register $a0.
	lui $a0, 0x1000		# $a0 = 0x10000000.
	or $0, $0, $0		# NOP.
	addi $a0, $a0, 0x0100	# $a0 = 0x10000100 (Address where string is being stored).
	add $s6, $a0, $0	# Make a copy of the current $a0 value for future use.
	syscall

	beq $0, $0, main	# Return to main.
	or $0, $0, $0		# NOP, branch delay slot.

display:
	addi $v0, $0, 4		# syscall for displaying a string.
	lui $a0, 0x1000
	or $0, $0, $0
	addi $a0, 0x100		# Address of string we wish to print.
	syscall
	beq $0, $0, main	# Return to main.
	or $0, $0, $0		# NOP.

convert:
	add $t0, $0, $0         # int digits = 0;
        addi $t2, $0, 0x2c      # The hexadecimal value of a comma  used for comparison in the digit counter.
        addi $t3, $0, 0x0a      # The hexadecimal value of a null terminator.

counter:
        lb $t1, 0($s6)          # $t1 contains the current digit of the inputted string.
        or $0, $0, $0           # NOP.
        bne $t1, $t2, next      # As long as the current element is not equal to a comma proceed.
        or $0, $0, $0           # NOP.
	beq $0, $0, change	# End of integer was reached so we will convert the integer now.
	or $0, $0, $0		# NOP.

next:
        bne $t1, $t3, increment # As long as the end of the string has not been reached, continue.
        or $0, $0, $0           # NOP.
	addi $s7, $0, 10	# A 10 being added to register s7 indicates that the end of the string has been reached.
	beq $0, $0, change	# End of integer was reached so we will convert the integer now.
        or $0, $0, $0           # NOP.

increment:
        addi $t0, $t0, 1        # digits++;
        addi $s6, $s6, 1        # index++;
        beq $0, $0, counter     # Start over.
        or $0, $0, $0           # NOP.

change:
	sub $t4, $s6, $t0	# Subtract the count of digits from the index to get the current digit's index.
	lb $t5, 0($t4)		# Loading current digit for conversion.
	or $0, $0, $0		# NOP.
	addi $s6, $s6, 1	# Increment index by 1 because we are at a comma or end of string.
	addi $t5, $t5, -48	# Converting a number from a hex to a decimal by subtracting 0x30 from a digit's ascii value.
	add $t6, $t0, $0	# Make a copy of the count of digits.
	add $t9, $0, $0		# Initialize loop counter.	

loop:
	add $t8, $t5, $0	# Make copy of initial value of $t5 for multiplication.
	add $t5, $t5, $t8	# Multiplication.
	addi $t9, $t9, 1	# Increment counter.
	addi $v0, $0, 10	# Initialize ending index of loop.
	bne $t9, $v0, loop.	# As long as the ending index has not been reached continue.
	or $0, $0, $0		# NOP.
	add $t0, $0, $0		# Reset digits.
	beq $s7, $s7, complete	# Continue the conversion.
	or $0, $0, $0		# NOP.

complete:
	beq $s7, $v0, ends	# If the end of the string has been reached proceed.
	or $0, $0, $0		# NOP.
	sh $t5, 0($a2)		# Contents from $t5 are stored in array.
	or $0, $0, $0		# NOP.
	addi $a2, $a2, 2	# Increment by 2 as that is the address of the next halfword.
	beq $0, $0, convert	# Continue the conversion as long as the end of the string has not been reached.
	or $0, $0, $0		# NOP.

ends:
	lui $a2, 0x1000		# Set $a2 to 0x10000200 (beginning of array) in order to add halfword with element count.
	or $0, $0, $0		# NOP.
	addi $a2, 0x200
	sh $s6, 0($a2)		# The index (number of elements) is stored as the first halfword in the array.
	or $0, $0, $0		# NOP.
	beq $0, $0, main	# Return to main.
	or $0, $0, $0		# NOP.
