/* 
#include <string.h>
#include <stdlib.h>
*/

char * trimString(char * str, const char * del){

	char * trimmed_str = malloc(strlen(str)*sizeof(char));
	strcpy(trimmed_str, str);
	
	for (int x = 0; x < strlen(del); ++x)
	{
		for (int i = 0; i < strlen(trimmed_str); ++i) {
			if ( trimmed_str[i] == del[x] ){
				for ( 	int j = i; 
						j < strlen(trimmed_str); 
						++j ) {
					trimmed_str[j] = trimmed_str[j+1];
				}
				i--;
			}
		}
	}
	return trimmed_str;
}