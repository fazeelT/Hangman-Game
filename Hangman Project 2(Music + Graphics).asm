	.data
wordbank:	.asciiz "word.txt"	# the txt file
list:		.space 128		# 128 bytes for bank
word:		.space 16		# for picking word
guessword:	.space 16		# for the unknown word
guess:		.space 4		# user guess

Begin:		.asciiz "Please fill in the words:  "
Enter:		.asciiz "Enter a letter "
Guesses:	.asciiz "Guesses remaining: "
Win:		.asciiz "You won!"
Lose:		.asciiz "You lost!"
Answer:		.asciiz "The correct answer was: "
PlayAgain:      .asciiz "Wanna Play again?(y/n)?"
ByeBye:         .asciiz "Bye Bye"
copyright:      .asciiz " © UTD CS3340 Group(Steven, Philips, Kameron, Fazeel"

Guess1:         .asciiz "1"
Guess2:         .asciiz "2"
Guess3:         .asciiz "3"
Guess4:         .asciiz "4"
Guess5:         .asciiz "5"
Guess6:         .asciiz "6"

Hangman11:  .asciiz "|---------------------"
Hangman12:  .asciiz "|                    |"
Hangman13:  .asciiz "|                   ( )"
Hangman14:  .asciiz "|"
Hangman15:  .asciiz "|"
Hangman16:  .asciiz "|"
Hangman17:  .asciiz "|"
Hangman18:  .asciiz "|"
Hangman19:  .asciiz "........"
neck:  .asciiz "|                    |"
hands:  .asciiz "|                   /|\\"
stomach:  .asciiz "|                    |"
legs:  .asciiz "|                   / \\"
floor:  .asciiz ".....             ........"

clear:      .asciiz "                            "
clearScreen:.asciiz "                                                                       "
beep: .byte 72
duration: .byte 100
volume: .byte 127

newl: .asciiz "\n"


	.text
	.globl links
links:	jal main
	jal words
	jal game
	j exit
############################ LOAD WORD BANK
main:	li $v0, 13		# open file syscall
	la $a0, wordbank
	li $a1, 0		# flags
	li $a2, 0		# mode
	syscall
	
	move $s0, $v0
	
	li $v0,	14		# read file syscall
	move $a0, $s0		# file descriptor
	la $a1, list		# input buffer address
	li $a2, 64		# max # of characters to read
	syscall
	
	li $v0, 16
	move $a0, $s0
	syscall
	
	jr $ra
	
############################# RANDOMLY GET WORDS	
words:	li $v0, 42		# random range syscall
	li $a0, 2		# id of pseudorandom number generator
	li $a1, 11		# upper bound of range of returned values
	syscall
	
	move $t0, $a0		# moves random int
	la $s0, list		# current letter address
	
loop:	beqz $t0, getword	# branch to getword if 0
	lb $t2, ($s0)		# load $s0 into $t2
	bne $t2, 0x0a, loop2	# new line
	subi $t0, $t0, 1	# subtract 1 from $t0
	
loop2:	addi $s0, $s0, 1	# add 1 into $s0
	b	loop		# jumps back to loop	
	
getword: la $t0, word		

loop3:	lb $t1, ($s0)
	beq $t1, 0x0d, endloop # exit when there is a newline
	sb $t1, ($t0)		# store $t0 (should make a copy of word)
	addi $s0, $s0, 1	# offsets wordbank
	addi $t0, $t0, 1	# offsets word
	b loop3
endloop:
	b bexit

########################### Music
	  li $t7,0
Music: 	  li $a0, 61 	#Play the losing sound
  	  li $a1, 1000  
  	  li $a2, 8
  	  li $a3, 24
  	  la $v0, 33
  	  syscall
  	  addi $a0, $a0, 1
  	  beq $a0, 73, resetMusic
  	  lw $t7, 0xffff0000
  	  beq $t7, 1, bexit
  	  b Music	  
		
resetMusic: li $a0, 61
	    b Music			
					
############################ THE GAME

game:	li $s0, 6		# number of guesses (6 tries)
	la $t0, word		# load word
	la $t1, guessword 	# load unknown word
	li $t2, 0x58		# hex for underscore (blank spaces)
	li $s1, 0		# store 0 for $s1 (guesses)
	
start:	sb $t2, ($t1)	# stores word to be guessed
	add $t0, $t0, 1		# increase word address
	add $t1, $t1, 1		# increase guessword address
	lb $t3, ($t0)
	bne $t3, 0x00, start	# does not equal 0, keeps looping
	
gloop:	jal print
	jal gguess
	
	jal done
	beqz $a0, gloop		# jumps back to main loop 
	li $s1, 1		# number of guesses stops at 1
	j gexit
	
############################ PRINTING

print:	 addi $sp, $sp -4
	 sw $ra, 0($sp)
	 
	 la $a0 , Begin
	 li $a1 , 1 #x = 1
	 li $a2 , 4 #y = 8
	 li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	
	 la $a0 , guessword
	 li $a1 , 27 #x = 1
	 li $a2 , 4 #y = 8
	 li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	   la $a0 , Guesses
	   li $a1 , 1 #x = 1
	   li $a2 , 5 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	 	
	   la $a0 , copyright
	   li $a1 , 20 #x = 1
	   li $a2 , 14 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	   
	   lw $ra, 0($sp)
	   addi $sp, $sp 4
	
	li $v0, 1		# number of guesses
	#move $a0, $s0
	#syscall
	
	beq $s0, 6, guess6
	beq $s0, 5, guess5
	beq $s0, 4, guess4
	beq $s0, 3, guess3
	beq $s0, 2, guess2
	beq $s0, 1, guess1

guess6: addi $sp, $sp -4
	  sw $ra, 0($sp)
	 
	   la $a0 , Guess6
	   li $a1 , 20 #x = 1
	   li $a2 , 5 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	 
	   lw $ra, 0($sp)
	   addi $sp, $sp 4
	   b bexit	
	   
guess5: addi $sp, $sp -4
	  sw $ra, 0($sp)
	 
	   la $a0 , Guess5
	   li $a1 , 20 #x = 1
	   li $a2 , 5 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	 
	   lw $ra, 0($sp)
	   addi $sp, $sp 4
	   b bexit
	   
guess4: addi $sp, $sp -4
	  sw $ra, 0($sp)
	 
	   la $a0 , Guess4
	   li $a1 , 20 #x = 1
	   li $a2 , 5 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	 
	   lw $ra, 0($sp)
	   addi $sp, $sp 4
	   b bexit
	   
guess3: addi $sp, $sp -4
	  sw $ra, 0($sp)
	 
	   la $a0 , Guess3
	   li $a1 , 20 #x = 1
	   li $a2 , 5 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	 
	   lw $ra, 0($sp)
	   addi $sp, $sp 4
	   b bexit
	   
guess2: addi $sp, $sp -4
	  sw $ra, 0($sp)
	 
	   la $a0 , Guess2
	   li $a1 , 20 #x = 1
	   li $a2 , 5 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	 
	   lw $ra, 0($sp)
	   addi $sp, $sp 4
	   b bexit
	   
guess1: addi $sp, $sp -4
	  sw $ra, 0($sp)
	 
	   la $a0 , Guess1
	   li $a1 , 20 #x = 1
	   li $a2 , 5 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	 
	   lw $ra, 0($sp)
	   addi $sp, $sp 4

	b bexit
	
############################ GUESSING

gguess:	    addi $sp, $sp -4
	    sw $ra, 0($sp)
	 
	   la $a0 , Enter
	   li $a1 , 1 #x = 1
	   li $a2 , 6 #y = 8
	   li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	   jal KGASPrintString
	 
	   jal Music
	   
	   lw $ra, 0($sp)
	   addi $sp, $sp 4
#	  li $t7, 0
#waitUser: beq $t7, 1, userInput
#	  lw $t7, 0xffff0000
#	  b waitUser
	  
userInput: la $a0, guess
	   lw $t8, 0xffff0004
	   sb $t8, ($a0)
	   
	
########################### SEE IF GUESS IS IN UNKNOWN WORD

gu:	li $t0, 0	# index
	la $t5, guess
	lb $t1, ($t5)	# characters go into $t1
	la $t2, word
	la $t3, guessword
	li $t5, 0
	
guloop: lb $t4, ($t2) 		# load current word
	beq $t4, 0x00, guexit   # if null exit
	bne $t4, $t1, gufail	# jumps to fail loop
	sb $t1, ($t3)		# makes letter appear
	li $a0, 80		#Play sound for correct guess
  	li $a1, 500 
  	li $a2, 64
  	li $a3, 24
  	la $v0, 33
  	syscall
	li $t5, 1
	
gufail: addi $t2, $t2, 1
	addi $t3, $t3, 1
	
	b guloop
	
guexit:	beq $t5, 1, bexit
	subi $s0, $s0, 1
	li $a0, 66	#Play sound for wrong guess
  	li $a1, 500  # half second
  	li $a2, 64
  	li $a3, 120
  	la $v0, 33
	syscall
	beq $s0,5, h1
	beq $s0,4, h2
	beq $s0,3, h3
	beq $s0,2, h4
	beq $s0,1, h5
	b bexit

h1: 	  addi $sp, $sp -4
	  sw $ra, 0($sp)
	  
	  la $a0 , Hangman11
	  li $a1 , 45 #x = 1
	  li $a2 , 1 #y = 1
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , Hangman12
	  li $a1 , 45 #x = 1
	  li $a2 , 2 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , Hangman13
	  li $a1 , 45 #x = 1
	  li $a2 , 3 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , Hangman14
	  li $a1 , 45 #x = 1
	  li $a2 , 4 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , Hangman15
	  li $a1 , 45 #x = 1
	  li $a2 , 5 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , Hangman16
	  li $a1 , 45 #x = 1
	  li $a2 , 6 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , Hangman17
	  li $a1 , 45 #x = 1
	  li $a2 , 7 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , Hangman18
	  li $a1 , 45 #x = 1
	  li $a2 , 8 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , Hangman19
	  li $a1 , 42 #x = 1
	  li $a2 , 8 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  lw $ra, 0($sp)
	  addi $sp, $sp, 4
	  
	  b bexit
	  
h2: 	  addi $sp, $sp -4
	  sw $ra, 0($sp)
	  
	  la $a0 , neck
	  li $a1 , 45 #x = 1
	  li $a2 , 4 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  lw $ra, 0($sp)
	  addi $sp, $sp, 4
	  
	  b bexit
	  
h3:	  addi $sp, $sp -4
	  sw $ra, 0($sp)
	  
	  la $a0 , hands
	  li $a1 , 45 #x = 1
	  li $a2 , 5 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  lw $ra, 0($sp)
	  addi $sp, $sp, 4
	  b bexit
	  
h4: 	  addi $sp, $sp -4
	  sw $ra, 0($sp)
	  
	  la $a0 , stomach
	  li $a1 , 45 #x = 1
	  li $a2 , 6 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  lw $ra, 0($sp)
	  addi $sp, $sp, 4
	  
	  b bexit
	  
h5: 	  addi $sp, $sp -4
	  sw $ra, 0($sp)
	  
	  la $a0 , legs
	  li $a1 , 45 #x = 1
	  li $a2 , 7 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  la $a0 , floor
	  li $a1 , 45 #x = 1
	  li $a2 , 8 #y = 8
	  li $a3 , 0x40 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  lw $ra, 0($sp)
	  addi $sp, $sp, 4
	  
	  b bexit
############################ EXITS

gexit:	jal  print
	beqz $s1, loseexit
	b winexit
	
winexit: addi $sp, $sp -4
	 sw $ra, 0($sp)
	
	 la $a0 , Win
	 li $a1 , 35 #x = 1
	 li $a2 , 12 #y = 8
	 li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	  
	 li $a0, 31 	#PLay victory sound
  	 li $a1, 4000  
  	 li $a2, 64
  	 li $a3, 24
  	 la $v0, 33
  	 syscall
  	  	  
	  la $a0 , PlayAgain
	  li $a1 , 28 #x = 1
	  li $a2 , 13 #y = 8
	  li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  jal Music
	  
	  lw $ra, 0($sp)
	  addi $sp, $sp, 4

	  
userInput2: lw $t8, 0xffff0004
	
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 1 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 2 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 3 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 4 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 5 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 6 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 7 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 8 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 9 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 10 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 11 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 12 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 1 #x = 1
	 li $a2 , 13 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	  
	  beq $t8, 0x00000079, Restart
	  
	 la $a0 , ByeBye
	 li $a1 , 35 #x = 1
	 li $a2 , 12 #y = 8
	 li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 li $v0,32
	 li $a0, 5000
	 syscall
	 
	 la $a0 , clearScreen
	 li $a1 , 35 #x = 1
	 li $a2 , 12 #y = 8
	 li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 la $a0 , clearScreen
	 li $a1 , 20 #x = 1
	 li $a2 , 14 #y = 8
	 li $a3 , 0x00 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	 jal KGASPrintString
	 
	 li $v0,32
	 li $a0, 5000
	 syscall
	  
	 j exit
	  
Restart:  b links	  
	  
	 	 	 
loseexit: addi $sp, $sp -4
	  sw $ra, 0($sp)
	  
	  la $a0 , Lose
	  li $a1 , 35 #x = 1
	  li $a2 , 12 #y = 8
	  li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  lw $ra, 0($sp)
	  addi $sp, $sp, 4
	  
	  li $a0, 66 	#Play the losing sound
  	  li $a1, 5000  
  	  li $a2, 64
  	  li $a3, 24
  	  la $v0, 33
  	  syscall
	  
	  addi $sp, $sp -4
	  sw $ra, 0($sp)
	  
	  la $a0 , clear
	  li $a1 , 50 #x = 1
	  li $a2 , 8 #y = 8
	  li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  
	  
	  la $a0 , PlayAgain
	  li $a1 , 28 #x = 1
	  li $a2 , 13 #y = 8
	  li $a3 , 0xF0 #c o l o r = w h i t e c h a r a c t e r (F) , b l a c k background ( 0 )
	  jal KGASPrintString
	  
	  jal Music
	  
	  lw $ra, 0($sp)
	  addi $sp, $sp, 4
	  
	  j userInput2

########################### Display on the Jame's Plugin	
KGASPrintString :
          li $t1 , 0xFFFF000C
	  sb $a1 , 2 ( $t1 )
	  sb $a2 ,  1( $t1 )
	  sb $a3 , ( $t1 )
KGASPSLoop:
	  lb $t0 , ( $a0 )
	  beqz $t0 , KGASPSLoopEnd
	  sb $t0 , 3 ( $t1 )
          addi $a0 , $a0 , 1
	  addi $a1 , $a1 , 1
	  sb $a1 , 2 ( $t1 )
	  b KGASPSLoop
KGASPSLoopEnd :
	  jr $ra
############################################################
done:	blez $s0, gexit
	la $t1, guessword
	
done2:	lb $t2, ($t1)
	beq $t2, 0x00, doneall
	beq $t2, 0x58, notdone
	addi $t1, $t1, 1
	b done2
	
doneall:	li $s1, 1
		b bexit
		
notdone:	li $a0, 0
		b bexit
		
bexit:		jr $ra
	
exit:	li $v0, 10
	syscall
