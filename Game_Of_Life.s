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

updatingBoard:
  # j++ after every loop
  add $s2, $s2, 1
  b jLoop

neighbours:

copyBackAndShow:
