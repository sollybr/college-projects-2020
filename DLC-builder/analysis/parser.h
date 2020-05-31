#ifndef _SCANNER_H_
#error "No scanner used by main process."
#endif

#ifndef _PARSER_H_
#define _PARSER_H_

_ll * all_parseds = NULL;

void parseParams (_ll * tokens_list){

	_ll	* current_tree = NULL;

	for ( _ll * this_tokenscurrent_line = tokens_list; 
		this_tokenscurrent_line != NULL; 
		this_tokenscurrent_line = this_tokenscurrent_line->next ) {

		node * ppe = NULL, * current_node = NULL;
		/* Tree root is port/IOput refer */
		_ll * parse_these = (_ll*)(this_tokenscurrent_line->object);
		char * save_token = malloc(strlen((char*)parse_these->object));
		strcpy(save_token, (char*)parse_these->object);
		current_node = spawn_node(NULL, &ppe, save_token);
		/* Expect port type next */
		parse_these = parse_these->next;

		if (parse_these != NULL) {
			/* If no port type specification, it's circuit input */
			save_token = malloc(strlen((char*)parse_these->object));
			strcpy(save_token, (char*)parse_these->object);
			spawn_node( ppe, 
						&(ppe->l), 
						save_token);
			
			for (parse_these = parse_these->next; 
				parse_these != NULL; 
				parse_these = parse_these->next) {

				save_token = malloc(strlen((char*)parse_these->object));
				strcpy(save_token, (char*)parse_these->object);
				current_node = 
					spawn_node( current_node,
								&(current_node->r), 
								save_token );
				
			} /* Organize port inputs if existent */
		} /* Check all tokens and put 
		them in their correct places */
		if ( all_parseds == NULL )
			{ all_parseds = createListNode(&current_tree, ppe); }
		else {
			current_tree = createListNode(&(current_tree->next), ppe);
		}
	} /* List all identified tokens lists */
} 

#endif /* _PARSER_H_ */