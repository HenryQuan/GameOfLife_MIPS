  .data
maxiters: .space 4
# Strings for output
iterationString: .asciiz "# Iterations: "
afterString: .asciiz "=== After iteration "
restString: .asciiz " ===\n"
eol: .asciiz "\n"

  .text
  .globl main
main:
  # prologue
  addi $sp, $sp, -4
  sw   $fp, ($sp)
  move $fp, $sp
  addi $sp, $sp, -4
  sw   $ra, ($sp)

  # asking for input
  la $a0, iterationString
  li $v0, 4
  syscall
  li $v0, 5
  syscall
  # save it into maxiters
  sw $v0, maxiters

  # setting up some global variables
  li $s0, 1          # n
  li $s1, 0          # i
  li $s2, 0          # j
  lw $s3, N          # N
  li $s4, 0          # nn = 0
  li $s5, -1         # x = -1
  li $s6, -1         # y = -1
  jal nLoop

  # epilogue
  lw   $ra, ($sp)
  addi $sp, $sp, 4
  lw   $fp, ($sp)
  addi $sp, $sp, 4
  jr   $ra

# Three for loops here
nLoop:
  lw $t0, maxiters
  # if n <= maxiters
  ble $s0, $t0, iLoop

  # printing stuff here
  la $a0, afterString
  li $v0, 4
  syscall
  # since index starts from 0, print index + 1
  lw $t0, 0
  add $t0, $s0, $t0
  lw $a0, $t0
  li $v0, 1
  syscall
  la $a0, restString
  li $v0, 4
  syscall

  # copyBackAndShow

  jr $ra

iLoop:
  blt $s1, $s3, jLoop
  # n++ if i stops looping
  add $s0, $s0, 1
  j nLoop

jLoop:
  blt $s2, $s3, updating_board
  # i++ if j stops looping
  add $s1, $s1, 1
  j iLoop

# Do real stuff here
updating_board:
  # nn = neighbours(i, j)
  move $a0, $s1
  move $a1, $s2
  jal neighbours
  # calculate index here, v0 is the return value
  move $s4, $v0
  mul $t1, $s1, $s3
  add $t1, $t1, $s2

  lb $t2, board($t1)
  beq $t2, 1, isPattern
  beq $t2, 3, setPattern
  j removePattern

# if it is 1
isPattern:
  blt $s4, 2, removePattern
  beq $s4, 2, setPattern
  beq $s4, 3, setPattern
  j removePattern

# Set as 1
setPattern:
  # t1 = N * i + j
  mul $t1, $s1, $s3
  add $t1, $t1, $s2
  # set it 1
  lb $t2, 1
  sb $t2, board($t1)
  j increaseJ

# Set as 0
removePattern:
  # t1 = N * i + j
  mul $t1, $s1, $s3
  add $t1, $t1, $s2
  # set it as k (a2)
  lb $t2, 0
  sb $t2, board($t1)
  j increaseJ

increaseJ:
  # j++
  add $s2, $s2, 1
  j jLoop

# int neighbours(int i ($a0), int j ($a1))
neighbours:
  jal xLoop
  # return nn ($s4)
  move $v0, $s4
  jr $ra

xLoop:
  ble $s5, 1, yLoop
  jr $ra

yLoop:
  ble $s6, 1, getting_nn
  # x++ and go back
  add $s5, $s5, 1
  j xLoop

getting_nn:
  # t0 = i + x
  add $t0, $a0, $s5
  blt $t0, 0, increaseY
  # t1 = N - 1
  sub $t1, $s3, 1
  bgt $t0, $t1, increaseY
  # Reset t0 and t0 = j + y
  li $t0, 0
  add $t0, $a1, $s6
  blt $t0, 0, increaseY
  blt $t0, $t1, increaseY
  # If x == 0
  beq $s5, 0, x_is_zero
  # make t1 = t0, reset t0,
  # t0 = i + x, t1 = j + y
  move $t1, $t0
  li $t0, 0
  add $t0, $a0, $s5
  # t2 is the index, N * t0 + t1
  mul $t2, $s3, $t0
  add $t2, $t2, $t1
  # Load it into t3
  lb $t3, board($t2)
  beq $t3, 1, increase_nn
  j increaseY

x_is_zero:
  beq $s6, 0, increaseY
  # Go back if x == 0 but y != 0
  jr $ra

increase_nn:
  # nn++
  add $s4, $4, 1
  j increaseY

increaseY:
  # y++ and go back
  add $s6, $s6, 1
  j yLoop

# void copyBackAndShow()
copyBackAndShow:
