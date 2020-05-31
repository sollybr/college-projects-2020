
#define _PORT_T_HASH_H_

#ifndef _ulli
#define _ulli unsigned long long
#endif

#define P 53
#define M 1e9 + 9

int hashFromString(char * my_str){
	int this_hash = 0;
	_ulli _pow = 1;
	for (int i = 0; i < strlen(my_str); ++i)
	{
		this_hash = (int)( this_hash + 
			( (int)my_str[i] - (int)'a' + 1 ) * _pow ) % (int)M;
		_pow = (_pow * P) % (int)M;

	}
	return this_hash;
}
