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

  

  jr $ra
