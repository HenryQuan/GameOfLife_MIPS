  .data
# Board and maxiter
N: .word 10
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
# Strings for output
iterationString: .asciiz "# Iterations: "
afterString: .asciiz "=== After iteration "
restString: .asciiz " ===\n"
eol: .asciiz "\n"

  .text
  .globl main
main:
  # Asking for input
  la $a0, iterationString
  li $v0, 4
  syscall
  li $v0, 5
  syscall
  # Save it into maxiters
  sw $v0, maxiters

  li $s0, 1          # n
  li $s1, 0          # i
  li $s2, 0          # j
  lw $s3, N          # N
  j nLoop

  jr $ra

# Three for loops here
nLoop:
  lw $t0, maxiters
  # if n <= maxiters
  ble $s0, $t0, iLoop
  jr $ra

iLoop:
  blt $s1, $s3, jLoop
  # n++ if i stops looping
  add $s0, $s0, 1
  b nLoop

jLoop:
  blt $s2, $s3, updatingBoard
  # i++ if j stops looping
  add $s0, $s0, 1
  b iLoop

# Do real stuff here
updatingBoard:
  # j++ after every loop
  add $s2, $s2, 1
  b jLoop

# int neighbours(int i ($a0), int j ($a1))
neighbours:
  li $s4, 0       # nn = 0
  li $s5, -1      # x = -1
  li $s6, -1      # y = -1
  ble    $s5, 1, xLoop
  # return nn ($s4)
  li $v0, $s4
  jr $ra

yLoop:
  ble $s6, 1, updatingNN
  # x++ and go back
  add $s5, $s5, 1
  jr $ra

updatingNN:
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
  beq $s5, 0, ZeroXAndY
  # make t1 = t0, reset t0,
  # t0 = i + x, t1 = j + y
  move $t1, $t0
  li $t0, 0
  add $t0, $a0, $s5
  # t2 is the index, N * t0 + t1
  mul $t2, $s3, $t0
  add $t2, $t2, $1
  # Load it into t3
  lb $t3, board($t2))

ZeroXAndY:
  beq $s6, 0, increaseY
  # Go back if x == 0 but y != 0
  jr $ra

increaseNN:
  # nn++
  add $s4, $4, 1
  jr $ra

increaseY:
  # y++ and go back
  add $s6, $s6, 1
  j yLoop

# void copyBackAndShow()
copyBackAndShow:
