sll $t1,$a1,2
add $t1,$a0,$t1
lw $t0,0x0($t1)
lw $t2,0x4($t1)
sw $t2,0x0($t1)
sw $t0,0x4($t1)
jr $ra
addi $sp,$sp,0xffec
sw $ra,0x10($sp)
sw $s3,0xc($sp)
sw $s2,0x8($sp)
sw $s1,0x4($sp)
sw $s0,0x0($sp)
addu $s2,$zero,$a0
addu $s3,$zero,$a1
addu $s0,$zero,$zero
slt $t0,$s0,$s3
beq $t0,$zero,0x10
addi $s1,$s0,0xffff
slti $t0,$s1,0x0
bne $t0,$zero,0xb
sll $t1,$s1,2
add $t2,$s2,$t1
lw $t3,0x0($t2)
lw $t4,0x4($t2)
slt $t0,$t4,$t3
beq $t0,$zero,0x5
addu $a0,$zero,$s2
addu $a1,$zero,$s1
jal 0x100000
addi $s1,$s1,0xffff
j 0x100013
addi $s0,$s0,0x1
j 0x100010
lw $s0,0x0($sp)
lw $s1,0x4($sp)
lw $s2,0x8($sp)
lw $s3,0xc($sp)
lw $ra,0x10($sp)
addi $sp,$sp,0x14
