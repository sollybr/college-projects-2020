import numpy as np

OP_R = 0

op_codes_r = np.array([[32, "add"],
	[33, "addu"],
	[34, "sub"],
	[35, "subu"],
	[36, "and"],
	[37, "or"],
	[39, "nor"],
	[42, "slt"],
	[43, "sltu"],
	[0, "sll"],
	[2, "srl"], [8, "jr"]])

# pseudo_r = np.array([])

op_codes_i = np.array([[4, "beq"],
	[5, "bne"],
	[8, "addi"],
	[9, "addiu"],
	[12, "andi"],
	[13, "ori"],
	[10, "slti"],
	[11, "sltiu"],
	[15, "lui"],
	[35, "lw"],
	[43, "sw"]])

op_codes_j = np.array([[2, "j"],
	[3, "jal"]])

registers = np.array(["$zero",
	"$at",
	"$v0", "$v1",
	"$a0", "$a1", "$a2", "$a3",
	"$t0", "$t1", "$t2", "$t3",
	"$t4", "$t5", "$t6", "$t7",
	"$s0", "$s1", "$s2", "$s3",
	"$s4", "$s5", "$s6", "$s7",
	"$t8", "$t9", 
	"$k0", "$k1",
	"$gp", "$sp", "$fp",
	"$ra"])

def getName(op_code, funct):
	# prop_code
	# print(funct)
	if op_code == OP_R:
		if (funct < 38 and funct > 31):
			return op_codes_r[funct-32][1]
		else:
			for x in range(6,len(op_codes_r)):
				if (int(op_codes_r[x][0]) == int(funct)):
					return op_codes_r[x][1]
	elif op_code == 2:
		return "j"
	elif op_code == 3:
		return "jal"
	else:
		for x in range(0,len(op_codes_i)):
				if (int(op_codes_i[x][0]) == int(op_code)):
					return op_codes_i[x][1]
	return "-1"

def getRegis(register_number):
	return registers[register_number]
