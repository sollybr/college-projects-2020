import sys
import numpy as np
import asm_ops as asm

def from_hex_to_ascii(my_hex):
	""" 
	O arquivo binario eh complicado de ler,
	preciso converter manualmente do Hex para
	String, lidando com palavras comecadas por 0.
	"""
	counter = 0
	single_instr = ""
	result = np.array([])

	for x in range(0,len(my_hex)):
		
		counter+=1
		add_this = str(my_hex[x][2:])
		if (len(add_this) == 1):
			add_this = "0" + add_this
		single_instr+=add_this
		if (counter == 4):
			result = np.append(result, single_instr)
			single_instr = ""
			counter = 0
	return result

def disassemble(op_code, funct, instr_bytes):

	op_code, funct = int(op_code), int(funct)
	# print(instr_bytes)
	# print(op_code)
	# print(funct)
	readable_instruction = asm.getName(op_code, 
										funct) + " "
	if readable_instruction == "-1 ":
		return "PSEUDO"

	elif (op_code == 2 or op_code == 3):
		address = int(instr_bytes[7],2)
		for y in range(1, 6):
			address += (int(instr_bytes[7-y],2) << (4*y))
		address += (int(instr_bytes[1],2)
			- ((int(instr_bytes[1],2) >> 2) << 2)) << 24
		readable_instruction += str(hex(address))

	else:
		rd = int(instr_bytes[2],2) >> 1
		b5_left = rd + (int(instr_bytes[1],2) 
			- ((int(instr_bytes[1],2) >> 2) << 2) << 3)
		b5_center = (int(instr_bytes[3],2) 
			+ ((int(instr_bytes[2],2) - (rd << 1)) << 4))
		b5_right = ((int(instr_bytes[4],2) << 1) 
			+ (int(instr_bytes[5],2) >> 3))
		b5_right_ext = ((int(instr_bytes[6],2) >> 2) 
			+ ((int(instr_bytes[5],2) 
				- ((int(instr_bytes[5],2) >> 3) << 3)) << 3))
		if (op_code != 0):
			immediate = int(instr_bytes[7],2)
			for y in range(1, 4):
				immediate += (int(instr_bytes[7-y],2) << (4*y))
				# offset imediato precisa dos ultimos 16 bits
			immediate = str(hex(immediate)) # str(int(hex(immediate), 16))
			if (op_code == 35 or op_code == 43): # lw e sw
				rs = b5_center
				rt = b5_left
				immediate += "(" + asm.getRegis(rt) + ")"

			elif (op_code == 15): # lui
				rs = b5_center

			elif (op_code == 4 or op_code == 5): # beq e bne
				rs = b5_left
				rt = b5_center
				immediate = asm.getRegis(rt) + "," + immediate

			else:
				rs = b5_center
				rt = b5_left
				immediate = asm.getRegis(rt) + "," + immediate
			readable_instruction += \
				asm.getRegis(rs) + "," + immediate

		else:
			if (funct == 8): #jr
				rs = b5_left
				readable_instruction += asm.getRegis(rs)

			elif (funct == 0 or funct == 2): #sll e #srl
				shamt = b5_right_ext
				rs = b5_right
				rt = b5_center
				readable_instruction += \
					asm.getRegis(rs) + "," + asm.getRegis(rt) + "," + str(shamt)

			else:
				rs = b5_right
				readable_instruction += asm.getRegis(rs) + ","
				rt = b5_left
				rd = b5_center
				readable_instruction += asm.getRegis(rt) + "," + asm.getRegis(rd)

	return readable_instruction

def get_code(asm_code):

	program = np.array([])
	program_bytes = asm_code.read()
	for x in range(0, len(program_bytes)):
		program = np.append(program, 
							hex(program_bytes[x]))
	readable_program = np.array([])
	program = from_hex_to_ascii(program)
	for x in range(0, len(program)):

		instr_bytes = np.array([])
		for y in range(0,4):

			instr_bytes = np.append(instr_bytes, 
				bin(int(program[x][6 - 2*y], 16))[2:])
			instr_bytes = np.append(instr_bytes, 
				bin(int(program[x][7 - 2*y], 16))[2:])
		op_code = ( (int(instr_bytes[0],2) << 2) 
			+ (int(instr_bytes[1],2) >> 2) )
		funct = int(instr_bytes[7],2) \
			+ ((int(instr_bytes[6],2) 
				- ((int(instr_bytes[6],2) >> 2) << 2)) << 4)
		readable_instruction = disassemble(op_code, 
											funct, 
											instr_bytes)
		readable_program = np.append(readable_program, 
									readable_instruction)
	return readable_program

if __name__ == "__main__":
	try:
		if (len(sys.argv) == 1):
			print("Insert file name.")
			exit()
		my_asm = open(sys.argv[1],'rb')
		to_write = get_code(my_asm)
		my_asm.close()
		my_code = open((sys.argv[1]+".asm"), 'w')
		for x in range(0, len(to_write)):
			my_code.write(to_write[x] + '\n')
		my_code.close()
	except Exception as e:
		raise 
