# board.s ... Game of Life on a 10x10 grid

   .data

N: .word 10  # gives board dimensions

board:
   .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
   .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
newBoard: .space 100
maxiters: .space 4
one: .byte 1
zero: .byte 0
# Strings for output
iterationString: .asciiz "# Iterations: "
afterString: .asciiz "=== After iteration "
restString: .asciiz " ===\n"
dot: .asciiz "."
hash: .asciiz "#"
updatingboard: .asciiz "updating_board\n"
eol: .asciiz "\n"
comma: .asciiz ", "

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
  # save it into s7
  sw $v0, maxiters

  # setting up some global variables
  li $s0, 1          # n
  li $s1, 0          # i
  li $s2, 0          # j
  lw $s3, N          # N
  li $s4, 0          # nn = 0
  li $s5, -1         # x = -1
  li $s6, -1         # y = -1
  lw $s7, maxiters
  jal nLoop

exit:
  # epilogue
  lw   $ra, ($sp)
  addi $sp, $sp, 4
  lw   $fp, ($sp)
  addi $sp, $sp, 4
  jr   $ra

# Three for loops here
nLoop:
  # if n <= maxiters
  ble $s0, $s7, iLoop
  j exit

iLoop:
  blt $s1, $s3, jLoop
  # printing stuff here
  la $a0, afterString
  li $v0, 4
  syscall
  move $a0, $s0
  li $v0, 1
  syscall
  la $a0, restString
  li $v0, 4
  syscall
  # copyBackAndShow
  jal copyBackAndShow

  # n++ and reset i
  addi $s0, $s0, 1
  li $s1, 0

  j nLoop

jLoop:
  blt $s2, $s3, updating_board
  # i++ and reset j
  addi $s1, $s1, 1
  li $s2, 0
  j iLoop

# Do real stuff here
updating_board:
  jal neighbours
  # calculate index here, i * N + j
  mul $t1, $s1, $s3
  add $t1, $t1, $s2

  # load byte from board
  lb $t2, board($t1)
  beq $t2, 1, isPattern
  beq $s3, 3, setPattern
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
  lb $t0, one
  sb $t0, newBoard($t1)
  j increaseJ

# Set as 0
removePattern:
  # t1 = N * i + j
  mul $t1, $s1, $s3
  add $t1, $t1, $s2
  # set it 0
  lb $t0, zero
  sb $t0, newBoard($t1)
  j increaseJ

increaseJ:
  # j++
  addi $s2, $s2, 1
  j jLoop

# int neighbours(int i (s1), int j (s2))
neighbours:
  # reset
  li $s4, 0
  li $s5, -1
  li $s6, -1
  j xLoop

xLoop:
  ble $s5, 1, yLoop
  jr $ra

yLoop:
  ble $s6, 1, getting_nn
  # x++ and reset y
  addi $s5, $s5, 1
  li $s6, -1
  j xLoop

getting_nn:
  # t0 = i + x
  add $t0, $s1, $s5
  blt $t0, 0, increaseY

  # t1 = N - 1
  sub $t1, $s3, 1
  bgt $t0, $t1, increaseY

  # t0 = j + y
  add $t0, $s2, $s6
  blt $t0, 0, increaseY
  bgt $t0, $t1, increaseY
  # If x == 0
  beq $s5, 0, x_is_zero
  j y_isnot_zero

y_isnot_zero:
  # t0 = i + x, t1 = j + y
  move $t1, $t0
  add $t0, $s1, $s5
  # t2 is the index, N * t0 + t1
  mul $t2, $s3, $t0
  add $t2, $t2, $t1
  # Load it into t3
  lb $t3, board($t2)
  lb $t4, one
  beq $t3, $t4, increase_nn
  j increaseY

x_is_zero:
  beq $s6, 0, increaseY
  # Go back if x == 0 but y != 0
  j y_isnot_zero

increase_nn:
  # n++
  addi $s4, $s4, 1
  j increaseY

increaseY:
  # y++ and go back
  addi $s6, $s6, 1
  j yLoop

# void copyBackAndShow()
copyBackAndShow:
  li $t0, 0         # i
  li $t1, 0         # j
  j iLoopPrint

iLoopPrint:
  blt $t0, $s3, jLoopPrint
  jr $ra

jLoopPrint:
  blt $t1, $s3, copy_show
  # increase i and reset j
  addi $t0, $t0, 1
  li $t1, 0
  # print \n
  la $a0, eol
  li $v0, 4
  syscall
  j iLoopPrint

copy_show:
  # calculate index i * N + j
  li $t2, 0
  mul $t2, $t0, $s3
  add $t2, $t2, $t1
  # load data from newBoard
  lb $t3, newBoard($t2)
  sb $t3, board($t2)

  beq $t3, 0, printDot
  jal printHash

printDot:
  la $a0, dot
  li $v0, 4
  syscall
  # increase j
  addi $t1, $t1, 1
  j jLoopPrint

printHash:
  la $a0, hash
  li $v0, 4
  syscall
  # increase j
  addi $t1, $t1, 1
  j jLoopPrint
