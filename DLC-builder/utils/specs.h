/* 	This file exists for the developer to tweak its 
	its circuit builder parameters easily */
#ifdef _SPECS_H_
#undef _SPECS_H_
#endif 

#define _SPECS_H_

#ifndef PORT_TYPES_T
#define PORT_TYPES_T

#define NOT_P 0x00
#define AND_P 0x01
#define OR_P 0x02
#define XOR_P 0x03

#endif /* PORT_TYPES_T */

#define TOKEN_SPL_STR " ,"
#ifdef __unix__
#define COMM_SYMBOL "#"
#elif _WIN32
#define COMM_SYMBOL "#"
#endif

#define MAX_TOKEN_LENGTH 5
#define MIN_TOKEN_LENGTH 2
