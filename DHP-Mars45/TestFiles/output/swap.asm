sll $t1,$a1,2
add $t1,$a0,$t1
lw $t0,0x0($t1)
lw $t2,0x4($t1)
sw $t2,0x0($t1)
sw $t0,0x4($t1)
