addi $sp,$sp,0xffff
sw $ra,0x4($sp)
sw $a0,0x0($sp)
slti $t0,$a0,0x1
beq $t0,$zero,0x3
addi $v0,$zero,0x1
addi $sp,$sp,0x8
jr $ra
addi $a0,$a0,0xffff
jal 0x100000
lw $a0,0x0($sp)
lw $ra,0x4($sp)
addi $sp,$sp,0x8
PSEUDO
jr $ra
