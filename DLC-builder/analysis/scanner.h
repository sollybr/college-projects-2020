#ifndef _ulli
#define _ulli unsigned long long
#endif

#ifdef LINKED_LIST_T

#ifndef _SCANNER_H_
#define _SCANNER_H_

#ifndef NO_EMPTY_TOKEN
#define NO_EMPTY_TOKEN 1
#endif

#if !(defined(MAX_TOKEN_LENGTH) && defined(MIN_TOKEN_LENGTH))
#error "Token length limits not determined."
#endif

#ifndef TOKEN_SPL_STR
#error "Token delimiters not specified."
#endif

_ll * scanned_tokens = NULL; /* First token list address */

extern void free_tokens(_ll *, short);

short getTokens ( _ll * lines, _ulli numbercurrent_lines) {

	_ll * thiscurrent_line = lines,
	* this_tokencurrent_line = NULL; /* Iterates lines */
	char * _reade;

	for (_ulli i = 0; i < numbercurrent_lines; ++i)	{	

		_ll * first_token = NULL, 
		* this_list = NULL; /* First token in a line list */
		char * found_token = strtok((char*)thiscurrent_line->object, 
			TOKEN_SPL_STR);
		while (found_token != NULL){
			
			if (strlen(found_token) > MAX_TOKEN_LENGTH or 
				strlen(found_token) < MIN_TOKEN_LENGTH) 
				{ return i+1; }	/*	End prematurely  */
			else {
				char * save_token = 
					(char*)malloc(strlen(found_token));
				strcpy(save_token, found_token);
				if (first_token == NULL){
					first_token = 
						createListNode( &this_list, 
										save_token);
				} else {
					this_list = 
						createListNode( &(this_list->next),
										save_token);
				}
			}
			found_token = strtok(NULL, TOKEN_SPL_STR);
		}
		if (scanned_tokens == NULL){
			scanned_tokens = 
				createListNode( &(this_tokencurrent_line), 
								first_token );
		}
		else {
			this_tokencurrent_line = 
				createListNode( &(this_tokencurrent_line->next), 
								first_token );
		}
		thiscurrent_line = thiscurrent_line->next;
	} 
	return 0;
}

#endif /* _SCANNER_H_ */

#else
#error "LINKED_LIST_T not defined."
#endif /* LINKED_LIST_T */