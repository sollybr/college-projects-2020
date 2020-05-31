#pragma once

#include <math.h>

#ifndef STRUCT_PORT_T
#define STRUCT_PORT_T

#ifndef PORT_TYPES_T
#define PORT_TYPES_T

#define NOT_P 0x00
#define AND_P 0x01
#define OR_P 0x02
#define XOR_P 0x03

#endif /* PORT_TYPES_T */

#ifndef MAX_ENTRIES
#define MAX_ENTRIES 8
#endif

#ifndef _ulli
#define _ulli unsigned long long
#endif

typedef struct circ_port {
	short port_t;
	_ulli num_entries;
	struct circ_port ** ENTS;
} c_port;

_ulli num_inputs = 0;
bool * inp_values, * out_values;

c_port * ports_address, 
** out_addresses, 
** inp_addresses;

extern bool calcByType( short, 
						bool, 
						bool);

c_port * portSpawn( c_port * my_addrs,
					short port_t,
					c_port ** entry_ref,
					_ulli num_entries ) {

	if (num_entries > MAX_ENTRIES or
		num_entries < 0) 
		{ return NULL; }
	else if (num_entries != 0) {
		my_addrs->ENTS = 
			(c_port**)malloc(sizeof(c_port*) * num_entries);
		for (_ulli i = 0; i < num_entries; ++i) {
			my_addrs->ENTS[i] = (struct circ_port*)entry_ref[i];
		}
		my_addrs->num_entries = num_entries;
		my_addrs->port_t = port_t;
	}
	return my_addrs;
}

bool calculateOutput( c_port * _to_calc ) {

	c_port ** _entry = _to_calc->ENTS;
	bool my_val;

	if (_to_calc->num_entries == 0){
		_ulli i;
		for (i = 0; i < num_inputs; ++i)
		{
			if (_to_calc == inp_addresses[i])
			{ break; }
		}
		return inp_values[i];
	}
	else if (_to_calc->port_t != NOT_P){
		my_val = calculateOutput(_entry[0]);
	}
	else {
		my_val = 
			(calculateOutput(_entry[0]) == 0) ? 1 :	0;
	}
	bool _prev = my_val;
	for (	_ulli i = 1; i < _to_calc->num_entries; ++i) {
		
		bool next_test = calculateOutput(_entry[i]);
		my_val = 
			calcByType( (_to_calc->port_t), 
						my_val, 
						next_test );
		if (_to_calc->port_t == XOR_P and 
			_prev == next_test and 
			next_test == true) {

			my_val = false;
			break;
		}
		_prev = my_val;
	}
	return my_val;
}

bool calcByType(short type, bool lval, bool rval) {
  bool value = false;
  switch (type) {
  case AND_P:
    value = (lval & rval);
    break;
  case OR_P:
    value = (lval | rval);
    break;
  case XOR_P:
    value = (lval ^ rval);
    break;
    /* ... */
  }
  return value;
}

short getPortType( node * its_type ) {

	if (its_type->l != NULL){
		_ulli type_hash = 
			hashFromString((its_type->l)->refer);
		switch (type_hash){
			case 66871:
				return NOT_P;
			case 1149:
				return OR_P;
			case 60291:
				return XOR_P;
			case 14076:
				return AND_P;
				/* ... */
			default:
				/* Is output */
				return 0x04;
		}
	}
	else return 0x05; /* Input standard identifier */
}

#else
#pragma message "Another definition of STRUCT_PORT_T was found. This one wont be used. (circuit.h)"
#endif /* STRUCT_PORT_T */ 